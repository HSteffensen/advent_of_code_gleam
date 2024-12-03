import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/bool
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string

pub fn main() {
  use _ <- result.try(solution.solve_advent(
    advent_of_code.PuzzleId(2024, 3),
    solve_part_1,
    solve_part_2,
  ))
  // trying out solving without regex just to see what it's like
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 3),
    solve_part_1_no_regex,
    solve_part_2_no_regex,
  )
}

type MulInstruction {
  MulInstruction(a: Int, b: Int)
}

fn mul(mul_instruction: MulInstruction) -> Int {
  mul_instruction.a * mul_instruction.b
}

fn parse_input(input: String) -> List(MulInstruction) {
  let assert Ok(mul_regex) =
    regexp.compile(
      "mul\\((\\d+),(\\d+)\\)",
      regexp.Options(case_insensitive: True, multi_line: True),
    )

  regexp.scan(mul_regex, input)
  |> list.map(fn(match) {
    let assert regexp.Match(_, [option.Some(a), option.Some(b)]) = match
    let assert Ok(a_int) = int.parse(a)
    let assert Ok(b_int) = int.parse(b)
    MulInstruction(a_int, b_int)
  })
}

fn solve_part_1(input: String) -> String {
  parse_input(input) |> list.map(mul) |> int.sum |> int.to_string
}

fn parse_input_2(input: String) -> List(MulInstruction) {
  let assert Ok(mul_regex) =
    regexp.compile(
      "mul\\((\\d+),(\\d+)\\)|do\\(\\)|don't\\(\\)",
      regexp.Options(case_insensitive: True, multi_line: True),
    )

  let #(_, parsed) =
    regexp.scan(mul_regex, input)
    |> list.map_fold(True, fn(enabled, match) {
      case enabled, match {
        True, regexp.Match(_, [option.Some(a), option.Some(b)]) -> {
          let assert Ok(a_int) = int.parse(a)
          let assert Ok(b_int) = int.parse(b)
          #(True, Ok(MulInstruction(a_int, b_int)))
        }
        _, regexp.Match("don't()", _) -> #(False, Error(Nil))
        _, regexp.Match("do()", _) -> #(True, Error(Nil))
        False, _ -> #(False, Error(Nil))
        _, _ -> panic as "unreachable"
      }
    })
  parsed |> result.values
}

fn solve_part_2(input: String) -> String {
  parse_input_2(input) |> list.map(mul) |> int.sum |> int.to_string
}

fn solve_part_1_no_regex(input: String) -> String {
  parse_input_no_regex(input) |> list.map(mul) |> int.sum |> int.to_string
}

fn solve_part_2_no_regex(input: String) -> String {
  parse_input_no_regex_2(input) |> list.map(mul) |> int.sum |> int.to_string
}

fn parse_input_no_regex(input: String) -> List(MulInstruction) {
  let length = string.length(input)
  let input_list = input |> string.to_graphemes
  list.range(0, length)
  |> list.filter_map(fn(i) { parse_mul_instruction(input_list |> list.drop(i)) })
}

fn parse_mul_instruction(input: List(String)) -> Result(MulInstruction, Nil) {
  use <- bool.guard(
    case input {
      ["m", "u", "l", "(", ..] -> False
      _ -> True
    },
    Error(Nil),
  )
  let inner =
    input
    |> list.drop(4)
    |> list.take_while(fn(c) { c != ")" })
    |> string.join("")
  use #(first, second) <- result.try(inner |> string.split_once(","))
  use a <- result.try(int.parse(first))
  use b <- result.try(int.parse(second))
  Ok(MulInstruction(a, b))
}

fn parse_input_no_regex_2(input: String) -> List(MulInstruction) {
  let length = string.length(input)
  let input_list = input |> string.to_graphemes
  let #(_, parsed) =
    list.range(0, length)
    |> list.map_fold(True, fn(enabled, i) {
      let li = input_list |> list.drop(i)
      case enabled, parse_mul_instruction(li), parse_do(li), parse_dont(li) {
        True, Ok(mul), False, False -> #(True, Ok(mul))
        False, Error(_), True, False -> #(True, Error(Nil))
        True, Error(_), False, True -> #(False, Error(Nil))
        e, _, _, _ -> #(e, Error(Nil))
      }
    })
  parsed |> result.values
}

fn parse_do(input: List(String)) -> Bool {
  case input {
    ["d", "o", "(", ")", ..] -> True
    _ -> False
  }
}

fn parse_dont(input: List(String)) -> Bool {
  case input {
    ["d", "o", "n", "'", "t", "(", ")", ..] -> True
    _ -> False
  }
}
