import common/adventofcode/local_data
import common/adventofcode/website
import gleam/erlang
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import html_parser
import simplifile

pub type PuzzleExample {
  PuzzleExample(number: Int, input: String, answer: String)
}

fn local_example_input_file(
  year: Int,
  day: Int,
  part: Int,
  number: Int,
) -> String {
  local_data.local_part_folder(year, day, part)
  <> "example_"
  <> int.to_string(number)
  <> "_input.txt"
}

fn local_example_answer_file(
  year: Int,
  day: Int,
  part: Int,
  number: Int,
) -> String {
  local_data.local_part_folder(year, day, part)
  <> "example_"
  <> int.to_string(number)
  <> "_answer.txt"
}

pub fn get_examples_or_ask_human(
  year: Int,
  day: Int,
  part: Int,
) -> Result(List(PuzzleExample), website.AdventOfCodeError) {
  let examples = collect_examples_from_local_files(year, day, part, 1, [])
  case examples {
    [] -> {
      get_examples_from_website_and_human(year, day, part)
      |> result.map(fn(l) {
        write_examples_to_local_file(year, day, part, l)
        l
      })
    }
    [_, ..] -> Ok(examples)
  }
}

fn collect_examples_from_local_files(
  year: Int,
  day: Int,
  part: Int,
  number: Int,
  collected: List(PuzzleExample),
) -> List(PuzzleExample) {
  let input = simplifile.read(local_example_input_file(year, day, part, number))
  let answer =
    simplifile.read(local_example_answer_file(year, day, part, number))
  case input, answer {
    Ok(i), Ok(a) ->
      collect_examples_from_local_files(year, day, part, number + 1, [
        PuzzleExample(number, i, a),
        ..collected
      ])
    Error(_), Error(_) -> collected
    _, _ -> {
      io.println_error(
        "Example "
        <> int.to_string(number)
        <> " for y"
        <> int.to_string(year)
        <> "d"
        <> int.to_string(day)
        <> " is messed up.",
      )
      collected
    }
  }
}

fn write_examples_to_local_file(
  year: Int,
  day: Int,
  part: Int,
  examples: List(PuzzleExample),
) -> Nil {
  let date_str = "y" <> int.to_string(year) <> "d" <> int.to_string(day)
  local_data.create_local_part_folder_if_not_exists(year, day, part)
  let success =
    examples
    |> list.all(fn(example) {
      let PuzzleExample(number, input, answer) = example
      let wrote_input =
        simplifile.write(
          local_example_input_file(year, day, part, number),
          input,
        )
        |> result.is_ok
      let wrote_answer =
        simplifile.write(
          local_example_answer_file(year, day, part, number),
          answer,
        )
        |> result.is_ok
      wrote_input && wrote_answer
    })
  case success {
    False ->
      io.println(
        "Failed to write puzzle examples for " <> date_str <> " to local cache.",
      )
    True ->
      io.println(
        "Puzzle examples for "
        <> date_str
        <> " written to local cache, and will be used in the future.",
      )
  }
}

fn get_examples_from_website_and_human(
  year: Int,
  day: Int,
  part: Int,
) -> Result(List(PuzzleExample), website.AdventOfCodeError) {
  use puzzle_html_text <- result.try(website.get_from_website(
    int.to_string(year) <> "/day/" <> int.to_string(day),
  ))
  let example_candidates =
    html_parser.as_list(puzzle_html_text)
    |> find_code_blocks_text(part)
  let example_candidates = case part {
    1 -> example_candidates
    2 ->
      list.append(
        get_examples_or_ask_human(year, day, 1)
          |> result.unwrap([])
          |> list.map(fn(e) { e.input }),
        example_candidates,
      )
    _ -> panic
  }
  let #(_, examples) =
    example_candidates
    |> list.filter_map(fn(candidate) {
      case
        erlang.get_line(
          "Possible example found:\n"
          <> candidate
          <> "\nIf this is an example, paste the corresponding correct answer. Else, press 'Enter':",
        )
      {
        Ok(answer) -> {
          let answer = string.trim(answer)
          case answer {
            "" -> Error(Nil)
            _ -> Ok(#(candidate, answer))
          }
        }
        Error(_) -> Error(Nil)
      }
    })
    |> list.map_fold(1, fn(n, m) {
      let #(i, a) = m
      #(n + 1, PuzzleExample(n, i, a))
    })
  Ok(examples)
}

fn find_code_blocks_text(
  elements: List(html_parser.Element),
  part: Int,
) -> List(String) {
  let elements_after_day_description =
    elements
    |> list.drop_while(fn(e) {
      case e, part {
        html_parser.StartElement("h2", _, _), 1 -> False
        html_parser.StartElement(
          "h2",
          [html_parser.Attribute("id", "part2")],
          _,
        ),
          2
        -> False
        _, _ -> True
      }
    })
    |> list.drop(1)
  find_code_blocks_text_helper(elements_after_day_description, [])
}

fn find_code_blocks_text_helper(
  elements: List(html_parser.Element),
  found: List(String),
) -> List(String) {
  case elements {
    [
      html_parser.StartElement("pre", _, _),
      html_parser.StartElement("code", _, _),
      html_parser.Content(text),
      ..rest
    ] -> find_code_blocks_text_helper(rest, [text, ..found])
    [
      html_parser.StartElement("h2", [html_parser.Attribute("id", "part2")], _),
      ..
    ]
    | [] -> found |> list.reverse
    [_, ..rest] -> find_code_blocks_text_helper(rest, found)
  }
}
