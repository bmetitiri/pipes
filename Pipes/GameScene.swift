//
//  GameScene.swift
//  Pipes
//
//  Created by Beatrice Metitiri on 1/28/18.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  var level: Map<GameNode>!

  let tileWidth: CGFloat = 32.0
  let tileHeight: CGFloat = 32.0

  let gameLayer = SKNode()
  let nodeLayer = SKNode()

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(size: CGSize) {
    super.init(size: size)

    addChild(gameLayer)
//
//    let layerPosition = CGPoint(
//      x: -TileWidth * CGFloat(NumColumns) / 2,
//      y: -TileHeight * CGFloat(NumRows) / 2)
//
//    cookiesLayer.position = layerPosition
    gameLayer.addChild(nodeLayer)
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

}
