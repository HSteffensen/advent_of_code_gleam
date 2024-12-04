import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/util
import gleam/function
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 4),
    solve_part_1,
    solve_part_2,
  )
}

fn solve_part_1(input: String) -> String {
  let input = input |> string.trim
  let horizontal =
    input |> string.split("\n") |> list.map(count_xmas) |> int.sum

  let diagonal =
    down_diagonals(input)
    |> list.append(down_diagonals(
      input
      |> string.split("\n")
      |> list.map(string.reverse)
      |> string.join("\n"),
    ))
    |> list.map(count_xmas)
    |> int.sum

  let vertical =
    input
    |> string.split("\n")
    |> list.map(string.to_graphemes)
    |> list.transpose
    |> list.map(string.join(_, ""))
    |> list.map(count_xmas)
    |> int.sum
  horizontal + diagonal + vertical |> int.to_string
}

fn down_diagonals(input: String) -> List(String) {
  let lines = input |> string.split("\n") |> list.map(string.to_graphemes)
  let assert Ok(width) = lines |> list.first |> result.map(list.length)
  let height = list.length(lines)
  let from_left =
    list.range(0, height - 1)
    |> list.map(fn(i) {
      list.range(i, height - 1)
      |> list.zip(list.range(0, width - 1))
      |> list.map(fn(yx) {
        let #(y, x) = yx
        let assert Ok(line) = lines |> list.drop(y) |> list.first
        let assert Ok(c) = line |> list.drop(x) |> list.first
        c
      })
      |> string.join("")
    })

  let from_top =
    list.range(1, width - 1)
    |> list.map(fn(i) {
      list.range(i, width - 1)
      |> list.zip(list.range(0, height - 1))
      |> list.map(fn(xy) {
        let #(x, y) = xy
        let assert Ok(line) = lines |> list.drop(y) |> list.first
        let assert Ok(c) = line |> list.drop(x) |> list.first
        c
      })
      |> string.join("")
    })

  list.append(from_left, from_top)
}

fn count_xmas(input: String) -> Int {
  let assert Ok(re) = regexp.from_string("XMAS")
  let assert Ok(re2) = regexp.from_string("SAMX")
  regexp.scan(re, input) |> list.append(regexp.scan(re2, input)) |> list.length
}

fn solve_part_2(input: String) -> String {
  let input = input |> string.split("\n") |> list.map(string.to_graphemes)
  input
  |> list.index_map(fn(line, y) {
    line
    |> list.index_map(fn(_, x) { check_x_mas(input, x, y) })
  })
  |> list.flatten
  |> list.filter(function.identity)
  |> list.length
  |> int.to_string
}

fn check_x_mas(input: List(List(String)), x: Int, y: Int) -> Bool {
  let at_pos = input |> list.drop(y) |> list.map(list.drop(_, x))
  use first_line <- util.result_guard(at_pos |> list.first, False)
  use first_char <- util.result_guard(first_line |> list.first, False)
  use third_char <- util.result_guard(
    first_line |> list.drop(2) |> list.first,
    False,
  )
  use second_line <- util.result_guard(
    at_pos |> list.drop(1) |> list.first,
    False,
  )
  use fifth_char <- util.result_guard(
    second_line |> list.drop(1) |> list.first,
    False,
  )
  use third_line <- util.result_guard(
    at_pos |> list.drop(2) |> list.first,
    False,
  )
  use seventh_char <- util.result_guard(third_line |> list.first, False)
  use ninth_char <- util.result_guard(
    third_line |> list.drop(2) |> list.first,
    False,
  )
  case first_char, third_char, fifth_char, seventh_char, ninth_char {
    "M", "M", "A", "S", "S" -> True
    "M", "S", "A", "M", "S" -> True
    "S", "M", "A", "S", "M" -> True
    "S", "S", "A", "M", "M" -> True
    _, _, _, _, _ -> False
  }
}
