import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/position.{type Direction, type Pos2d, Pos2d}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import gleamy/priority_queue.{type Queue}

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 16),
    solve_part_1,
    solve_part_2,
  )
}

type MazeEntity {
  Wall
  Empty
  End
}

fn parse_input(input: String) -> #(Dict(Pos2d, MazeEntity), Pos2d) {
  let grid =
    input
    |> string.trim
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(c, x) {
        case c {
          "#" -> #(Pos2d(x, y), Wall)
          "." -> #(Pos2d(x, y), Empty)
          "S" -> #(Pos2d(x, y), Empty)
          "E" -> #(Pos2d(x, y), End)
          _ -> panic as "impossible input character"
        }
      })
    })
    |> list.flatten
    |> dict.from_list
  let assert Ok(start) =
    input
    |> string.trim
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(c, x) {
        case c {
          "S" -> Ok(Pos2d(x, y))
          _ -> Error(Nil)
        }
      })
    })
    |> list.flatten
    |> result.values
    |> list.first
  #(grid, start)
}

fn solve_maze_score(
  grid: Dict(Pos2d, MazeEntity),
  visited: set.Set(#(Pos2d, Direction)),
  queue: Queue(#(Pos2d, Direction, Int)),
) -> Int {
  let assert Ok(#(#(pos, dir, score), queue)) = queue |> priority_queue.pop
  let assert Ok(entity) = grid |> dict.get(pos)
  case entity {
    End -> score
    Wall -> solve_maze_score(grid, visited, queue)
    Empty -> {
      use <- bool.lazy_guard(visited |> set.contains(#(pos, dir)), fn() {
        solve_maze_score(grid, visited, queue)
      })
      let visited = visited |> set.insert(#(pos, dir))
      let queue =
        [
          #(dir, score + 0),
          #(dir |> position.rotate_left, score + 1000),
          #(dir |> position.rotate_right, score + 1000),
        ]
        |> list.fold(queue, fn(queue, x) {
          let #(dir, score) = x
          let pos = pos |> position.step(dir)
          let score = score + 1
          case
            grid |> dict.has_key(pos)
            && visited |> set.contains(#(pos, dir)) |> bool.negate
          {
            True -> queue |> priority_queue.push(#(pos, dir, score))
            False -> queue
          }
        })
      solve_maze_score(grid, visited, queue)
    }
  }
}

fn solve_part_1(input: String) -> String {
  let #(grid, start) = parse_input(input)
  let assert Ok(#(end, _)) =
    grid
    |> dict.filter(fn(_, v) {
      case v {
        Empty -> False
        End -> True
        Wall -> False
      }
    })
    |> dict.to_list
    |> list.first
  let score =
    solve_maze_score(
      grid,
      set.new(),
      priority_queue.from_list([#(start, position.East, 0)], fn(a, b) {
        let #(a, _, a_score) = a
        let #(b, _, b_score) = b
        {
          a_score
          + int.absolute_value(a.x - end.x)
          + int.absolute_value(a.y - end.y)
        }
        |> int.compare(
          b_score
          + int.absolute_value(b.x - end.x)
          + int.absolute_value(b.y - end.y),
        )
      }),
    )
  // solve_maze_score(grid, set.new(), start, position.East, 0, Error(Nil))
  score |> int.to_string
}

fn solve_part_2(input: String) -> String {
  todo
}
