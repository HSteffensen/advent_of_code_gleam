import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/util
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

type DirectionalButton {
  Up
  Left
  Down
  Right
  ADirectional
}

fn numeric_neighbors(
  button: NumericButton,
) -> List(#(DirectionalButton, NumericButton)) {
  case button {
    ANumeric -> [#(Left, Zero), #(Up, Three)]
    Eight -> [#(Left, Seven), #(Right, Nine), #(Down, Five)]
    Five -> [#(Up, Eight), #(Left, Four), #(Right, Six), #(Down, Two)]
    Four -> [#(Up, Seven), #(Right, Five), #(Down, One)]
    Nine -> [#(Left, Eight), #(Down, Six)]
    One -> [#(Up, Four), #(Right, Two)]
    Seven -> [#(Right, Eight), #(Down, Four)]
    Six -> [#(Up, Nine), #(Left, Five), #(Down, Three)]
    Three -> [#(Up, Six), #(Left, Two), #(Down, ANumeric)]
    Two -> [#(Up, Five), #(Left, One), #(Right, Three), #(Down, Zero)]
    Zero -> [#(Up, Two), #(Right, ANumeric)]
  }
}

fn directional_neighbors(
  button: DirectionalButton,
) -> List(#(DirectionalButton, DirectionalButton)) {
  case button {
    ADirectional -> [#(Left, Up), #(Down, Right)]
    Down -> [#(Up, Up), #(Left, Left), #(Right, Right)]
    Left -> [#(Right, Down)]
    Right -> [#(Up, ADirectional), #(Left, Down)]
    Up -> [#(Right, ADirectional), #(Down, Down)]
  }
}

type RobotsState {
  RobotsState(
    directional1: DirectionalButton,
    directional2: DirectionalButton,
    numeric: NumericButton,
    output: String,
  )
}

fn press_direction_into_directional(
  pressing: DirectionalButton,
  target: DirectionalButton,
) -> Result(DirectionalButton, Nil) {
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
  pressing: DirectionalButton,
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
  button: DirectionalButton,
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

fn paths_to_numeric_button(
  start: NumericButton,
  target: NumericButton,
) -> List(List(DirectionalButton)) {
  case start, target {
    ANumeric, Zero -> [[Left]]
    ANumeric, One -> [[Up, Left, Left]]
    ANumeric, Two -> [[Up, Left], [Left, Up]]
    ANumeric, Three -> [[Up]]
    ANumeric, Four -> [[Up, Up, Left, Left]]
    ANumeric, Five -> [[Up, Up, Left], [Left, Up, Up]]
    ANumeric, Six -> [[Up, Up]]
    ANumeric, Seven -> [[Up, Up, Up, Left, Left]]
    ANumeric, Eight -> [[Up, Up, Up, Left], [Left, Up, Up, Up]]
    ANumeric, Nine -> [[Up, Up, Up]]
    Zero, ANumeric -> [[Right]]
    Zero, One -> [[Up, Left]]
    Zero, Two -> [[Up]]
    Zero, Three -> [[Up, Right], [Right, Up]]
    Zero, Four -> [[Up, Up, Left]]
    Zero, Five -> [[Up, Up]]
    Zero, Six -> [[Up, Up, Right], [Right, Up, Up]]
    Zero, Seven -> [[Up, Up, Up, Left]]
    Zero, Eight -> [[Up, Up, Up]]
    Zero, Nine -> [[Up, Up, Up, Right], [Right, Up, Up, Up]]
    One, ANumeric -> [[Right, Right, Down]]
    One, Zero -> [[Right, Down]]
    One, Two -> [[Right]]
    One, Three -> [[Right, Right]]
    One, Four -> [[Up]]
    One, Five -> [[Up, Right], [Right, Up]]
    One, Six -> [[Up, Right, Right], [Right, Right, Up]]
    One, Seven -> [[Up, Up]]
    One, Eight -> [[Up, Up, Right], [Right, Up, Up]]
    One, Nine -> [[Up, Up, Right, Right], [Right, Right, Up, Up]]
    Two, ANumeric -> [[Down, Right], [Right, Down]]
    Two, Zero -> [[Down]]
    Two, One -> [[Left]]
    Two, Three -> [[Right]]
    Two, Four -> [[Up, Left], [Left, Up]]
    Two, Five -> [[Up]]
    Two, Six -> [[Up, Right], [Right, Up]]
    Two, Seven -> [[Up, Up, Left], [Left, Up, Up]]
    Two, Eight -> [[Up, Up]]
    Two, Nine -> [[Up, Up, Right], [Right, Up, Up]]
    Three, ANumeric -> [[Down]]
    Three, Zero -> [[Down, Left], [Left, Down]]
    Three, One -> [[Left, Left]]
    Three, Two -> [[Left]]
    Three, Four -> [[Up, Left, Left], [Left, Left, Up]]
    Three, Five -> [[Up, Left], [Left, Up]]
    Three, Six -> [[Up]]
    Three, Seven -> [[Up, Up, Left, Left], [Left, Left, Up, Up]]
    Three, Eight -> [[Up, Up, Left], [Left, Up, Up]]
    Three, Nine -> [[Up, Up]]
    Four, ANumeric -> [[Right, Right, Down, Down]]
    Four, Zero -> [[Right, Down, Down]]
    Four, One -> [[Down]]
    Four, Two -> [[Down, Right], [Right, Down]]
    Four, Three -> [[Down, Right, Right], [Right, Right, Down]]
    Four, Five -> [[Right]]
    Four, Six -> [[Right, Right]]
    Four, Seven -> [[Up]]
    Four, Eight -> [[Up, Right], [Right, Up]]
    Four, Nine -> [[Up, Right, Right], [Right, Right, Up]]
    Five, ANumeric -> [[Down, Down, Right], [Right, Right, Down]]
    Five, Zero -> [[Down, Down]]
    Five, One -> [[Down, Left], [Left, Down]]
    Five, Two -> [[Down]]
    Five, Three -> [[Down, Right], [Right, Down]]
    Five, Four -> [[Left]]
    Five, Six -> [[Right]]
    Five, Seven -> [[Up, Left], [Left, Up]]
    Five, Eight -> [[Up]]
    Five, Nine -> [[Up, Right], [Right, Up]]
    Six, ANumeric -> [[Down, Down]]
    Six, Zero -> [[Down, Down, Left], [Left, Down, Down]]
    Six, One -> [[Down, Left, Left], [Left, Left, Down]]
    Six, Two -> [[Down, Left], [Left, Down]]
    Six, Three -> [[Down]]
    Six, Four -> [[Left, Left]]
    Six, Five -> [[Left]]
    Six, Seven -> [[Up, Left, Left], [Left, Left, Up]]
    Six, Eight -> [[Up, Left], [Left, Up]]
    Six, Nine -> [[Up]]
    Seven, ANumeric -> [[Right, Right, Down, Down, Down]]
    Seven, Zero -> [[Right, Down, Down, Down]]
    Seven, One -> [[Down, Down]]
    Seven, Two -> [[Down, Down, Right], [Right, Down, Down]]
    Seven, Three -> [[Down, Down, Right, Right], [Right, Right, Down, Down]]
    Seven, Four -> [[Down]]
    Seven, Five -> [[Down, Right], [Right, Down]]
    Seven, Six -> [[Down, Right, Right], [Right, Right, Down]]
    Seven, Eight -> [[Right]]
    Seven, Nine -> [[Right, Right]]
    Eight, ANumeric -> [[Down, Down, Down, Right], [Right, Right, Down, Down]]
    Eight, Zero -> [[Down, Down, Down]]
    Eight, One -> [[Down, Down, Left], [Left, Down, Down]]
    Eight, Two -> [[Down, Down]]
    Eight, Three -> [[Down, Down, Right], [Right, Down, Down]]
    Eight, Four -> [[Down, Left], [Left, Down]]
    Eight, Five -> [[Down]]
    Eight, Six -> [[Down, Right], [Right, Down]]
    Eight, Seven -> [[Left]]
    Eight, Nine -> [[Right]]
    Nine, ANumeric -> [[Down, Down, Down]]
    Nine, Zero -> [[Down, Down, Down, Left], [Left, Down, Down, Down]]
    Nine, One -> [[Down, Down, Left, Left], [Left, Left, Down, Down]]
    Nine, Two -> [[Down, Down, Left], [Left, Down, Down]]
    Nine, Three -> [[Down, Down]]
    Nine, Four -> [[Down, Left, Left], [Left, Left, Down]]
    Nine, Five -> [[Down, Left], [Left, Down]]
    Nine, Six -> [[Down]]
    Nine, Seven -> [[Left, Left]]
    Nine, Eight -> [[Left]]
    _, _ -> [[]]
  }
}

fn paths_to_directional_button(
  start: DirectionalButton,
  target: DirectionalButton,
) -> List(List(DirectionalButton)) {
  case start, target {
    ADirectional, Down -> [[Down, Left], [Left, Down]]
    ADirectional, Left -> [[Down, Left, Left]]
    ADirectional, Right -> [[Down]]
    ADirectional, Up -> [[Left]]
    Up, ADirectional -> [[Right]]
    Up, Down -> [[Down]]
    Up, Left -> [[Down, Left]]
    Up, Right -> [[Down, Right], [Right, Down]]
    Left, ADirectional -> [[Right, Right, Up]]
    Left, Down -> [[Right]]
    Left, Right -> [[Right, Right]]
    Left, Up -> [[Right, Up]]
    Down, ADirectional -> [[Up, Right], [Right, Up]]
    Down, Left -> [[Left]]
    Down, Right -> [[Right]]
    Down, Up -> [[Up]]
    Right, ADirectional -> [[Up]]
    Right, Down -> [[Left]]
    Right, Left -> [[Left, Left]]
    Right, Up -> [[Left, Up], [Up, Left]]
    _, _ -> [[]]
  }
}

fn press_directional_button(
  start: DirectionalButton,
  target: DirectionalButton,
  distance_to_numeric_pad: Int,
  cache: Dict(#(DirectionalButton, DirectionalButton, Int), Int),
  robots_inbetween: Int,
) -> #(Int, Dict(#(DirectionalButton, DirectionalButton, Int), Int)) {
  let cache_key = #(start, target, distance_to_numeric_pad)
  // |> io.debug
  use <- bool.guard(distance_to_numeric_pad == robots_inbetween + 1, #(
    // 1 press at the lowest level
    1,
    cache,
  ))
  use <- bool.guard(start == target, #(
    // 1 press of A at the lowest level will be good for keeping the current position
    1,
    cache,
  ))
  use <- util.result_return_ok(
    cache |> dict.get(cache_key) |> result.map(fn(v) { #(v, cache) }),
  )
  let #(cost, cache) =
    paths_to_directional_button(start, target)
    |> cost_of_best_path(cache, distance_to_numeric_pad + 1, robots_inbetween)
  let cache = cache |> dict.insert(cache_key, cost)
  #(cost, cache)
}

fn press_numerical_code(
  code: String,
  cache: Dict(#(DirectionalButton, DirectionalButton, Int), Int),
  robots_inbetween: Int,
) -> #(Int, Dict(#(DirectionalButton, DirectionalButton, Int), Int)) {
  let #(cache, costs) =
    [
      ANumeric,
      ..{
        code
        |> string.to_graphemes
        |> list.map(fn(c) {
          case c {
            "A" -> ANumeric
            "0" -> Zero
            "1" -> One
            "2" -> Two
            "3" -> Three
            "4" -> Four
            "5" -> Five
            "6" -> Six
            "7" -> Seven
            "8" -> Eight
            "9" -> Nine
            _ -> panic as "unexpected code character"
          }
        })
      }
    ]
    |> list.window_by_2
    |> list.map_fold(cache, fn(cache, p) {
      let #(s, t) = p
      // |> io.debug
      let #(best_cost, cache) =
        paths_to_numeric_button(s, t)
        |> cost_of_best_path(cache, 1, robots_inbetween)
      #(cache, best_cost)
    })
  #(costs |> int.sum, cache)
}

fn cost_of_best_path(
  paths: List(List(DirectionalButton)),
  cache: Dict(#(DirectionalButton, DirectionalButton, Int), Int),
  distance_to_numeric_pad: Int,
  robots_inbetween: Int,
) -> #(Int, Dict(#(DirectionalButton, DirectionalButton, Int), Int)) {
  let #(cache, path_costs) =
    paths
    |> list.map_fold(cache, fn(cache, path) {
      let #(cache, costs) =
        [ADirectional, ..path]
        |> list.append([ADirectional])
        |> list.window_by_2
        |> list.map_fold(cache, fn(cache, p) {
          let #(s, d) = p
          let #(cost, cache) =
            press_directional_button(
              s,
              d,
              distance_to_numeric_pad,
              cache,
              robots_inbetween,
            )
          #(cache, cost)
        })
      #(
        cache,
        costs |> int.sum,
        //|> io.debug
      )
    })
  let assert Ok(cost) =
    path_costs
    //|> io.debug
    |> list.reduce(int.min)
  #(cost, cache)
}

fn complexity_score(line: String, button_presses: Int) -> Int {
  let numeric = line |> string.replace("A", "")
  let assert Ok(numeric) = int.parse(numeric)
  numeric * button_presses
}

// v<<A>>^A<A>AvA<^AA>A<vAAA>^A
fn solve_part_1(input: String) -> String {
  let cache = dict.new()
  let #(_, all_presses) =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map_fold(cache, fn(cache, line) {
      //   line |> io.debug
      let #(presses, cache) = press_numerical_code(line, cache, 2)
      #(
        cache,
        complexity_score(
          line,
          presses,
          //|> io.debug
        ),
      )
    })
  all_presses
  |> int.sum
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  use <- bool.guard(input == "", "0")
  let cache = dict.new()
  let #(_, all_presses) =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map_fold(cache, fn(cache, line) {
      let #(presses, cache) = press_numerical_code(line, cache, 25)
      #(cache, complexity_score(line, presses))
    })
  all_presses
  |> int.sum
  |> int.to_string
}
