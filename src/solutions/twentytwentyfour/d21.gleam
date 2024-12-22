import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/util
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

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
