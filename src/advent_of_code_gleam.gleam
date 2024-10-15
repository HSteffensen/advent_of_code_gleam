import common/adventofcode/advent_of_code
import common/adventofcode/examples
import common/adventofcode/input
import gleam/io

pub fn main() {
  case input.get_puzzle_input(advent_of_code.PuzzleId(2018, 1)) {
    Error(_) -> io.println("Failed to get puzzle input.")
    Ok(_) -> io.println("Puzzle input works good.")
  }
  case
    examples.get_examples_or_ask_human(
      advent_of_code.PuzzleId(2018, 1),
      advent_of_code.Part1,
    )
  {
    Error(_) -> io.println("Failed to get puzzle examples.")
    Ok(_) -> io.println("Puzzle examples works good.")
  }
  case
    examples.get_examples_or_ask_human(
      advent_of_code.PuzzleId(2018, 1),
      advent_of_code.Part2,
    )
  {
    Error(_) -> io.println("Failed to get puzzle examples.")
    Ok(_) -> io.println("Puzzle examples works good.")
  }
}
