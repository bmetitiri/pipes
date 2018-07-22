//
//  GameScene.swift
//  Pipes
//
//  Created by Beatrice Metitiri on 1/28/18.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  // MARK:  Game stuff
  var map: Map<GameNode>! {
    didSet {
      updateMap()
    }
  }

  var currentBuildType: Item?

  let tileSize: CGFloat = 32.0

  // MARK: Layers
  let gameLayer = SKSpriteNode()
  let nodeLayer = SKNode()

  // MARK: Gesture stuff
  var startPinchScale: CGFloat = 1.0
  var draggingType: Building.Type?
  var draggingNodes: [SKSpriteNode]?
  var dragAnchorNode: SKSpriteNode?

  // MARK: - Initialization functions

  override func didMove(to view: SKView) {
    addChild(gameLayer)
    gameLayer.anchorPoint = anchorPoint
    gameLayer.addChild(nodeLayer)

    let camera = SKCameraNode()
    addChild(camera)
    self.camera = camera
    setupGestures()
  }

  private func setupGestures() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panRecognized))
    panGesture.minimumNumberOfTouches = 2
//    panGesture.delaysTouchesBegan = true
    view?.addGestureRecognizer(panGesture)

    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized))
//    pinchGesture.delaysTouchesBegan = true
    view?.addGestureRecognizer(pinchGesture)
  }

  func addSprites(for nodes: [GameNode]) {
    for node in nodes where node.value != nil || node.ore != .none {
      let spriteName = (node.value?.type ?? node.ore).spriteName
      let sprite = createNodeSprite(named: spriteName, at: node.position)
      nodeLayer.addChild(sprite)
      node.sprite = sprite
    }
  }

  func addSprites(for building: Building) {
    let size = type(of: building).size()
    for row in 0..<size.height {
      for col in 0..<size.width {
        let nodePoint = Point(x: building.position.x + col, y: building.position.y + row)
        let node = map.get(at: nodePoint)
        if let oldSprite = node.sprite {
          oldSprite.removeFromParent()
        }
        let sprite = createNodeSprite(named: building.type.spriteName, at: nodePoint)
        nodeLayer.addChild(sprite)
        node.sprite = sprite
      }
    }
  }

  // MARK: - Helper functions
  
  private func spritePositionFor(point: Point) -> CGPoint {
    return CGPoint(
      x: CGFloat(point.x) * tileSize + tileSize / 2,
      y: CGFloat(point.y) * tileSize + tileSize / 2)
  }

  private func mapPosition(for point: CGPoint) -> Point {
    let x = (point.x - tileSize / 2) / tileSize
    let y = (point.y - tileSize / 2) / tileSize
    return Point(x: Int(x), y: Int(y))
  }

  private func createNodeSprite(named spriteName: String, at point: Point) -> SKSpriteNode {
    let sprite = SKSpriteNode(imageNamed: spriteName)
    sprite.size = CGSize(width: tileSize, height: tileSize)
    sprite.position = spritePositionFor(point: point)
    return sprite
  }

  func updateMap() {
    addSprites(for: map.map.flatMap { return $0 })
    updateCameraConstraints()
    guard let texture = Utils.gridTexture(rows: map.height, cols: map.width, tileSize: tileSize)
      else { return }
    gameLayer.size = CGSize(width: texture.size().width, height: texture.size().height)
    gameLayer.texture = texture
  }

  private func updateCameraConstraints() {
    guard let camera = camera else { return }
    let mapRect = nodeLayer.calculateAccumulatedFrame()
    let scaledSize = CGSize(width: size.width * camera.xScale, height: size.height * camera.yScale)
    let xInset = min((scaledSize.width / 2) - 100, mapRect.width / 2)
    let yInset = min((scaledSize.height / 2) - 100, mapRect.height / 2)
    let insetRect = mapRect.insetBy(dx: xInset, dy: yInset)
    let xRange = SKRange(lowerLimit: insetRect.minX, upperLimit: insetRect.maxX)
    let yRange = SKRange(lowerLimit: insetRect.minY, upperLimit: insetRect.maxY)
    let cameraEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
    camera.constraints = [cameraEdgeConstraint]
  }

}

// MARK: - Gesture Recognizers

extension GameScene {

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, touches.count == 1,
      let buildType = currentBuildType, let build = buildType.build() else { return }
    draggingType = build
    draggingNodes = []
    let anchorPoint = mapPosition(for: touch.location(in: nodeLayer))
    for row in 0..<build.size().height {
      for col in 0..<build.size().width {
        let nodePoint = Point(x: anchorPoint.x + col, y: anchorPoint.y + row)
        let sprite = createNodeSprite(named: buildType.spriteName, at: nodePoint)
        sprite.alpha = 0.7
        draggingNodes?.append(sprite)
        nodeLayer.addChild(sprite)
        if nodePoint == anchorPoint {
          dragAnchorNode = sprite
        }
      }
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, touches.count == 1,
      let anchorNode = dragAnchorNode, let nodes = draggingNodes else {
      endDrag()
      return
    }
    let newAnchorPoint = mapPosition(for: touch.location(in: nodeLayer))
    let anchorPoint = mapPosition(for: anchorNode.position)
    guard newAnchorPoint != anchorPoint else { return }
    let xDiff = newAnchorPoint.x - anchorPoint.x
    let yDiff = newAnchorPoint.y - anchorPoint.y
    nodes.forEach { node in
      let nodeAnchor = mapPosition(for: node.position)
      node.position = spritePositionFor(point: Point(x: nodeAnchor.x + xDiff,
                                                     y: nodeAnchor.y + yDiff))
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let buildType = currentBuildType, let anchorNode = dragAnchorNode else {
      endDrag()
      return
    }
    let buildPoint = mapPosition(for: anchorNode.position)
    if let building = map.build(type: buildType, at: buildPoint) {
      addSprites(for: building)
    }
    endDrag()
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    endDrag()
  }

  private func endDrag() {
    if let nodes = draggingNodes {
      for node in nodes {
        node.removeFromParent()
      }
    }
    draggingType = nil
    draggingNodes = nil
    dragAnchorNode = nil
  }

  @objc func panRecognized(_ sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view!)
    sender.setTranslation(CGPoint.zero, in: view)
    guard let position = camera?.position else { return }
    camera?.position = CGPoint(x: position.x - translation.x, y: position.y + translation.y)
  }

  @objc func pinchRecognized(_ sender: UIPinchGestureRecognizer) {
    guard let camera = camera else { return }
    if sender.state == .began {
      startPinchScale = camera.xScale
    } else if sender.state != .changed {
      return
    }
    var newScale = startPinchScale / sender.scale
    newScale = max(min(newScale, 2.5), 0.5)
    camera.xScale = newScale
    camera.yScale = newScale
    updateCameraConstraints()
  }

}
