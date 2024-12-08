import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/int
import gleam/list
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 7),
    solve_part_1,
    solve_part_2,
  )
}

type CalibrationEquation {
  CalibrationEquation(test_value: Int, operands: List(Int))
}

fn parse_input(input: String) -> List(CalibrationEquation) {
  input |> string.trim |> string.split("\n") |> list.map(parse_line)
}

fn parse_line(line: String) -> CalibrationEquation {
  let assert Ok(#(first, rest)) = line |> string.split_once(": ")
  let assert Ok(test_value) = first |> int.parse
  let operands =
    rest
    |> string.split(" ")
    |> list.map(fn(a) {
      let assert Ok(b) = int.parse(a)
      b
    })
  CalibrationEquation(test_value, operands)
}

fn all_possible_operations(operands: List(Int)) -> List(Int) {
  case operands {
    [_] -> operands
    [a, ..rest] -> {
      let next = all_possible_operations(rest)
      next
      |> list.map(int.multiply(a, _))
      |> list.append(next |> list.map(int.add(a, _)))
    }
    [] -> panic as "unreachable"
  }
}

fn all_possible_operations_2(operands: List(Int)) -> List(Int) {
  case operands {
    [_] -> operands
    [a, ..rest] -> {
      let next = all_possible_operations_2(rest)
      next
      |> list.map(int.multiply(a, _))
      |> list.append(next |> list.map(int.add(a, _)))
      |> list.append(
        next
        |> list.map(fn(b) {
          let assert Ok(c) = int.parse(int.to_string(b) <> int.to_string(a))
          c
        }),
      )
    }
    [] -> panic as "unreachable"
  }
}

fn solve_part_1(input: String) -> String {
  parse_input(input)
  |> list.filter(fn(equation) {
    all_possible_operations(equation.operands |> list.reverse)
    |> list.contains(equation.test_value)
  })
  |> list.map(fn(equation) { equation.test_value })
  |> int.sum
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  parse_input(input)
  |> list.filter(fn(equation) {
    all_possible_operations_2(equation.operands |> list.reverse)
    |> list.contains(equation.test_value)
  })
  |> list.map(fn(equation) { equation.test_value })
  |> int.sum
  |> int.to_string
}
