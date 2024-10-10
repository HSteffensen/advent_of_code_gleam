import common/adventofcode/local_data
import gleam/erlang
import gleam/http/request
import gleam/httpc
import gleam/io
import gleam/result
import gleam/string
import simplifile

fn local_session_file() -> String {
  local_data.local_data_folder() <> "session_cookie.txt"
}

pub type SessionCookieError {
  SessionCookieError
}

pub fn get_session_or_ask_human() -> Result(String, SessionCookieError) {
  get_session_from_local_file()
  |> result.then(check_session)
  |> result.lazy_or(fn() {
    get_session_from_human_input()
    |> result.then(check_session)
    |> result.map(fn(s) {
      write_session_to_local_file(s)
      s
    })
  })
  |> result.map(string.trim)
  |> result.map_error(fn(_) { SessionCookieError })
}

fn get_session_from_local_file() -> Result(String, Nil) {
  simplifile.read(local_session_file()) |> result.nil_error
}

fn write_session_to_local_file(session: String) -> Nil {
  local_data.create_local_data_folder_if_not_exists()
  case simplifile.write(local_session_file(), session) {
    Error(_) ->
      io.println("Failed to write to local cache. You might need to try again.")
    Ok(_) ->
      io.println(
        "Session cookie written to local cache, and will be used in the future.",
      )
  }
}

fn get_session_from_human_input() -> Result(String, Nil) {
  erlang.get_line(
    "Session cookie missing or invalid. Go to `https://adventofcode.com` and use browser tools to get the session cookie, then paste here:\n",
  )
  |> result.nil_error
}

fn check_session(session: String) -> Result(String, Nil) {
  let assert Ok(r) = request.to("https://adventofcode.com/2018/day/1/input")
  let request = request.set_cookie(r, "session", session)
  use response <- result.try(httpc.send(request) |> result.nil_error)
  case response.status {
    200 -> Ok(session)
    _ -> Error(Nil)
  }
}
