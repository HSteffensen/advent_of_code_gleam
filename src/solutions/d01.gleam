import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2018, 1),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> List(Int) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(int.parse)
  |> list.map(fn(i) {
    let assert Ok(v) = i
    v
  })
}

fn solve_part_1(input: String) -> String {
  input
  |> parse_input
  |> int.sum
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  input |> parse_input |> part_2_helper(0, set.new()) |> int.to_string
}

fn part_2_helper(input: List(Int), frequency: Int, visited: Set(Int)) -> Int {
  let #(frequency, visited) =
    input
    |> list.fold_until(#(frequency, visited), fn(acc, change) {
      let #(freq, vis) = acc
      case set.contains(vis, freq) {
        True -> list.Stop(#(freq, vis))
        False -> list.Continue(#(freq + change, vis |> set.insert(freq)))
      }
    })
  case set.contains(visited, frequency) {
    False -> part_2_helper(input, frequency, visited)
    True -> frequency
  }
}
