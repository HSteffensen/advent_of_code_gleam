import common/adventofcode/advent_of_code.{type PuzzleId, type PuzzlePart}
import common/adventofcode/local_data
import common/adventofcode/website
import gleam/bool
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import html_parser
import simplifile

fn local_wrong_answers_file(puzzle: PuzzleId, part: PuzzlePart) -> String {
  local_data.local_part_folder(puzzle, part) <> "wrong_answers.txt"
}

fn local_correct_answer_file(puzzle: PuzzleId, part: PuzzlePart) -> String {
  local_data.local_part_folder(puzzle, part) <> "correct_answer.txt"
}

pub fn submit_answer(
  puzzle: PuzzleId,
  part: PuzzlePart,
  answer: String,
) -> Result(Bool, website.AdventOfCodeError) {
  let is_known_wrong =
    get_known_wrong_answers(puzzle, part) |> list.contains(answer)
  use <- bool.lazy_guard(is_known_wrong, fn() {
    io.println("Answer known to be wrong from previous submission.")
    Ok(False)
  })

  // check known correct answer file. compare against that.
  let is_known_correct = case
    get_known_correct_answer(puzzle, part)
    |> result.map(fn(a) { a == answer })
  {
    Ok(a) -> Ok(option.Some(a))
    Error(_) -> {
      // check known correct answer from website, write to correct answer file. compare against that.
      get_website_correct_answer(puzzle, part)
      |> result.map(fn(a) {
        case a {
          option.None -> option.None
          option.Some(b) -> {
            write_correct_answer_to_local_file(puzzle, part, b)
            option.Some(b == answer)
          }
        }
      })
    }
  }
  use is_known_correct <- result.try(
    is_known_correct
    |> result.map_error(fn(e) {
      io.println("Failed to get the correct answer.")
      e
    }),
  )

  use <- bool.lazy_guard(is_known_correct |> option.is_some, fn() {
    io.println("Answer known to be correct from previous submission.")
    Ok(is_known_correct |> option.unwrap(True))
  })

  // submit answer to AoC website. check if correct or wrong. if wrong, append to wrong answers file. if right, write to correct answer file.

  use is_correct_submitted <- result.try(
    submit_answer_to_website(puzzle, part, answer)
    |> result.map_error(fn(e) {
      io.println("Failed to submit answer to website.")
      e
    }),
  )
  case is_correct_submitted {
    True -> {
      io.println("Submitted correct answer!!! :D")
      write_correct_answer_to_local_file(puzzle, part, answer)
    }
    False -> {
      io.println("Submitted wrong answer :(")
      write_wrong_answer_to_local_file(puzzle, part, answer)
    }
  }
  Ok(is_correct_submitted)
}

fn get_known_wrong_answers(puzzle: PuzzleId, part: PuzzlePart) -> List(String) {
  case simplifile.read(local_wrong_answers_file(puzzle, part)) {
    Error(_) -> []
    Ok(text) -> text |> string.trim |> string.split(on: "\n")
  }
}

fn get_known_correct_answer(
  puzzle: PuzzleId,
  part: PuzzlePart,
) -> Result(String, Nil) {
  simplifile.read(local_correct_answer_file(puzzle, part))
  |> result.replace_error(Nil)
}

fn get_website_correct_answer(
  puzzle: PuzzleId,
  part: PuzzlePart,
) -> Result(option.Option(String), website.AdventOfCodeError) {
  use puzzle_html_text <- result.try(
    website.get_from_website(advent_of_code.day_path(puzzle))
    |> result.map_error(fn(e) {
      io.println("Failed to get puzzle text.")
      e
    }),
  )
  let html = html_parser.as_list(puzzle_html_text)
  let answer_element =
    case part {
      advent_of_code.Part1 -> html
      advent_of_code.Part2 ->
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
    }
    |> list.drop_while(fn(element) {
      case element {
        html_parser.Content("Your puzzle answer was ") -> False
        _ -> True
      }
    })
    |> list.drop(2)
    |> list.first

  Ok(case answer_element {
    Ok(html_parser.Content(text)) -> option.Some(text)
    _ -> option.None
  })
}

fn submit_answer_to_website(
  puzzle: PuzzleId,
  part: PuzzlePart,
  answer: String,
) -> Result(Bool, website.AdventOfCodeError) {
  use html_string <- result.try(website.post_answer(puzzle, part, answer))
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
  puzzle: PuzzleId,
  part: PuzzlePart,
  answer: String,
) -> Nil {
  let date_str =
    advent_of_code.day_string(puzzle)
    <> "p"
    <> advent_of_code.part_int_string(part)
  case
    simplifile.append(local_wrong_answers_file(puzzle, part), answer <> "\n")
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
  puzzle: PuzzleId,
  part: PuzzlePart,
  answer: String,
) -> Nil {
  let date_str =
    advent_of_code.day_string(puzzle)
    <> "p"
    <> advent_of_code.part_int_string(part)
  case simplifile.write(local_correct_answer_file(puzzle, part), answer) {
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
