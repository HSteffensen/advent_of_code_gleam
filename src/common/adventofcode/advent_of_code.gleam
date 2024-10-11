import common/adventofcode/auth
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
  let request = request.set_cookie(r, "session", session)
  use response <- result.try(
    httpc.send(request) |> result.map_error(fn(_) { FetchError }),
  )
  case response.status {
    200 -> Ok(response.body)
    _ -> Error(FetchError)
  }
}
