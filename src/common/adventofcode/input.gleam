import common/adventofcode/auth
import common/adventofcode/local_data
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/result
import simplifile

fn local_input_file(year: Int, day: Int) -> String {
  local_data.local_day_folder(year, day) <> "input.txt"
}

pub type PuzzleInputError {
  SessionError(auth.SessionCookieError)
  FetchError
}

pub fn get_puzzle_input(year: Int, day: Int) -> Result(String, PuzzleInputError) {
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
) -> Result(String, PuzzleInputError) {
  use session <- result.try(
    auth.get_session_or_ask_human() |> result.map_error(SessionError),
  )
  let assert Ok(r) =
    request.to(
      "https://adventofcode.com/"
      <> int.to_string(year)
      <> "/day/"
      <> int.to_string(day)
      <> "/input",
    )
  let request = request.set_cookie(r, "session", session)
  use response <- result.try(
    httpc.send(request) |> result.map_error(fn(_) { FetchError }),
  )
  case response.status {
    200 -> Ok(response.body)
    _ -> Error(FetchError)
  }
}
