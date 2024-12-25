import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/util
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 24),
    solve_part_1,
    solve_part_2,
  )
}

type Gate {
  And(a: String, b: String, out: String)
  Or(a: String, b: String, out: String)
  Xor(a: String, b: String, out: String)
}

fn parse_input(input: String) -> #(Dict(String, Bool), List(Gate)) {
  let assert Ok(#(values, gates)) =
    input |> string.trim |> string.split_once("\n\n")
  let values =
    values
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(name, v)) = line |> string.split_once(": ")
      #(name, case v {
        "0" -> False
        "1" -> True
        _ -> panic as "unexpected parse value"
      })
    })
    |> dict.from_list

  let gates =
    gates
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(left, out)) = line |> string.split_once(" -> ")
      use <- util.result_return_ok(
        left
        |> string.split_once(" AND ")
        |> result.map(fn(p) {
          let #(a, b) = p
          And(a, b, out)
        }),
      )
      use <- util.result_return_ok(
        left
        |> string.split_once(" OR ")
        |> result.map(fn(p) {
          let #(a, b) = p
          Or(a, b, out)
        }),
      )
      use <- util.result_return_ok(
        left
        |> string.split_once(" XOR ")
        |> result.map(fn(p) {
          let #(a, b) = p
          Xor(a, b, out)
        }),
      )
      panic as "unexpected parse gate"
    })

  #(values, gates)
}

fn step_gates(
  values: Dict(String, Bool),
  gates: List(Gate),
) -> Dict(String, Bool) {
  gates
  |> list.fold(values, fn(values, gate) {
    case
      values |> dict.get(gate.a),
      values |> dict.get(gate.b),
      values |> dict.get(gate.out),
      gate
    {
      Ok(a_val), Ok(b_val), Error(Nil), And(..) ->
        values |> dict.insert(gate.out, a_val && b_val)
      Ok(a_val), Ok(b_val), Error(Nil), Or(..) ->
        values |> dict.insert(gate.out, a_val || b_val)
      Ok(a_val), Ok(b_val), Error(Nil), Xor(..) ->
        values |> dict.insert(gate.out, bool.exclusive_or(a_val, b_val))
      _, _, _, _ -> values
    }
  })
}

fn step_gates_until_zs(
  values: Dict(String, Bool),
  gates: List(Gate),
  zs: List(String),
) -> Dict(String, Bool) {
  use <- util.result_return_ok(
    zs |> list.map(dict.get(values, _)) |> result.all |> result.replace(values),
  )
  step_gates_until_zs(step_gates(values, gates), gates, zs)
}

fn vals_to_int(values: Dict(String, Bool), zs: List(String)) -> Int {
  let assert Ok(answer) =
    zs
    |> list.sort(fn(a, b) { b |> string.compare(a) })
    |> list.map(fn(z) {
      let assert Ok(v) = values |> dict.get(z)
      case v {
        False -> "0"
        True -> "1"
      }
    })
    |> string.join("")
    |> int.base_parse(2)
  answer
}

fn run_system(values: Dict(String, Bool), gates: List(Gate)) -> Int {
  let zs =
    gates
    |> list.map(fn(g) { g.out })
    |> list.filter(string.starts_with(_, "z"))
    |> list.unique
  let values = step_gates_until_zs(values, gates, zs)
  vals_to_int(values, zs)
}

fn swap_gates(gates: List(Gate), swaps: List(#(String, String))) -> List(Gate) {
  let swaps =
    swaps
    |> list.flat_map(fn(p) {
      let #(a, b) = p
      [p, #(b, a)]
    })
    |> dict.from_list
  gates
  |> list.map(fn(gate) {
    case gate {
      And(..) -> And
      Or(..) -> Or
      Xor(..) -> Xor
    }(gate.a, gate.b, swaps |> dict.get(gate.out) |> result.unwrap(gate.out))
  })
}

fn solve_part_1(input: String) -> String {
  let #(values, gates) = parse_input(input)
  run_system(values, gates) |> int.to_string
}

fn solve_part_2(input: String) -> String {
  use <- bool.guard(input == "", "0")
  let #(values, gates) = parse_input(input)
  let swaps = [
    #("z08", "cdj"),
    #("z16", "mrb"),
    #("z32", "gfm"),
    #("qjd", "dhm"),
  ]
  let gates = swap_gates(gates, swaps)
  let xs = values |> dict.keys |> list.filter(string.starts_with(_, "x"))
  let ys = values |> dict.keys |> list.filter(string.starts_with(_, "y"))
  let x = vals_to_int(values, xs)
  x |> int.to_base_string(2) |> io.debug
  let y = vals_to_int(values, ys)
  y |> int.to_base_string(2) |> io.debug
  { x + y } |> int.to_base_string(2) |> io.debug
  run_system(values, gates) |> int.to_base_string(2) |> io.debug

  let test_input1 =
    "
x00: 1
x01: 1
x02: 1
x03: 1
x04: 1
x05: 1
x06: 1
x07: 1
x08: 1
x09: 1
x10: 1
x11: 1
x12: 1
x13: 1
x14: 1
x15: 1
x16: 1
x17: 1
x18: 1
x19: 1
x20: 1
x21: 1
x22: 1
x23: 1
x24: 1
x25: 1
x26: 1
x27: 1
x28: 1
x29: 1
x30: 1
x31: 1
x32: 1
x33: 1
x34: 1
x35: 1
x36: 1
x37: 1
x38: 1
x39: 1
x40: 1
x41: 1
x42: 1
x43: 1
x44: 1
y00: 1
y01: 1
y02: 1
y03: 1
y04: 1
y05: 1
y06: 1
y07: 1
y08: 1
y09: 1
y10: 1
y11: 1
y12: 1
y13: 1
y14: 1
y15: 1
y16: 1
y17: 1
y18: 1
y19: 1
y20: 1
y21: 1
y22: 1
y23: 1
y24: 1
y25: 1
y26: 1
y27: 1
y28: 1
y29: 1
y30: 1
y31: 1
y32: 1
y33: 1
y34: 1
y35: 1
y36: 1
y37: 1
y38: 1
y39: 1
y40: 1
y41: 1
y42: 1
y43: 1
y44: 1

stn AND ffg -> tnr
"
  let #(values, _) = parse_input(test_input1)
  let xs = values |> dict.keys |> list.filter(string.starts_with(_, "x"))
  let ys = values |> dict.keys |> list.filter(string.starts_with(_, "y"))
  let x = vals_to_int(values, xs)
  x |> int.to_base_string(2) |> io.debug
  let y = vals_to_int(values, ys)
  y |> int.to_base_string(2) |> io.debug
  { x + y } |> int.to_base_string(2) |> io.debug
  run_system(values, gates) |> int.to_base_string(2) |> io.debug

  swaps
  |> list.flat_map(fn(p) {
    let #(a, b) = p
    [a, b]
  })
  |> list.sort(string.compare)
  |> string.join(",")
  //   todo
}
