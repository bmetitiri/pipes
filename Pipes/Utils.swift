//
//  Utils.swift
//  Pipes
//
//  Created by Beatrice Metitiri on 7/21/18.
//

import Foundation
import UIKit
import SpriteKit

class Utils {

  static func gridTexture(rows: Int, cols: Int, tileSize: CGFloat) -> SKTexture? {
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
