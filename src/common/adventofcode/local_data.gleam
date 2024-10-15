import common/adventofcode/advent_of_code.{type PuzzlePart}
import gleam/int
import gleam/result
import simplifile

pub fn local_data_folder() -> String {
  "./.local/"
}

pub fn create_local_data_folder_if_not_exists() -> Nil {
  simplifile.create_directory_all(local_data_folder()) |> result.unwrap(Nil)
}

pub fn local_day_folder(year: Int, day: Int) -> String {
  local_data_folder() <> int.to_string(year) <> "/" <> int.to_string(day) <> "/"
}

pub fn create_local_day_folder_if_not_exists(year: Int, day: Int) -> Nil {
  simplifile.create_directory_all(local_day_folder(year, day))
  |> result.unwrap(Nil)
}

pub fn local_part_folder(year: Int, day: Int, part: PuzzlePart) -> String {
  local_data_folder()
  <> int.to_string(year)
  <> "/"
  <> int.to_string(day)
  <> "/"
  <> advent_of_code.part_int_string(part)
  <> "/"
}

pub fn create_local_part_folder_if_not_exists(
  year: Int,
  day: Int,
  part: PuzzlePart,
) -> Nil {
  simplifile.create_directory_all(local_part_folder(year, day, part))
  |> result.unwrap(Nil)
}
