import Foundation

class Map<T: Node> {
  let width: Int
  let height: Int
  // TODO: Probably should not be public.
  var inventory = Dictionary<Item, Int>()
  var map: [[T]]
  var nodes = Set<Building>()
  // TODO: Change to weak referenced.
  var active = Set<Building>()
  var turn = 0

  init(width: Int, height: Int) {
    let seed = Int(arc4random())
    self.width = width
    self.height = height
    map = []
    for col in 0 ..< width {
      var colArray: [T] = []
      for row in 0 ..< height {
        let node = T(column: col, row: row)
        if col == 0 || col == width - 1 || row == 0 || row == height - 1 {
          let value = Wall(position: Point(x: col, y: row))
          nodes.insert(value)
          node.value = value
        } else {
          if cos(Double(col + seed) / 8) + sin(Double(row + seed) / 4) > 1.8 {
            node.ore = .iron_ore
          }
          if sin(Double(col - seed) / 8) + cos(Double(row - seed) / 4) > 1.8 {
            node.ore = .stone
          }
          if sin(Double(col + seed) / 8) + cos(Double(row + seed) / 4) > 1.8 {
            node.ore = .copper_ore
          }
        }
        colArray.append(node)
      }
      map.append(colArray)
    }
  }

  func get(at: Point) -> T {
    return get(x: at.x, y: at.y)
  }

  func check(type: Item, at: Point) -> Bool {
    if inventory[type, default: 0] <= 0 {
      return false
    }
    let (w, h) = type.size()
    for row in 0 ..< h {
      for col in 0 ..< w {
        if at.x + col >= width || at.y + row >= height {
          return false
        }
        let node = get(x: at.x + col, y: at.y + row)
        switch node.value {
        case .none: continue
        default: return false
        }
      }
    }
    return type == .mine ? ores(type: type, at: at).count > 0 : true
  }

  @discardableResult
  func build(type: Item, at: Point) -> Building? {
    guard let build = type.build() else { return nil }
    if !check(type: type, at: at) {
      return nil
    }
    inventory[type, default: 0] -= 1
    let receiver: Building
    switch build {
    case is Mine.Type:
      receiver = Mine(position: at, raw: ores(type: type, at: at))
//    case is Yard.Type:
//      receiver = Yard(map: self)
    case is Factory.Type:
      receiver = Factory(position: at)
    case is Furnace.Type:
      receiver = Furnace(position: at)
    default:
      return nil
    }
    let (w, h) = type.size()
    for row in 0 ..< h {
      for col in 0 ..< w {
        set(x: at.x + col, y: at.y + row, value: receiver)
      }
    }
    active.insert(receiver)
    return receiver
  }

  func pipe(from: Point, to: Point) {
    var dest = get(at: to).value
    if dest == nil {
      dest = Pipe(position: to)
      set(at: to, value: dest!)
    }
    guard let destination = dest else { return }

    let source = get(at: from).value
    if let source = source {
      if source != destination {
        source.pipe(to: destination)
      }
    } else {
      let p = Pipe(position: from)
      set(at: from, value: p)
      p.pipe(to: destination)
    }
  }

  func delete(at: Point) {
    let value = get(at: at).value
    if let value = value {
      switch value {
      case is Wall: return
      case is Pipe: break
      case let receiver:
        active.remove(receiver)
        inventory[receiver.type, default: 0] += 1
      }
      nodes.remove(value)
    }
    set(at: at, value: nil)
  }

  func update() {
    for receiver in active {
      receiver.update(turn: turn)
    }
    turn += 1
  }

  private func ores(type: Item, at: Point) -> Set<Item> {
    var ores = Set<Item>()
    let (w, h) = type.size()
    for row in 0 ..< h {
      for col in 0 ..< w {
        let ore = get(x: at.x + col, y: at.y + row).ore
        if ore != .none {
          ores.insert(ore)
        }
      }
    }
    return ores
  }

  private func get(x: Int, y: Int) -> T {
    return map[x][y]
  }

  private func set(at: Point, value: Building?) {
    set(x: at.x, y: at.y, value: value)
  }

  private func set(x: Int, y: Int, value: Building?) {
    if let value = value {
      nodes.insert(value)
    }
    map[x][y].value = value
  }
}

// MARK: - Inventory

extension Map: Inventory {

  func get(item: Item) -> Int {
    return inventory[item] ?? 0
  }

  func add(item: Item, count: Int) {
    inventory[item] = (inventory[item] ?? 0) + count
  }

  func available() -> [Item] {
    return Array(inventory.keys)
  }

}
