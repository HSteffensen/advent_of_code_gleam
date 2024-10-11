import common/adventofcode/auth
import common/adventofcode/examples
import common/adventofcode/input
import gleam/io

pub fn main() {
  case auth.get_session_or_ask_human() {
    Error(_) -> io.println("Failed to get session cookie.")
    Ok(_) -> io.println("Session cookie works good.")
  }
  case input.get_puzzle_input(2023, 1) {
    Error(_) -> io.println("Failed to get puzzle input.")
    Ok(_) -> io.println("Puzzle input works good.")
  }
  case examples.get_examples_or_ask_human(2023, 1, 1) {
    Error(_) -> io.println("Failed to get puzzle examples.")
    Ok(_) -> io.println("Puzzle examples works good.")
  }
  case examples.get_examples_or_ask_human(2023, 1, 2) {
    Error(_) -> io.println("Failed to get puzzle examples.")
    Ok(_) -> io.println("Puzzle examples works good.")
  }
}
