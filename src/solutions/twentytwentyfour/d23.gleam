import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/set.{type Set}
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 23),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> List(#(String, String)) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(a, b)) = line |> string.split_once("-")
    sort_pair(#(a, b))
  })
}

fn sort_pair(pair: #(String, String)) -> #(String, String) {
  let #(a, b) = pair
  let assert [a, b] = [a, b] |> list.sort(string.compare)
  #(a, b)
}

fn sort_triple(triple: #(String, String, String)) -> #(String, String, String) {
  let #(a, b, c) = triple
  let assert [a, b, c] = [a, b, c] |> list.sort(string.compare)
  #(a, b, c)
}

type ConnectionStartingWithT {
  ConnectionStartingWithT(t: String, other: String)
}

fn triples_containing_t(
  pairs: List(#(String, String)),
) -> List(#(String, String, String)) {
  let pairs_set = pairs |> set.from_list
  let pairs_containing_t =
    pairs
    |> list.filter_map(fn(p) {
      let #(a, b) = p
      case a |> string.starts_with("t"), b |> string.starts_with("t") {
        True, True -> Ok(ConnectionStartingWithT(a, b))
        True, False -> Ok(ConnectionStartingWithT(a, b))
        False, True -> Ok(ConnectionStartingWithT(b, a))
        False, False -> Error(Nil)
      }
    })
    |> list.group(fn(p) { p.t })
  pairs_containing_t
  |> dict.to_list
  |> list.flat_map(fn(entry) {
    let #(t, connections) = entry
    connections
    |> list.map(fn(c) { c.other })
    |> list.combination_pairs
    |> list.map(sort_pair)
    |> list.filter(set.contains(pairs_set, _))
    |> list.map(fn(p) {
      let #(a, b) = p
      sort_triple(#(t, a, b))
    })
  })
}

fn solve_part_1(input: String) -> String {
  parse_input(input)
  |> triples_containing_t
  |> list.length
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  todo
}
