import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/int
import gleam/list
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 1),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> List(#(Int, Int)) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(a, b)) = line |> string.split_once("   ")
    let assert Ok(a_int) = int.parse(a)
    let assert Ok(b_int) = int.parse(b)
    #(a_int, b_int)
  })
}

fn solve_part_1(input: String) -> String {
  let #(list1, list2) = parse_input(input) |> list.unzip
  list1
  |> list.sort(int.compare)
  |> list.zip(
    list2
    |> list.sort(int.compare),
  )
  |> list.map(fn(x) {
    let #(a, b) = x
    int.absolute_value(a - b)
  })
  |> int.sum
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  let #(list1, list2) = parse_input(input) |> list.unzip
  list1
  |> list.map(fn(a) {
    list2
    |> list.map(fn(b) {
      case a == b {
        True -> a
        False -> 0
      }
    })
    |> int.sum
  })
  |> int.sum
  |> int.to_string
}
