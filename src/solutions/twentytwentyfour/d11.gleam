import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/bool
import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 11),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> List(Int) {
  input
  |> string.trim
  |> string.split(" ")
  |> list.filter(fn(x) { x != "" })
  |> list.map(fn(x) {
    let assert Ok(x) = int.parse(x)
    x
  })
}

fn next_stone(x: Int) -> List(Int) {
  use <- bool.guard(x == 0, [1])
  let x_str = int.to_string(x)
  let x_length = string.length(x_str)
  let assert Ok(x_tens_half) =
    int.power(10, int.to_float(x_length / 2)) |> result.map(float.round)
  case x_length % 2 {
    0 -> [x / x_tens_half, x % x_tens_half]
    1 -> [x * 2024]
    _ -> panic as "unreachable"
  }
}

fn blink(stones: List(Int), blinks_remaining: Int) -> List(Int) {
  case blinks_remaining {
    0 -> stones
    _ ->
      stones
      |> list.map(next_stone)
      |> list.map(blink(_, blinks_remaining - 1))
      |> list.flatten
  }
}

fn solve_part_1(input: String) -> String {
  parse_input(input) |> blink(25) |> list.length |> int.to_string
}

fn solve_part_2(input: String) -> String {
  todo
}
