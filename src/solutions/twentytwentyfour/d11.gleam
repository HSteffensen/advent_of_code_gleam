import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/bool
import gleam/dict
import gleam/float
import gleam/int
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

fn blink_stone_count(
  stone: Int,
  blinks_remaining: Int,
  cache: dict.Dict(#(Int, Int), Int),
) -> #(dict.Dict(#(Int, Int), Int), Int) {
  use <- bool.guard(blinks_remaining == 0, #(cache, 1))
  case cache |> dict.get(#(stone, blinks_remaining)) {
    Ok(count) -> #(cache, count)
    Error(Nil) -> {
      let #(cache, counts) =
        next_stone(stone)
        |> list.map_fold(cache, fn(cache, new_stone) {
          blink_stone_count(new_stone, blinks_remaining - 1, cache)
        })
      let count = counts |> int.sum
      let cache = cache |> dict.insert(#(stone, blinks_remaining), count)
      #(cache, count)
    }
  }
}

fn blink_count_stones(stones: List(Int), blinks: Int) -> Int {
  let #(_, counts) =
    stones
    |> list.map_fold(dict.new(), fn(cache, stone) {
      blink_stone_count(stone, blinks, cache)
    })
  counts |> int.sum
}

fn solve_part_1(input: String) -> String {
  parse_input(input) |> blink_count_stones(25) |> int.to_string
}

fn solve_part_2(input: String) -> String {
  parse_input(input) |> blink_count_stones(75) |> int.to_string
}
