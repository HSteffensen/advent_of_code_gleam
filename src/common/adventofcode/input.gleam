import common/adventofcode/advent_of_code.{type PuzzleId}
import common/adventofcode/local_data
import common/adventofcode/website
import gleam/io
import gleam/result
import simplifile

fn local_input_file(puzzle: PuzzleId) -> String {
  local_data.local_day_folder(puzzle) <> "input.txt"
}

pub fn get_puzzle_input(
  puzzle: PuzzleId,
) -> Result(String, website.AdventOfCodeError) {
  case get_input_from_local_file(puzzle) {
    Ok(i) -> Ok(i)
    Error(_) ->
      get_input_from_website(puzzle)
      |> result.map(fn(i) {
        write_input_to_local_file(puzzle, i)
        i
      })
  }
}

fn get_input_from_local_file(puzzle: PuzzleId) -> Result(String, Nil) {
  simplifile.read(local_input_file(puzzle)) |> result.replace_error(Nil)
}

fn write_input_to_local_file(puzzle: PuzzleId, input: String) -> Nil {
  let date_str = advent_of_code.day_string(puzzle)
  local_data.create_local_day_folder_if_not_exists(puzzle)
  case simplifile.write(local_input_file(puzzle), input) {
    Error(_) ->
      io.println(
        "Failed to write puzzle input for " <> date_str <> " to local cache.",
      )
    Ok(_) ->
      io.println(
        "Puzzle input for "
        <> date_str
        <> " written to local cache, and will be used in the future.",
      )
  }
}

fn get_input_from_website(
  puzzle: PuzzleId,
) -> Result(String, website.AdventOfCodeError) {
  website.get_from_website(advent_of_code.day_path(puzzle) <> "/input")
}
