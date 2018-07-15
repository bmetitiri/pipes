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
      addSprites(for: map.map.flatMap { return $0 })
      updateCameraConstraints()
    }
  }

  let tileWidth: CGFloat = 32.0
  let tileHeight: CGFloat = 32.0

  // MARK: Layers
  let gameLayer = SKNode()
  let nodeLayer = SKNode()

  // MARK: Gesture variables
  private var lastPosition: CGPoint = CGPoint.zero

  override func didMove(to view: SKView) {
    addChild(gameLayer)
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
      sprite.size = CGSize(width: tileWidth, height: tileHeight)
      sprite.position = pointFor(column: node.column, row: node.row)
      nodeLayer.addChild(sprite)
      node.sprite = sprite
    }
  }
  
  private func pointFor(column: Int, row: Int) -> CGPoint {
    return CGPoint(
      x: CGFloat(column) * tileWidth + tileWidth / 2,
      y: CGFloat(row) * tileHeight + tileHeight / 2)
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

  @objc func panRecognized(_ sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view!)
    sender.setTranslation(CGPoint.zero, in: view)
    guard let position = camera?.position else { return }
    camera?.position = CGPoint(x: position.x - translation.x, y: position.y + translation.y)
  }

  @objc func pinchRecognized(_ sender: UIPinchGestureRecognizer) {
    guard let camera = camera else { return }
    var newScale = camera.xScale / sender.scale
    newScale = max(min(newScale, 2.5), 0.5)
    camera.xScale = newScale
    camera.yScale = newScale
    updateCameraConstraints()
  }

}
