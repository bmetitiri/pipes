//
//  ItemButton.swift
//  Pipes
//
//  Created by Beatrice Metitiri on 7/21/18.
//

import UIKit

class ItemButton: UIButton {

  var type: Item = .none {
    didSet {
      updateContents()
    }
  }
  weak var inventory: Inventory?

  override func awakeFromNib() {
    super.awakeFromNib()
    backgroundColor = UIColor.clear
    setTitleColor(UIColor.black, for: .normal)
  }

  func updateContents() {
    setImage(UIImage(named: type.spriteName), for: .normal)
    guard let count = inventory?.get(item: type) else {
      setTitle("0", for: .normal)
      return
    }
    setTitle("\(count)", for: .normal)
  }

}
