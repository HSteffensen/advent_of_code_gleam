pub type Pos2d {
  Pos2d(x: Int, y: Int)
}

pub type Direction {
  North
  South
  West
  East
}

pub fn rotate_right(dir: Direction) -> Direction {
  case dir {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

pub fn step(pos: Pos2d, dir: Direction) -> Pos2d {
  case pos, dir {
    Pos2d(x, y), North -> Pos2d(x, y - 1)
    Pos2d(x, y), South -> Pos2d(x, y + 1)
    Pos2d(x, y), West -> Pos2d(x - 1, y)
    Pos2d(x, y), East -> Pos2d(x + 1, y)
  }
}

pub fn neighbors4(pos: Pos2d) -> List(Pos2d) {
  [step(pos, North), step(pos, South), step(pos, West), step(pos, East)]
}

pub fn sort(a: Pos2d, b: Pos2d) -> #(Pos2d, Pos2d) {
  case a, b {
    Pos2d(x1, _), Pos2d(x2, _) if x1 < x2 -> #(a, b)
    Pos2d(x1, _), Pos2d(x2, _) if x2 < x1 -> #(b, a)
    Pos2d(_, y1), Pos2d(_, y2) if y1 < y2 -> #(a, b)
    _, _ -> #(b, a)
  }
}
