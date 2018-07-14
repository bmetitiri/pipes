//
//  Item+Extensions.swift
//  Pipes
//
//  Created by Beatrice Metitiri on 4/8/18.
//

import Foundation
import UIKit

extension Item {

    var spriteName: String {
        return rawValue
    }

    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }

}
