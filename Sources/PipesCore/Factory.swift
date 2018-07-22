class Factory: Building {
  override class func size() -> (width: Int, height: Int) {
    return (3, 3)
  }

  init(position: Point) {
    super.init(type: .factory, position: position)
  }

  var raw = [Item: Int]()
  var time = 0
  var target = Item.none

  override func receive(item: Item) -> Bool {
    guard let recipe = target.recipe() else { return false }
    if recipe.keys.contains(item) {
      let count = raw[item, default: 0]
      if count < item.stack() {
        raw[item] = count + 1
        return true
      }
    }
    return super.receive(item: item)
  }

  override func update(turn: Int) {
    super.update(turn: turn)
    guard let recipe = target.recipe() else { return }
    if stocked() {
      time += 1
      if time > 10 {
        let made = inventory[target, default: 0]
        if made < target.stack() {
          time = 0
          for (part, count) in recipe {
            raw[part]? -= count
          }
          inventory[target] = made + 1
        }
      }
    }
  }

  private func stocked() -> Bool {
    guard let recipe = target.recipe() else { return false }
    for (part, count) in recipe {
      if raw[part, default: 0] < count {
        return false
      }
    }
    return true
  }
}
