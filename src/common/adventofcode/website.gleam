import common/adventofcode/advent_of_code
import common/adventofcode/auth
import common/adventofcode/local_data
import gleam/bool
import gleam/erlang/process
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/order
import gleam/result
import simplifile
import tempo/date
import tempo/datetime
import tempo/duration
import tempo/time

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
  ensure_time_between_submissions()
  write_submission_time()
  use _ <- result.try(Ok(""))
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
  use response <- result.try(
    httpc.send(request) |> result.map_error(fn(_) { FetchError }),
  )
  write_submission_time()
  case response.status {
    200 -> Ok(response.body)
    _ -> Error(FetchError)
  }
}

fn ensure_time_between_submissions() -> Nil {
  case simplifile.read(local_submission_time_file()) {
    Error(_) -> Nil
    Ok(time_string) ->
      case datetime.from_string(time_string) {
        Error(_) -> Nil
        Ok(last_submission_time) -> {
          let now = datetime.now_utc()
          use <- bool.guard(
            date.compare(
              last_submission_time |> datetime.get_date,
              now |> datetime.get_date,
            )
              != order.Eq,
            Nil,
          )
          let time_since_submission =
            time.difference(
              last_submission_time |> datetime.get_time,
              now |> datetime.get_time,
            )
          let waiting_period = duration.seconds(61)
          let sleep_millis =
            duration.decrease(waiting_period, time_since_submission)
            |> duration.as_milliseconds
          case sleep_millis > 0 {
            False -> Nil
            True -> {
              io.println(
                "Waiting "
                <> int.to_string({ sleep_millis / 1000 })
                <> " seconds before the next submission because of the waiting period...",
              )
              process.sleep(sleep_millis)
            }
          }
        }
      }
  }
}

fn write_submission_time() -> Nil {
  simplifile.write(
    local_submission_time_file(),
    datetime.now_utc() |> datetime.to_string,
  )
  |> result.unwrap(Nil)
}

fn local_submission_time_file() -> String {
  local_data.local_data_folder() <> "last_submission_time.txt"
}
