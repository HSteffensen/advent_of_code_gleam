import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/position.{type Pos2d, Pos2d}
import gleam/bool
import gleam/int
import gleam/list
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 13),
    solve_part_1,
    solve_part_2,
  )
}

type ClawMachine {
  ClawMachine(a: Pos2d, b: Pos2d, prize: Pos2d)
}

fn parse_claw_machine(input: String) -> ClawMachine {
  let assert Ok(#(ax, input)) =
    input |> string.drop_start(12) |> string.split_once(", Y+")
  let assert Ok(#(ay, input)) = input |> string.split_once("\nButton B: X+")
  let assert Ok(#(bx, input)) = input |> string.split_once(", Y+")
  let assert Ok(#(by, input)) = input |> string.split_once("\nPrize: X=")
  let assert Ok(#(prizex, prizey)) = input |> string.split_once(", Y=")
  let assert Ok(ax) = int.parse(ax)
  let assert Ok(ay) = int.parse(ay)
  let assert Ok(bx) = int.parse(bx)
  let assert Ok(by) = int.parse(by)
  let assert Ok(prizex) = int.parse(prizex)
  let assert Ok(prizey) = int.parse(prizey)
  ClawMachine(a: Pos2d(ax, ay), b: Pos2d(bx, by), prize: Pos2d(prizex, prizey))
}

fn parse_input(input: String) -> List(ClawMachine) {
  input |> string.trim |> string.split("\n\n") |> list.map(parse_claw_machine)
}

fn find_cheapest_solve(machine: ClawMachine) -> Result(#(Int, Int), Nil) {
  find_cheapest_solve_helper(machine, 0, Error(Nil))
}

fn find_cheapest_solve_helper(
  machine: ClawMachine,
  a_presses: Int,
  cheapest_so_far: Result(#(Int, Int), Nil),
) -> Result(#(Int, Int), Nil) {
  use <- bool.guard(a_presses > 100, cheapest_so_far)
  let ClawMachine(Pos2d(ax, ay), Pos2d(bx, by), Pos2d(px, py)) = machine
  let px = px - { a_presses * ax }
  let py = py - { a_presses * ay }
  let b_presses = px / bx
  case px % bx, py % by, b_presses == { py / by }, cheapest_so_far {
    0, 0, True, Error(Nil) -> {
      find_cheapest_solve_helper(
        machine,
        a_presses + 1,
        Ok(#(a_presses, b_presses)),
      )
    }
    0, 0, True, Ok(#(cheap_a, cheap_b)) -> {
      let current_cost = a_presses * 3 + b_presses
      let cheapest_cost = cheap_a * 3 + cheap_b
      use <- bool.guard(cheapest_cost <= current_cost, cheapest_so_far)
      find_cheapest_solve_helper(
        machine,
        a_presses + 1,
        Ok(#(a_presses, b_presses)),
      )
    }
    _, _, _, _ ->
      find_cheapest_solve_helper(machine, a_presses + 1, cheapest_so_far)
  }
}

fn solve_part_1(input: String) -> String {
  parse_input(input)
  |> list.filter_map(find_cheapest_solve)
  |> list.map(fn(it) {
    let #(a, b) = it
    a * 3 + b
  })
  |> int.sum
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  todo
}
