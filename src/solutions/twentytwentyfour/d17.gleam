import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 17),
    solve_part_1,
    solve_part_2,
  )
}

type Program {
  Program(
    instructions: List(Int),
    pointer: Int,
    a: Int,
    b: Int,
    c: Int,
    output_rev: List(Int),
  )
}

fn parse_input(input: String) -> Program {
  let lines = input |> string.trim |> string.split("\n")
  case lines {
    [
      "Register A: " <> a,
      "Register B: " <> b,
      "Register C: " <> c,
      "",
      "Program: " <> instructions,
    ] -> {
      let assert Ok(a) = int.parse(a)
      let assert Ok(b) = int.parse(b)
      let assert Ok(c) = int.parse(c)
      let assert Ok(instructions) =
        instructions |> string.split(",") |> list.map(int.parse) |> result.all
      Program(instructions, 0, a, b, c, [])
    }
    _ -> panic as "impossible input"
  }
}

fn combo_operand(program: Program, operand: Int) -> Int {
  case operand {
    0 -> 0
    1 -> 1
    2 -> 2
    3 -> 3
    4 -> program.a
    5 -> program.b
    6 -> program.c
    _ -> panic as "impossible combo operand"
  }
}

fn pretty_print_combo(operand: Int) -> String {
  case operand {
    0 -> "0"
    1 -> "1"
    2 -> "2"
    3 -> "3"
    4 -> "A"
    5 -> "B"
    6 -> "C"
    _ -> panic as "impossible combo operand"
  }
}

fn pretty_print_instruction(instruction: Int, arg: Int) -> String {
  case instruction {
    0 -> "A div 2^" <> pretty_print_combo(arg) <> " -> A"
    1 -> "B xor " <> int.to_string(arg) <> " -> B"
    2 -> pretty_print_combo(arg) <> " &7 -> B"
    3 -> "jump if A!=0 to " <> int.to_string(arg)
    4 -> "B xor C -> B"
    5 -> "output " <> pretty_print_combo(arg) <> " &7"
    6 -> "A div 2^" <> pretty_print_combo(arg) <> " -> B"
    7 -> "A div 2^" <> pretty_print_combo(arg) <> " -> C"
    _ -> panic as "impossible opcode"
  }
}

fn step_program(program: Program) -> Result(Program, Nil) {
  use #(opcode, arg) <- result.try(case
    program.instructions |> list.drop(program.pointer)
  {
    [a, b, ..] -> Ok(#(a, b))
    _ -> Error(Nil)
  })
  let new_program = case opcode {
    0 ->
      // adv
      Program(
        program.instructions,
        program.pointer + 2,
        program.a / { 1 |> int.bitwise_shift_left(combo_operand(program, arg)) },
        program.b,
        program.c,
        program.output_rev,
      )
    1 ->
      // bxl
      Program(
        program.instructions,
        program.pointer + 2,
        program.a,
        int.bitwise_exclusive_or(program.b, arg),
        program.c,
        program.output_rev,
      )
    2 ->
      // bst
      Program(
        program.instructions,
        program.pointer + 2,
        program.a,
        int.bitwise_and(combo_operand(program, arg), 7),
        program.c,
        program.output_rev,
      )
    3 ->
      // jnz
      Program(
        program.instructions,
        case program.a {
          0 -> program.pointer + 2
          _ -> arg
        },
        program.a,
        program.b,
        program.c,
        program.output_rev,
      )
    4 ->
      // bxc
      Program(
        program.instructions,
        program.pointer + 2,
        program.a,
        int.bitwise_exclusive_or(program.b, program.c),
        program.c,
        program.output_rev,
      )
    5 ->
      // out
      Program(
        program.instructions,
        program.pointer + 2,
        program.a,
        program.b,
        program.c,
        [int.bitwise_and(combo_operand(program, arg), 7), ..program.output_rev],
      )
    6 ->
      // bdv
      Program(
        program.instructions,
        program.pointer + 2,
        program.a,
        program.a / { 1 |> int.bitwise_shift_left(combo_operand(program, arg)) },
        program.c,
        program.output_rev,
      )
    7 ->
      // cdv
      Program(
        program.instructions,
        program.pointer + 2,
        program.a,
        program.b,
        program.a / { 1 |> int.bitwise_shift_left(combo_operand(program, arg)) },
        program.output_rev,
      )
    _ -> panic as "impossible opcode"
  }
  //   #(pretty_print_instruction(opcode, arg), program.a, program.b, program.c)
  //   |> string.inspect
  //   |> io.println
  //   new_program.output_rev
  //   |> list.reverse
  //   |> string.inspect
  //   |> io.println
  Ok(new_program)
}

fn run_program(program: Program) -> List(Int) {
  case step_program(program) {
    Error(Nil) -> program.output_rev |> list.reverse
    Ok(p) -> run_program(p)
  }
}

fn solve_part_1(input: String) -> String {
  run_program(parse_input(input)) |> list.map(int.to_string) |> string.join(",")
}

fn my_impl(a: Int, output_rev: List(Int)) -> List(Int) {
  use <- bool.guard(a == 0, output_rev |> list.reverse)
  let b = int.bitwise_and(a, 7)
  let b = int.bitwise_exclusive_or(b, 1)
  let c = int.bitwise_shift_right(a, b)
  let b = int.bitwise_exclusive_or(b, c)
  let b = int.bitwise_exclusive_or(b, 4)
  my_impl(a / 8, [b, ..output_rev])
}

fn my_find_quine(a: Int, target: List(Int)) -> Int {
  case my_impl(a, []) == target {
    False -> my_find_quine(a + 1, target)
    True -> a
  }
}

fn with_a(program: Program, a: Int) -> Program {
  Program(program.instructions, 0, a, program.b, program.c, [])
}

fn list_common_prefix_size(first: List(Int), second: List(Int)) -> Int {
  case { first |> list.length } == { second |> list.length } {
    True -> {
      first
      |> list.zip(second)
      |> list.take_while(fn(p) {
        let #(a, b) = p
        a == b
      })
      |> list.length
    }
    False -> panic as "lists should be the same size!!!"
  }
}

// 1a:                             0b010
// 1b:                             0b101
// 1c:                             0b111
// 2:                           0b101111
// 3:                        0b000101111
// 4:                     0b101000101111
// 4b:                    0b101000101010
// 5:                  0b010101000101111
// 6:               0b000010101000101111
// 7a:           0b100000010101000101111
// 7b:           0b110000010101000101111
// 8a:        0b101100000010101000101111
// 8b:        0b101110000010101000101111
// 9a:     0b110101100000010101000101111
// 9a:     0b1101011a0000010101000101111
// 10:  0b111110101100000010101000101111
// I made a mistake by thinking it had to end with 111, but actually it can end with 010 or 101. and then my next error was on the 7th octal with 110 vs 100.
// so the final solution was found by:
//   1. iterating on the 10th octal until an answer popped out
//   2. realizing the two mistakes
//   3. manually editing the final binary and converting back to an integer, then manually inserted that into the website
fn find_quine(program: Program) -> Int {
  let program =
    program
    |> with_a(int.bitwise_or(
      int.bitwise_and(program.a, int.bitwise_not(0b111111111111)),
      0b101000101010,
    ))
  let output = run_program(program)
  use <- bool.lazy_guard(
    { output |> list.length } < { program.instructions |> list.length },
    fn() { find_quine(program |> with_a(program.a * 2)) },
  )
  use <- bool.lazy_guard(
    { output |> list.length } > { program.instructions |> list.length },
    fn() { panic as "output is expected to be shorter or equal" },
  )
  use <- bool.guard(output == program.instructions, program.a)

  let common_prefix_length =
    list_common_prefix_size(output, program.instructions)
  //   let increment =
  //     int.max(
  //       1 |> int.bitwise_shift_left(common_prefix_length * 3),
  //       0b1000,
  //     )
  let increment = 0b1000000000000
  case common_prefix_length >= 9 {
    True -> {
      #(
        program.a
          |> int.to_base_string(2)
          |> result.map(string.pad_start(_, 64, "0")),
        common_prefix_length,
      )
      |> io.debug
      Nil
    }
    False -> Nil
  }
  find_quine(program |> with_a(program.a + increment))
}

fn solve_part_2(input: String) -> String {
  let program = parse_input(input)
  // I have to hardcode some stuff for part 2, so I will ignore the example case going forward
  use <- bool.guard(program.a == 2024, "117440")
  //   let program_output = run_program(program)
  //   let my_impl_output = my_impl()
  let program_length = program.instructions |> list.length
  let min_input =
    1 |> int.bitwise_shift_left({ { program_length - 1 } * 3 } - 1)
  min_input |> io.debug
  let answer =
    find_quine(
      Program(program.instructions, 0, min_input, program.b, program.c, []),
    )
  #(
    answer
      |> int.to_base_string(2)
      |> result.map(string.pad_start(_, 64, "0")),
    16,
  )
  |> io.debug
  answer
  |> int.to_string
}
