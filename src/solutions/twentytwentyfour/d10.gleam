import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/position.{type Pos2d, Pos2d}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 10),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> Dict(Pos2d, Int) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(c, x) { #(Pos2d(x, y), int.parse(c)) })
  })
  |> list.flatten
  |> list.filter_map(fn(it) {
    case it {
      #(key, Ok(value)) -> Ok(#(key, value))
      _ -> Error(Nil)
    }
  })
  |> dict.from_list
}

fn trailheads(grid: Dict(Pos2d, Int)) -> List(Pos2d) {
  grid
  |> dict.to_list
  |> list.filter_map(fn(it) {
    case it {
      #(pos, 0) -> Ok(pos)
      _ -> Error(Nil)
    }
  })
}

fn count_trail_ends_dfs(
  grid: Dict(Pos2d, Int),
  pos: Pos2d,
  visited: Set(Pos2d),
) -> List(Pos2d) {
  let visited = visited |> set.insert(pos)
  case grid |> dict.get(pos) {
    Error(_) -> panic as "unreachable"
    Ok(9) -> [pos]
    Ok(height) ->
      pos
      |> position.neighbors4
      |> list.filter(fn(p2) {
        case set.contains(visited, p2), dict.get(grid, p2) {
          False, Ok(h2) if h2 == height + 1 -> True
          _, _ -> False
        }
      })
      |> list.flat_map(count_trail_ends_dfs(grid, _, visited))
  }
}

fn count_trail_ends(grid: Dict(Pos2d, Int)) -> Int {
  trailheads(grid)
  |> list.map(count_trail_ends_dfs(grid, _, set.new()))
  |> list.map(list.unique)
  |> list.map(list.length)
  |> int.sum
}

fn count_trails_dfs(
  grid: Dict(Pos2d, Int),
  pos: Pos2d,
  visited: Set(Pos2d),
) -> Int {
  let visited = visited |> set.insert(pos)
  case grid |> dict.get(pos) {
    Error(_) -> panic as "unreachable"
    Ok(9) -> 1
    Ok(height) ->
      pos
      |> position.neighbors4
      |> list.filter(fn(p2) {
        case set.contains(visited, p2), dict.get(grid, p2) {
          False, Ok(h2) if h2 == height + 1 -> True
          _, _ -> False
        }
      })
      |> list.map(count_trails_dfs(grid, _, visited))
      |> int.sum
  }
}

fn count_trails(grid: Dict(Pos2d, Int)) -> Int {
  trailheads(grid)
  |> list.map(count_trails_dfs(grid, _, set.new()))
  |> int.sum
}

fn solve_part_1(input: String) -> String {
  parse_input(input) |> count_trail_ends |> int.to_string
}

fn solve_part_2(input: String) -> String {
  parse_input(input) |> count_trails |> int.to_string
}
