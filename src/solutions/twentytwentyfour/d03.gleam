import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 3),
    solve_part_1,
    solve_part_2,
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
          #(True, MulInstruction(a_int, b_int))
        }
        True, regexp.Match("don't()", _) -> #(False, MulInstruction(0, 0))
        _, regexp.Match("do()", _) -> #(True, MulInstruction(0, 0))
        False, _ -> #(False, MulInstruction(0, 0))
        _, _ -> panic as "unreachable"
      }
    })
  parsed
}

fn solve_part_2(input: String) -> String {
  parse_input_2(input) |> list.map(mul) |> int.sum |> int.to_string
}
