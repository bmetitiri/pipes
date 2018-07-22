//
//  GameViewController.swift
//  Pipes
//
//  Created by Beatrice Metitiri on 1/28/18.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  @IBOutlet var skView: SKView!
  @IBOutlet var quickSlotView: UIStackView!

  var scene: GameScene!
  var map: Map<GameNode>!

  private let startItems: [Item: Int] = [.mine: 2, .furnace: 2, .factory: 1, .yard: 1]

  override var shouldAutorotate: Bool {
    return true
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    skView.isMultipleTouchEnabled = false

    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    skView.presentScene(scene)

    beginGame()
  }

  func beginGame() {
    map = Map<GameNode>(width: 20, height: 30)
    var buttonIndex = 0
    for (type, count) in startItems {
      map.inventory[type] = count
      guard buttonIndex < quickSlotView.arrangedSubviews.count,
        let button = quickSlotView.arrangedSubviews[buttonIndex] as? ItemButton
        else { return }
      button.inventory = map
      button.type = type
      buttonIndex += 1
    }
    scene.map = map
    map.update()
  }

  func select(button: UIButton) {
    quickSlotView.arrangedSubviews.forEach { button in
      button.backgroundColor = UIColor.clear
    }
    button.backgroundColor = UIColor.yellow
  }

  @IBAction func quickSlotPressed(_ sender: Any) {
    guard let button = sender as? ItemButton else { return }
    guard scene.currentBuildType != button.type else {
      button.backgroundColor = UIColor.clear
      scene.currentBuildType = nil
      return
    }
    scene.currentBuildType = button.type
    select(button: button)
  }

}
