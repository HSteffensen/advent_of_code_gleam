import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 19),
    solve_part_1,
    solve_part_2,
  )
}

type TowelProblem {
  TowelProblem(towels: List(String), patterns: List(String))
}

fn parse_input(input: String) -> TowelProblem {
  let assert Ok(#(towels, patterns)) =
    input |> string.trim |> string.split_once("\n\n")

  TowelProblem(
    towels: towels |> string.split(", "),
    patterns: patterns |> string.split("\n"),
  )
}

fn pattern_with_towels(pattern: String, towels: List(String)) -> Bool {
  use <- bool.guard(pattern == "", True)
  towels
  // |> io.debug
  |> list.filter(string.starts_with(pattern, _))
  // |> io.debug
  |> list.any(fn(towel) {
    pattern_with_towels(
      pattern |> string.drop_start(towel |> string.length),
      towels,
    )
  })
}

fn possible_towels(pattern: String, towels: List(String)) -> List(String) {
  towels
  |> list.filter(string.contains(pattern, _))
}

fn pattern_with_towels_2(
  pattern: String,
  towels: List(String),
  cache: Dict(String, Int),
) -> #(Int, Dict(String, Int)) {
  use <- bool.guard(pattern == "", #(1, cache))
  case cache |> dict.get(pattern) {
    Ok(cached_count) -> #(cached_count, cache)
    Error(Nil) -> {
      let #(sum, cache) =
        towels
        // |> io.debug
        |> list.filter(string.starts_with(pattern, _))
        // |> io.debug
        |> list.fold(#(0, cache), fn(acc, towel) {
          let #(subsum, cache) = acc
          let #(summand, cache) =
            pattern_with_towels_2(
              pattern |> string.drop_start(towel |> string.length),
              towels,
              cache,
            )
          #(subsum + summand, cache)
        })
      let cache = cache |> dict.insert(pattern, sum)
      #(sum, cache)
    }
  }
}

fn solve_part_1(input: String) -> String {
  let input = parse_input(input)
  input.patterns
  |> list.filter(fn(pattern) {
    pattern_with_towels(pattern, possible_towels(pattern, input.towels))
  })
  |> list.length
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  let input = parse_input(input)
  input.patterns
  |> list.map(fn(pattern) {
    let #(count, _) =
      pattern_with_towels_2(
        pattern,
        possible_towels(pattern, input.towels),
        dict.new(),
      )
    count
  })
  |> int.sum
  |> int.to_string
}
