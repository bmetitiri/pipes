//
//  Inventory.swift
//  Pipes
//
//  Created by Beatrice Metitiri on 7/21/18.
//

import Foundation

protocol Inventory: class {

  func get(item: Item) -> Int
  func add(item: Item, count: Int)
  func available() -> [Item]

}
