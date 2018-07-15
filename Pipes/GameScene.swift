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

  let tileSize: CGFloat = 32.0

  // MARK: Layers
  let gameLayer = SKSpriteNode()
  let nodeLayer = SKNode()

  // MARK: Gesture stuff
  var startPinchScale: CGFloat = 1.0

  // MARK: - Initialization functions

  override func didMove(to view: SKView) {
    addChild(gameLayer)
    gameLayer.anchorPoint = anchorPoint
    //
    //    let layerPosition = CGPoint(
    //      x: -TileWidth * CGFloat(NumColumns) / 2,
    //      y: -TileHeight * CGFloat(NumRows) / 2)
    //
    //    cookiesLayer.position = layerPosition
    gameLayer.addChild(nodeLayer)

    let camera = SKCameraNode()
    addChild(camera)
    self.camera = camera
    setupGestures()
  }

  private func setupGestures() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panRecognized))
    panGesture.maximumNumberOfTouches = 1
    view?.addGestureRecognizer(panGesture)

    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized))
    view?.addGestureRecognizer(pinchGesture)
  }

  func addSprites(for nodes: [GameNode]) {
    for node in nodes where node.value != nil {
      let sprite = SKSpriteNode(imageNamed: node.value!.type.spriteName)
      sprite.size = CGSize(width: tileSize, height: tileSize)
      sprite.position = spritePositionFor(column: node.column, row: node.row)
      nodeLayer.addChild(sprite)
      node.sprite = sprite
    }
  }

  // MARK: - Helper functions
  
  private func spritePositionFor(column: Int, row: Int) -> CGPoint {
    return CGPoint(
      x: CGFloat(column) * tileSize + tileSize / 2,
      y: CGFloat(row) * tileSize + tileSize / 2)
  }

  func updateMap() {
    addSprites(for: map.map.flatMap { return $0 })
    updateCameraConstraints()
    guard let texture = gridTexture(rows: map.height, cols: map.width, tileSize: tileSize)
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

  private func gridTexture(rows: Int, cols: Int, tileSize: CGFloat) -> SKTexture? {
    // Add 1 to the height and width to ensure the borders are within the sprite
    let size = CGSize(width: CGFloat(cols) * tileSize + 1, height: CGFloat(rows) * tileSize + 1)
    UIGraphicsBeginImageContext(size)

    guard let context = UIGraphicsGetCurrentContext() else {
      return nil
    }
    let bezierPath = UIBezierPath()
    let offset: CGFloat = 0.5
    // Draw vertical lines
    for i in 0...cols {
      let x = CGFloat(i) * tileSize + offset
      bezierPath.move(to: CGPoint(x: x, y: 0))
      bezierPath.addLine(to: CGPoint(x: x, y: size.height))
    }
    // Draw horizontal lines
    for i in 0...rows {
      let y = CGFloat(i) * tileSize + offset
      bezierPath.move(to: CGPoint(x: 0, y: y))
      bezierPath.addLine(to: CGPoint(x: size.width, y: y))
    }
    SKColor.white.setStroke()
    bezierPath.lineWidth = 1.0
    bezierPath.stroke()
    context.addPath(bezierPath.cgPath)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return SKTexture(image: image!)
  }

}

// MARK: - Gesture Recognizers

extension GameScene {

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
