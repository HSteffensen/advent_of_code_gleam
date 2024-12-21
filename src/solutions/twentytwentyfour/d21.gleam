import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import gleamy/priority_queue.{type Queue}

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 21),
    solve_part_1,
    solve_part_2,
  )
}

type NumericButton {
  One
  Two
  Three
  Four
  Five
  Six
  Seven
  Eight
  Nine
  Zero
  ANumeric
}

type DirectonalButton {
  Up
  Left
  Down
  Right
  ADirectional
}

fn numeric_neighbors(button: NumericButton) -> List(NumericButton) {
  case button {
    ANumeric -> [Zero, Three]
    Eight -> [Seven, Nine, Five]
    Five -> [Eight, Four, Six, Two]
    Four -> [Seven, Five, One]
    Nine -> [Eight, Six]
    One -> [Four, Two]
    Seven -> [Eight, Four]
    Six -> [Nine, Five, Three]
    Three -> [Six, Two, ANumeric]
    Two -> [Five, One, Three, Zero]
    Zero -> [Two, ANumeric]
  }
}

fn directional_neighbors(button: DirectonalButton) -> List(DirectonalButton) {
  case button {
    ADirectional -> [Up, Right]
    Down -> [Up, Left, Right]
    Left -> [Down]
    Right -> [ADirectional, Down]
    Up -> [ADirectional, Down]
  }
}

type RobotsState {
  RobotsState(
    directional1: DirectonalButton,
    directional2: DirectonalButton,
    numeric: NumericButton,
    output: String,
  )
}

fn press_direction_into_directional(
  pressing: DirectonalButton,
  target: DirectonalButton,
) -> Result(DirectonalButton, Nil) {
  case pressing, target {
    Down, Up -> Ok(Down)
    Down, ADirectional -> Ok(Right)
    Left, ADirectional -> Ok(Up)
    Left, Down -> Ok(Left)
    Left, Right -> Ok(Down)
    Right, Up -> Ok(ADirectional)
    Right, Left -> Ok(Down)
    Right, Down -> Ok(Right)
    Up, Down -> Ok(Up)
    Up, Right -> Ok(ADirectional)
    ADirectional, _ -> Ok(target)
    _, _ -> Error(Nil)
  }
}

fn press_direction_into_numeric(
  pressing: DirectonalButton,
  target: NumericButton,
) -> Result(NumericButton, Nil) {
  case pressing, target {
    Down, Seven -> Ok(Four)
    Down, Eight -> Ok(Five)
    Down, Nine -> Ok(Six)
    Down, Four -> Ok(One)
    Down, Five -> Ok(Two)
    Down, Six -> Ok(Three)
    Down, Two -> Ok(Zero)
    Down, Three -> Ok(ANumeric)
    Left, Eight -> Ok(Seven)
    Left, Five -> Ok(Four)
    Left, Two -> Ok(One)
    Left, Nine -> Ok(Eight)
    Left, Six -> Ok(Five)
    Left, Three -> Ok(Two)
    Left, ANumeric -> Ok(Zero)
    Right, Seven -> Ok(Eight)
    Right, Four -> Ok(Five)
    Right, One -> Ok(Two)
    Right, Eight -> Ok(Nine)
    Right, Five -> Ok(Six)
    Right, Two -> Ok(Three)
    Right, Zero -> Ok(ANumeric)
    Up, Four -> Ok(Seven)
    Up, Five -> Ok(Eight)
    Up, Six -> Ok(Nine)
    Up, One -> Ok(Four)
    Up, Two -> Ok(Five)
    Up, Three -> Ok(Six)
    Up, Zero -> Ok(Two)
    Up, ANumeric -> Ok(Three)
    ADirectional, _ -> Ok(target)
    _, _ -> Error(Nil)
  }
}

fn press_button(
  robots: RobotsState,
  button: DirectonalButton,
  target: String,
) -> Result(RobotsState, Nil) {
  use <- bool.guard(
    case button {
      ADirectional -> False
      _ -> True
    },
    press_direction_into_directional(button, robots.directional1)
      |> result.map(fn(new_directional1) {
        RobotsState(
          new_directional1,
          robots.directional2,
          robots.numeric,
          robots.output,
        )
      }),
  )
  use <- bool.guard(
    case robots.directional1 {
      ADirectional -> False
      _ -> True
    },
    press_direction_into_directional(robots.directional1, robots.directional2)
      |> result.map(fn(new_directional2) {
        RobotsState(
          robots.directional1,
          new_directional2,
          robots.numeric,
          robots.output,
        )
      }),
  )
  use <- bool.guard(
    case robots.directional2 {
      ADirectional -> False
      _ -> True
    },
    press_direction_into_numeric(robots.directional2, robots.numeric)
      |> result.map(fn(new_numeric) {
        RobotsState(
          ADirectional,
          robots.directional2,
          new_numeric,
          robots.output,
        )
      }),
  )
  let pressed_numeric = case robots.numeric {
    ANumeric -> "A"
    Eight -> "8"
    Five -> "5"
    Four -> "4"
    Nine -> "9"
    One -> "1"
    Seven -> "7"
    Six -> "6"
    Three -> "3"
    Two -> "2"
    Zero -> "0"
  }
  let new_output = robots.output <> pressed_numeric
  case target |> string.starts_with(new_output) {
    True ->
      Ok(RobotsState(ADirectional, ADirectional, robots.numeric, new_output))
    False -> Error(Nil)
  }
}

fn fewest_button_presses(
  target: String,
  queue: Queue(#(RobotsState, Int)),
  visited: Dict(RobotsState, Int),
) -> Result(Int, Nil) {
  use #(#(robots, presses), queue) <- result.try(queue |> priority_queue.pop)
  use <- bool.guard(robots.output == target, Ok(presses))
  let assert True = target |> string.starts_with(robots.output)
  use <- bool.lazy_guard(
    case visited |> dict.get(robots) {
      Ok(p) if p <= presses -> True
      _ -> False
    },
    fn() { fewest_button_presses(target, queue, visited) },
  )
  //   #(robots, presses) |> io.debug
  let visited = visited |> dict.insert(robots, presses)
  let queue =
    [Left, Right, Up, Down, ADirectional]
    |> list.fold(queue, fn(queue, button) {
      case press_button(robots, button, target) {
        Ok(new_robots) ->
          queue |> priority_queue.push(#(new_robots, presses + 1))
        Error(Nil) -> queue
      }
    })
  fewest_button_presses(target, queue, visited)
}

fn complexity_score(line: String, button_presses: Int) -> Int {
  let numeric = line |> string.replace("A", "")
  let assert Ok(numeric) = int.parse(numeric)
  numeric * button_presses
}

fn solve_part_1(input: String) -> String {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    complexity_score(
      line,
      fewest_button_presses(
        line,
        priority_queue.from_list(
          [#(RobotsState(ADirectional, ADirectional, ANumeric, ""), 0)],
          fn(a, b) {
            let #(a_robots, a_presses) = a
            let #(b_robots, b_presses) = b
            // longer output first, otherwise fewer presses
            case
              string.length(b_robots.output)
              |> int.compare(string.length(a_robots.output))
            {
              order.Eq -> a_presses |> int.compare(b_presses)
              other -> other
            }
          },
        ),
        dict.new(),
      )
        |> result.lazy_unwrap(fn() { panic as "expected to have an answer" }),
    )
  })
  |> int.sum
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  todo
}
