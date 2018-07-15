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

  var scene: GameScene!

  override var prefersStatusBarHidden: Bool {
    return true
  }

  override var shouldAutorotate: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false

    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    skView.presentScene(scene)
  }

}