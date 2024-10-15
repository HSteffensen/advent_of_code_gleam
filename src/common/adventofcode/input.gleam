import common/adventofcode/local_data
import common/adventofcode/website
import gleam/int
import gleam/io
import gleam/result
import simplifile

fn local_input_file(year: Int, day: Int) -> String {
  local_data.local_day_folder(year, day) <> "input.txt"
}

pub fn get_puzzle_input(
  year: Int,
  day: Int,
) -> Result(String, website.AdventOfCodeError) {
  case get_input_from_local_file(year, day) {
    Ok(i) -> Ok(i)
    Error(_) ->
      get_input_from_website(year, day)
      |> result.map(fn(i) {
        write_input_to_local_file(year, day, i)
        i
      })
  }
}

fn get_input_from_local_file(year: Int, day: Int) -> Result(String, Nil) {
  simplifile.read(local_input_file(year, day)) |> result.nil_error
}

fn write_input_to_local_file(year: Int, day: Int, input: String) -> Nil {
  let date_str = "y" <> int.to_string(year) <> "d" <> int.to_string(day)
  local_data.create_local_day_folder_if_not_exists(year, day)
  case simplifile.write(local_input_file(year, day), input) {
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
  year: Int,
  day: Int,
) -> Result(String, website.AdventOfCodeError) {
  website.get_from_website(
    int.to_string(year) <> "/day/" <> int.to_string(day) <> "/input",
  )
}
