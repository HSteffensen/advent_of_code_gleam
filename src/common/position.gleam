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
