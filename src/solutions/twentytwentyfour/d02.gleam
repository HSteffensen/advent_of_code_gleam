import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/int
import gleam/list
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 2),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> List(List(Int)) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.trim
    |> string.split(" ")
    |> list.map(fn(a) {
      let assert Ok(b) = int.parse(a)
      b
    })
  })
}

fn solve_part_1(input: String) -> String {
  parse_input(input)
  |> list.map(fn(line) {
    case
      line |> strictly_increasing_by_at_most(3)
      || line |> list.reverse |> strictly_increasing_by_at_most(3)
    {
      False -> 0
      True -> 1
    }
  })
  |> int.sum
  |> int.to_string
}

fn strictly_increasing_by_at_most(l: List(Int), jump_max: Int) -> Bool {
  l
  |> list.window_by_2
  |> list.fold(True, fn(acc, p) {
    let #(a, b) = p
    acc && a < b && b - a <= jump_max
  })
}

fn solve_part_2(input: String) -> String {
  parse_input(input)
  |> list.map(fn(line) {
    case
      line
      |> each_removed
      |> list.any(fn(line_removed) {
        line_removed |> strictly_increasing_by_at_most(3)
        || line_removed
        |> list.reverse
        |> strictly_increasing_by_at_most(3)
      })
    {
      False -> 0
      True -> 1
    }
  })
  |> int.sum
  |> int.to_string
}

fn each_removed(l: List(t)) -> List(List(t)) {
  list.range(0, list.length(l))
  |> list.map(fn(i) {
    l
    |> list.index_map(fn(x, j) { #(j, x) })
    |> list.filter_map(fn(x) {
      let #(j, x) = x
      case j == i {
        False -> Ok(x)
        True -> Error(Nil)
      }
    })
  })
}
