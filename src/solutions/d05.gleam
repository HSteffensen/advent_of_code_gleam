import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2018, 5),
    solve_part_1,
    solve_part_2,
  )
}

type Particle {
  Upper(String)
  Lower(String)
}

fn parse_input(input: String) -> List(Particle) {
  input
  |> string.trim
  |> string.to_graphemes
  |> list.map(fn(c) {
    let lower = string.lowercase(c)
    case lower == c {
      False -> Upper(lower)
      True -> Lower(lower)
    }
  })
}

fn particle_string(output: List(Particle)) -> String {
  output
  |> list.map(fn(p) {
    case p {
      Lower(c) -> c
      Upper(c) -> string.uppercase(c)
    }
  })
  |> string.concat
}

fn solve_part_1(input: String) -> String {
  input |> parse_input |> part_1_full |> list.length |> int.to_string
}

fn part_1_full(input: List(Particle)) -> List(Particle) {
  let processed = part_1_single_pass(input, list.new())
  case input == processed {
    False -> part_1_full(processed)
    True -> processed
  }
}

fn part_1_single_pass(
  remaining: List(Particle),
  head: List(Particle),
) -> List(Particle) {
  case remaining {
    [] -> head |> list.reverse
    [Upper(a), Lower(b), ..rest] | [Lower(a), Upper(b), ..rest] if a == b ->
      part_1_single_pass(rest, head)
    [first, ..rest] -> part_1_single_pass(rest, [first, ..head])
  }
}

fn solve_part_2(input: String) -> String {
  todo
}
