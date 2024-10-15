import common/adventofcode/advent_of_code
import common/adventofcode/auth
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/io
import gleam/result

pub type AdventOfCodeError {
  SessionError(auth.SessionCookieError)
  FetchError
}

pub fn get_from_website(path: String) -> Result(String, AdventOfCodeError) {
  use session <- result.try(
    auth.get_session_or_ask_human() |> result.map_error(SessionError),
  )
  let assert Ok(r) = request.to("https://adventofcode.com/" <> path)
  let request =
    r
    |> request.set_cookie("session", session)
    |> auth.set_user_agent
  use response <- result.try(
    httpc.send(request) |> result.map_error(fn(_) { FetchError }),
  )
  case response.status {
    200 -> Ok(response.body)
    _ -> Error(FetchError)
  }
}

pub fn post_answer(
  puzzle: advent_of_code.PuzzleId,
  part: advent_of_code.PuzzlePart,
  answer: String,
) -> Result(String, AdventOfCodeError) {
  use session <- result.try(
    auth.get_session_or_ask_human() |> result.map_error(SessionError),
  )
  let assert Ok(r) =
    request.to(
      "https://adventofcode.com/"
      <> advent_of_code.day_path(puzzle)
      <> "/answer",
    )
  let request =
    r
    |> request.set_method(http.Post)
    |> request.set_cookie("session", session)
    |> auth.set_user_agent
    |> request.set_header("Content-Type", "application/x-www-form-urlencoded")
    |> request.set_body(
      "level=" <> advent_of_code.part_int_string(part) <> "&answer=" <> answer,
    )
    |> io.debug
  use response <- result.try(
    httpc.send(request) |> io.debug |> result.map_error(fn(_) { FetchError }),
  )
  case response.status {
    200 -> Ok(response.body)
    _ -> Error(FetchError)
  }
}
