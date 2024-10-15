import gleam/int

pub type PuzzlePart {
  Part1
  Part2
}

pub fn part_int_string(part: PuzzlePart) -> String {
  case part {
    Part1 -> "1"
    Part2 -> "2"
  }
}

pub type PuzzleId {
  PuzzleId(year: Int, day: Int)
}

pub fn day_string(puzzle_id: PuzzleId) -> String {
  "y" <> int.to_string(puzzle_id.year) <> "d" <> int.to_string(puzzle_id.day)
}

pub fn day_path(puzzle: PuzzleId) -> String {
  int.to_string(puzzle.year) <> "/day/" <> int.to_string(puzzle.day)
}
