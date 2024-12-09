import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/int
import gleam/list
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 9),
    solve_part_1,
    solve_part_2,
  )
}

type Diskspace {
  File(id: Int, length: Int)
  Empty(length: Int)
}

fn parse_input(input: String) -> List(Diskspace) {
  input
  |> string.trim
  |> string.to_graphemes
  |> list.index_map(fn(c, i) {
    let assert Ok(length) = int.parse(c)
    case i {
      i if i % 2 == 0 -> File(i / 2, length)
      _ -> Empty(length)
    }
  })
}

fn replace_empty_blocks(
  input: List(Diskspace),
  reversed_input: List(Diskspace),
  result_list: List(Diskspace),
) -> List(Diskspace) {
  case input, reversed_input {
    [File(id1, ..), ..], [File(id2, ..) as f, ..] if id1 == id2 ->
      [f, ..result_list] |> list.reverse
    _, [Empty(..), ..rest] -> replace_empty_blocks(input, rest, result_list)
    [File(..) as f, ..rest], _ ->
      replace_empty_blocks(rest, reversed_input, [f, ..result_list])
    [Empty(empty_len), ..rest1], [File(_, f_len) as f, ..rest2]
      if empty_len == f_len
    -> replace_empty_blocks(rest1, rest2, [f, ..result_list])
    [Empty(empty_len), ..rest1], [File(id, f_len), ..rest2]
      if empty_len < f_len
    ->
      replace_empty_blocks(rest1, [File(id, f_len - empty_len), ..rest2], [
        File(id, empty_len),
        ..result_list
      ])
    [Empty(empty_len), ..rest1], [File(id, f_len), ..rest2]
      if empty_len > f_len
    ->
      replace_empty_blocks([Empty(empty_len - f_len), ..rest1], rest2, [
        File(id, f_len),
        ..result_list
      ])
    _, _ -> panic as "unreachable"
  }
}

fn triangle(i: Int) -> Int {
  { i * { i + 1 } } / 2
}

fn blocks_hash(disk: List(Diskspace)) -> Int {
  let #(_, result) =
    disk
    |> list.map_fold(0, fn(first_index, f) {
      case f {
        File(id, length) -> {
          let hash =
            { triangle(length) + { { first_index - 1 } * length } } * id
          let next_index = first_index + length
          #(next_index, hash)
        }
        Empty(length) -> #(first_index + length, 0)
      }
    })
  result |> int.sum
}

fn fill_empty_blocks(
  disk: List(Diskspace),
  reversed_input: List(Diskspace),
) -> List(Diskspace) {
  case reversed_input {
    [] -> disk
    [Empty(..), ..rest] -> fill_empty_blocks(disk, rest)
    [File(id, length), ..rest] -> {
      let #(_, new_disk) =
        disk
        |> list.map_fold(False, fn(moved, f) {
          case f, moved {
            File(id2, ..) as f2, False if id2 == id -> #(True, [f2])
            File(id2, ..), True if id2 == id -> #(True, [Empty(length)])
            File(..) as f2, _ -> #(moved, [f2])
            Empty(length2), False if length2 >= length -> #(True, [
              File(id, length),
              Empty(length2 - length),
            ])
            Empty(..) as f2, _ -> #(moved, [f2])
          }
        })
      let new_disk = new_disk |> list.flatten |> combine_empty_blocks([])
      fill_empty_blocks(new_disk, rest)
    }
  }
}

fn combine_empty_blocks(
  disk: List(Diskspace),
  result: List(Diskspace),
) -> List(Diskspace) {
  case disk, result {
    [], _ -> result |> list.reverse
    [Empty(0), ..rest], _ -> combine_empty_blocks(rest, result)
    [Empty(length1), ..rest1], [Empty(length2), ..rest2] ->
      combine_empty_blocks(rest1, [Empty(length1 + length2), ..rest2])
    [f, ..rest], _ -> combine_empty_blocks(rest, [f, ..result])
  }
}

fn solve_part_1(input: String) -> String {
  let input = parse_input(input)
  replace_empty_blocks(input, input |> list.reverse, [])
  |> blocks_hash
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  let input = parse_input(input)
  fill_empty_blocks(input, input |> list.reverse)
  |> blocks_hash
  |> int.to_string
}
