import common/adventofcode/advent_of_code.{type PuzzleId, type PuzzlePart}
import gleam/int
import gleam/result
import simplifile

pub fn local_data_folder() -> String {
  "./.local/"
}

pub fn create_local_data_folder_if_not_exists() -> Nil {
  simplifile.create_directory_all(local_data_folder()) |> result.unwrap(Nil)
}

pub fn local_day_folder(puzzle: PuzzleId) -> String {
  local_data_folder()
  <> int.to_string(puzzle.year)
  <> "/"
  <> int.to_string(puzzle.day)
  <> "/"
}

pub fn create_local_day_folder_if_not_exists(puzzle: PuzzleId) -> Nil {
  simplifile.create_directory_all(local_day_folder(puzzle))
  |> result.unwrap(Nil)
}

pub fn local_part_folder(puzzle: PuzzleId, part: PuzzlePart) -> String {
  local_day_folder(puzzle) <> advent_of_code.part_int_string(part) <> "/"
}

pub fn create_local_part_folder_if_not_exists(
  puzzle: PuzzleId,
  part: PuzzlePart,
) -> Nil {
  simplifile.create_directory_all(local_part_folder(puzzle, part))
  |> result.unwrap(Nil)
}
