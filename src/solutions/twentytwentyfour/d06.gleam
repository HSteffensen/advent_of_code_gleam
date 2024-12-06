import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import gleam/yielder

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 6),
    solve_part_1,
    solve_part_2,
  )
}

type Pos {
  Pos(x: Int, y: Int)
}

type Direction {
  North
  South
  West
  East
}

fn direction_delta(dir: Direction) -> #(Int, Int) {
  case dir {
    North -> #(0, -1)
    South -> #(0, 1)
    West -> #(-1, 0)
    East -> #(1, 0)
  }
}

fn direction_rotate_90_right(dir: Direction) -> Direction {
  case dir {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

type MapParseItem {
  ObstaclePos
  EmptyPos
  GuardStartFacingNorthPos
}

type MapItem {
  Obstacle
  Empty
}

type GuardMap {
  GuardMap(
    guard_pos: Pos,
    guard_dir: Direction,
    guard_gone: Bool,
    map: dict.Dict(Pos, MapItem),
  )
}

fn parse_input(input: String) -> GuardMap {
  let parsed =
    input
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(c, x) {
        #(Pos(x, y), case c {
          "." -> EmptyPos
          "#" -> ObstaclePos
          "^" -> GuardStartFacingNorthPos
          _ -> panic as "unreachable because of impossible input"
        })
      })
    })
    |> list.flatten
  let assert Ok(#(guard_pos, _)) =
    parsed
    |> list.find(fn(x) {
      let #(_, item) = x
      case item {
        GuardStartFacingNorthPos -> True
        EmptyPos -> False
        ObstaclePos -> False
      }
    })
  let map =
    parsed
    |> list.map(fn(x) {
      let #(p, item) = x
      #(p, case item {
        EmptyPos -> Empty
        GuardStartFacingNorthPos -> Empty
        ObstaclePos -> Obstacle
      })
    })
    |> dict.from_list
  GuardMap(guard_pos, North, False, map)
}

fn advance_guard(guard_map: GuardMap) -> GuardMap {
  let GuardMap(guard_pos, guard_dir, _, map) = guard_map
  let Pos(x, y) = guard_pos
  let #(dx, dy) = direction_delta(guard_dir)
  let new_pos = Pos(x + dx, y + dy)
  case map |> dict.get(new_pos) {
    Ok(Empty) -> GuardMap(new_pos, guard_dir, False, map)
    Ok(Obstacle) ->
      GuardMap(guard_pos, direction_rotate_90_right(guard_dir), False, map)
    Error(Nil) -> GuardMap(new_pos, guard_dir, True, map)
  }
}

fn step_guard_until_gone_or_loop(guard_map: GuardMap) -> #(List(Pos), Bool) {
  let guard_pos_list =
    #(
      guard_map,
      set.new() |> set.insert(#(guard_map.guard_pos, guard_map.guard_dir)),
      False,
    )
    |> yielder.unfold(fn(acc) {
      let #(map, visited, looped) = acc
      let next = advance_guard(map)
      let next_visited = #(next.guard_pos, next.guard_dir)
      case next.guard_gone, visited |> set.contains(next_visited), looped {
        _, _, True -> yielder.Done
        False, False, _ ->
          yielder.Next(#(next.guard_pos, False), #(
            next,
            visited |> set.insert(next_visited),
            False,
          ))
        False, True, _ ->
          yielder.Next(#(next.guard_pos, True), #(
            next,
            visited |> set.insert(next_visited),
            True,
          ))
        True, _, _ -> yielder.Done
      }
    })
    |> yielder.to_list
  #(
    guard_pos_list
      |> list.map(fn(a) {
        let #(b, _) = a
        b
      }),
    guard_pos_list
      |> list.any(fn(a) {
        let #(_, b) = a
        b
      }),
  )
}

fn solve_part_1(input: String) -> String {
  parse_input(input)
  |> yielder.unfold(fn(map) {
    let next = advance_guard(map)
    case next.guard_gone {
      False -> yielder.Next(next.guard_pos, next)
      True -> yielder.Done
    }
  })
  |> yielder.to_list
  |> list.unique
  |> list.length
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  todo
}
