import common/adventofcode/local_data
import common/adventofcode/website
import gleam/bool
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import html_parser
import simplifile
import tempo/datetime
import tempo/period

fn local_wrong_answers_file(year: Int, day: Int, part: Int) -> String {
  local_data.local_part_folder(year, day, part) <> "wrong_answers.txt"
}

fn local_correct_answer_file(year: Int, day: Int, part: Int) -> String {
  local_data.local_part_folder(year, day, part) <> "correct_answer.txt"
}

fn local_submission_time_file() -> String {
  local_data.local_data_folder() <> "last_submission_time.txt"
}

pub fn submit_answer(
  year: Int,
  day: Int,
  part: Int,
  answer: String,
) -> Result(Bool, website.AdventOfCodeError) {
  let is_known_wrong =
    get_known_wrong_answers(year, day, part) |> list.contains(answer)
  use <- bool.lazy_guard(is_known_wrong, fn() {
    io.println("Answer known to be wrong from previous submission.")
    Ok(False)
  })

  // check known correct answer file. compare against that.
  let is_known_correct = case
    get_known_correct_answer(year, day, part)
    |> result.map(fn(a) { a == answer })
  {
    Ok(a) -> Ok(a)
    Error(_) -> {
      // check known correct answer from website, write to correct answer file. compare against that.
      get_website_correct_answer(year, day, part)
      |> result.map(fn(a) {
        write_correct_answer_to_local_file(year, day, part, a)
        a == answer
      })
    }
  }
  use is_known_correct <- result.try(is_known_correct)
  use <- bool.lazy_guard(is_known_correct, fn() {
    io.println("Answer known to be correct from previous submission.")
    Ok(True)
  })

  // check one minute between submissions, sleep until minute is ended
  ensure_one_minute_between_submissions()
  // submit answer to AoC website. check if correct or wrong. if wrong, append to wrong answers file. if right, write to correct answer file.

  use is_correct_submitted <- result.try(submit_answer_to_website(
    year,
    day,
    part,
    answer,
  ))
  case is_correct_submitted {
    True -> {
      io.println("Submitted correct answer!!! :D")
      write_correct_answer_to_local_file(year, day, part, answer)
    }
    False -> {
      io.println("Submitted wrong answer :(")
      write_wrong_answer_to_local_file(year, day, part, answer)
    }
  }
  Ok(is_correct_submitted)
}

fn get_known_wrong_answers(year: Int, day: Int, part: Int) -> List(String) {
  case simplifile.read(local_wrong_answers_file(year, day, part)) {
    Error(_) -> []
    Ok(text) -> text |> string.trim |> string.split(on: "\n")
  }
}

fn get_known_correct_answer(
  year: Int,
  day: Int,
  part: Int,
) -> Result(String, Nil) {
  simplifile.read(local_correct_answer_file(year, day, part))
  |> result.nil_error
}

fn get_website_correct_answer(
  year: Int,
  day: Int,
  part: Int,
) -> Result(String, website.AdventOfCodeError) {
  use puzzle_html_text <- result.try(website.get_from_website(
    int.to_string(year) <> "/day/" <> int.to_string(day),
  ))
  let html = html_parser.as_list(puzzle_html_text)
  let answer_element =
    case part {
      1 -> html
      2 ->
        html
        |> list.drop_while(fn(element) {
          case element {
            html_parser.StartElement(
              "h2",
              [html_parser.Attribute("id", "part2")],
              _,
            ) -> False
            _ -> True
          }
        })
      _ -> panic
    }
    |> list.drop_while(fn(element) {
      case element {
        html_parser.Content("Your puzzle answer was") -> False
        _ -> True
      }
    })
    |> list.drop(2)
    |> list.first

  case answer_element {
    Ok(html_parser.Content(text)) -> Ok(text)
    _ -> Error(website.FetchError)
  }
}

fn ensure_one_minute_between_submissions() -> Nil {
  case simplifile.read(local_submission_time_file()) {
    Error(_) -> Nil
    Ok(time_string) ->
      case datetime.from_string(time_string) {
        Error(_) -> Nil
        Ok(last_submission_time) -> {
          let now = datetime.now_utc()
          let sleep_millis =
            {
              datetime.difference(now, last_submission_time)
              |> period.as_duration
            }.nanoseconds
            / 1000
          io.println(
            "Waiting "
            <> int.to_string({ sleep_millis / 1000 })
            <> " seconds before the next submission because of the 1 minute waiting period...",
          )
          process.sleep(sleep_millis)
        }
      }
  }
}

fn submit_answer_to_website(
  year: Int,
  day: Int,
  part: Int,
  answer: String,
) -> Result(Bool, website.AdventOfCodeError) {
  use html_string <- result.try(website.post_to_website(
    int.to_string(year) <> "/day/" <> int.to_string(day) <> "/answer",
    "level=" <> int.to_string(part) <> "&answer=" <> answer,
  ))
  let correct = html_string |> string.contains("That's the right answer")
  let wrong = html_string |> string.contains("That's not the right answer")
  case correct, wrong {
    True, False -> Ok(True)
    False, True -> {
      let assert Ok(#(_, second)) =
        html_string |> string.split_once("That's not the right answer")
      let assert Ok(#(first, _)) = second |> string.split_once(".")
      io.println("Wrong answer extra info: '" <> first <> "'")
      Ok(False)
    }
    _, _ -> Error(website.FetchError)
  }
}

fn write_wrong_answer_to_local_file(
  year: Int,
  day: Int,
  part: Int,
  answer: String,
) -> Nil {
  let date_str =
    "y"
    <> int.to_string(year)
    <> "d"
    <> int.to_string(day)
    <> "p"
    <> int.to_string(part)
  case
    simplifile.append(local_wrong_answers_file(year, day, part), answer <> "\n")
  {
    Error(_) ->
      io.println(
        "Failed to write wrong answer for " <> date_str <> " to local cache.",
      )
    Ok(_) ->
      io.println("Wrong answer for " <> date_str <> " written to local cache.")
  }
}

fn write_correct_answer_to_local_file(
  year: Int,
  day: Int,
  part: Int,
  answer: String,
) -> Nil {
  let date_str =
    "y"
    <> int.to_string(year)
    <> "d"
    <> int.to_string(day)
    <> "p"
    <> int.to_string(part)
  case simplifile.write(local_correct_answer_file(year, day, part), answer) {
    Error(_) ->
      io.println(
        "Failed to write correct answer for " <> date_str <> " to local cache.",
      )
    Ok(_) ->
      io.println(
        "Correct answer for " <> date_str <> " written to local cache.",
      )
  }
}
