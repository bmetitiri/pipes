class Yard: Building {
  override class func size() -> (width: Int, height: Int) {
    return (4, 3)
  }

  weak var map: Inventory!

  init(map: Inventory) {
    self.map = map
    super.init(type: .yard)
  }

  override func receive(item: Item) -> Bool {
    if item != .none {
      map.add(item: item)
      return true
    }
    return super.receive(item: item)
  }
}
