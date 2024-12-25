import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 25),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> #(List(List(Int)), List(List(Int))) {
  let #(locks, keys) =
    input
    |> string.trim
    |> string.split("\n\n")
    |> list.map(fn(line) {
      let assert Ok(#(first, rest)) = line |> string.split_once("\n")
      #(rest, case first {
        "#####" -> True
        "....." -> False
        _ -> panic as "unexpected lock kind"
      })
    })
    |> list.partition(fn(p) {
      let #(_, is_lock) = p
      is_lock
    })
  let locks =
    locks
    |> list.map(fn(lock) {
      let #(lock, _) = lock
      lock
      |> string.split("\n")
      |> list.map(string.to_graphemes)
      |> list.transpose
      |> list.map(fn(line) {
        line |> list.take_while(fn(c) { c == "#" }) |> list.length
      })
    })
  let keys =
    keys
    |> list.map(fn(key) {
      let #(key, _) = key
      key
      |> string.split("\n")
      |> list.map(string.to_graphemes)
      |> list.transpose
      |> list.map(fn(line) {
        5 - { line |> list.take_while(fn(c) { c == "." }) |> list.length }
      })
    })
  #(locks, keys)
}

fn lock_fits_key(lock: List(Int), key: List(Int)) -> Bool {
  list.zip(lock, key)
  |> list.all(fn(p) {
    let #(a, b) = p
    { a + b } <= 5
  })
}

fn solve_part_1(input: String) -> String {
  let #(locks, keys) = parse_input(input)
  locks
  |> list.map(fn(lock) { keys |> list.count(lock_fits_key(lock, _)) })
  |> int.sum
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  todo
}
