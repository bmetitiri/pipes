class Pipe: Building {
  init(position: Point) {
    super.init(type: .pipe, position: position)
  }

  func content() -> Item {
    if let item = inventory.first(where: { $1 > 0 }) {
      return item.key
    }
    return .none
  }

  override func receive(item: Item) -> Bool {
    guard content() == .none else { return false }
    inventory[item] = inventory[item, default: 0] + 1
    return true
  }
}
