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
