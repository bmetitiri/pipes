//
//  GameScene.swift
//  Pipes
//
//  Created by Beatrice Metitiri on 1/28/18.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  var level: Map!

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

}
