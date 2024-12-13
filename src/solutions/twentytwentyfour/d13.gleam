import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/position.{type Pos2d, Pos2d}
import gleam/bool
import gleam/int
import gleam/list
import gleam/string
import gleam_community/maths/arithmetics

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
  let ClawMachine(Pos2d(ax, ay), Pos2d(bx, by), Pos2d(px, py)) = machine
  let gcd_x = arithmetics.gcd(ax, bx)
  let gcd_y = arithmetics.gcd(ay, by)
  use <- bool.guard(px % gcd_x != 0 || py % gcd_y != 0, Error(Nil))
  let b_presses = {
    { { py * ax } - { px * ay } } / { { by * ax } - { bx * ay } }
  }
  let a_presses = {
    { px - { b_presses * bx } } / ax
  }
  case
    a_presses < 0,
    b_presses < 0,
    a_presses * ax + b_presses * bx == px,
    a_presses * ay + b_presses * by == py
  {
    False, False, True, True -> Ok(#(a_presses, b_presses))
    _, _, _, _ -> Error(Nil)
  }
}

fn solve_part_1(input: String) -> String {
  parse_input(input)
  |> list.filter_map(find_cheapest_solve)
  |> list.filter_map(fn(it) {
    let #(a, b) = it
    case a <= 100, b <= 100 {
      True, True -> Ok(3 * a + b)
      _, _ -> Error(Nil)
    }
  })
  |> int.sum
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  parse_input(input)
  |> list.map(fn(machine) {
    ClawMachine(
      machine.a,
      machine.b,
      Pos2d(
        machine.prize.x + 10_000_000_000_000,
        machine.prize.y + 10_000_000_000_000,
      ),
    )
  })
  |> list.filter_map(find_cheapest_solve)
  |> list.map(fn(it) {
    let #(a, b) = it
    a * 3 + b
  })
  |> int.sum
  |> int.to_string
}
