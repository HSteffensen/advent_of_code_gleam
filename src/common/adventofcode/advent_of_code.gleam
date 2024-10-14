import common/adventofcode/auth
import gleam/http
import gleam/http/request
import gleam/httpc
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

pub fn post_to_website(
  path: String,
  body: String,
) -> Result(String, AdventOfCodeError) {
  use session <- result.try(
    auth.get_session_or_ask_human() |> result.map_error(SessionError),
  )
  let assert Ok(r) = request.to("https://adventofcode.com/" <> path)
  let request =
    r
    |> request.set_method(http.Post)
    |> request.set_cookie("session", session)
    |> auth.set_user_agent
    |> request.set_body(body)
  use response <- result.try(
    httpc.send(request) |> result.map_error(fn(_) { FetchError }),
  )
  case response.status {
    200 -> Ok(response.body)
    _ -> Error(FetchError)
  }
}
