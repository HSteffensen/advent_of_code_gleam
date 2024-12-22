import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 22),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> List(Int) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(s) = int.parse(line)
    s
  })
}

fn next_secret(secret: Int) -> Int {
  let secret = int.bitwise_exclusive_or(secret, secret * 64) % 16_777_216
  let secret = int.bitwise_exclusive_or(secret, secret / 32) % 16_777_216
  int.bitwise_exclusive_or(secret, secret * 2048) % 16_777_216
}

fn nth_secret(secret: Int, n: Int) -> Int {
  case n {
    0 -> secret
    _ -> nth_secret(next_secret(secret), n - 1)
  }
}

fn change_sequence_gains(
  initial_secret: Int,
) -> Dict(#(Int, Int, Int, Int), Int) {
  let #(_, secrets) =
    list.range(1, 2000)
    |> list.map_fold(initial_secret, fn(secret, _) {
      let secret = next_secret(secret)
      #(secret, secret)
    })

  let all_secrets = [initial_secret, ..secrets]
  let all_prices = all_secrets |> list.map(fn(s) { s % 10 })
  let changes =
    all_prices
    |> list.window_by_2
    |> list.map(fn(p) {
      let #(a, b) = p
      b - a
    })
  let assert Ok(change_sequence_with_new_price) =
    changes
    |> list.window(4)
    |> list.strict_zip(
      // change sequence of 4 changes -> we can start buying from the 5th price
      all_prices |> list.drop(4),
    )

  change_sequence_with_new_price
  |> list.fold(dict.new(), fn(acc, seq) {
    let #(changes, price) = seq
    let assert [c1, c2, c3, c4] = changes
    let changes = #(c1, c2, c3, c4)
    case acc |> dict.get(changes) {
      Ok(_) -> acc
      Error(Nil) -> acc |> dict.insert(changes, price)
    }
  })
}

fn solve_part_1(input: String) -> String {
  parse_input(input)
  |> list.map(nth_secret(_, 2000))
  |> int.sum
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  let all_change_sequence_gains =
    parse_input(input) |> list.map(change_sequence_gains)

  let all_change_sequences =
    all_change_sequence_gains
    |> list.flat_map(dict.keys)
    |> set.from_list

  let change_sequence_total_gains =
    all_change_sequences
    |> set.to_list
    |> list.map(fn(seq) {
      all_change_sequence_gains
      |> list.map(fn(g) { g |> dict.get(seq) |> result.unwrap(0) })
      |> int.sum
    })

  let assert Ok(answer) = change_sequence_total_gains |> list.reduce(int.max)

  answer |> int.to_string
}
