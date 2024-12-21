import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/position.{type Pos2d, Pos2d}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleamy/priority_queue.{type Queue}

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 18),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> List(Pos2d) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(a, b)) = line |> string.split_once(",")
    let assert Ok(a) = int.parse(a)
    let assert Ok(b) = int.parse(b)
    Pos2d(a, b)
  })
}

fn pathfind(
  walls: Set(Pos2d),
  visited: Dict(Pos2d, Int),
  queue: Queue(#(Pos2d, Int)),
  max_dimension: Int,
) -> Result(Int, Nil) {
  use #(#(pos, steps), queue) <- result.try(queue |> priority_queue.pop)
  use <- bool.guard(pos == Pos2d(max_dimension, max_dimension), Ok(steps))
  use <- bool.lazy_guard(
    set.contains(walls, pos)
      || pos.x < 0
      || pos.y < 0
      || pos.x > max_dimension
      || pos.y > max_dimension
      || case visited |> dict.get(pos) {
      Ok(s) if s <= steps -> True
      _ -> False
    },
    fn() { pathfind(walls, visited, queue, max_dimension) },
  )
  let visited = visited |> dict.insert(pos, steps)
  let queue =
    pos
    |> position.neighbors4
    |> list.fold(queue, fn(queue, neighbor) {
      queue |> priority_queue.push(#(neighbor, steps + 1))
    })
  pathfind(walls, visited, queue, max_dimension)
}

fn solve_part_1(input: String) -> String {
  let input = parse_input(input)
  let assert Ok(max_dimension) =
    input |> list.flat_map(fn(p) { [p.x, p.y] }) |> list.reduce(int.max)
  //   max_dimension |> io.debug
  let walls =
    input
    |> list.take(case max_dimension {
      6 -> 12
      70 -> 1024
      _ -> panic as "impossible max_dimension"
    })
    |> set.from_list
  let queue =
    priority_queue.from_list([#(Pos2d(0, 0), 0)], fn(a, b) {
      let #(a, a_score) = a
      let #(b, b_score) = b
      {
        a_score
        + int.absolute_value(a.x - max_dimension)
        + int.absolute_value(a.y - max_dimension)
      }
      |> int.compare(
        b_score
        + int.absolute_value(b.x - max_dimension)
        + int.absolute_value(b.y - max_dimension),
      )
    })
  let assert Ok(answer) = pathfind(walls, dict.new(), queue, max_dimension)
  answer |> int.to_string
}

fn first_blocking_byte(walls_list: List(Pos2d)) -> Int {
  let assert Ok(max_dimension) =
    walls_list |> list.flat_map(fn(p) { [p.x, p.y] }) |> list.reduce(int.max)
  let queue =
    priority_queue.from_list([#(Pos2d(0, 0), 0)], fn(a, b) {
      let #(a, a_score) = a
      let #(b, b_score) = b
      {
        a_score
        + int.absolute_value(a.x - max_dimension)
        + int.absolute_value(a.y - max_dimension)
      }
      |> int.compare(
        b_score
        + int.absolute_value(b.x - max_dimension)
        + int.absolute_value(b.y - max_dimension),
      )
    })
  let assert Ok(answer) =
    list.range(1, walls_list |> list.length)
    |> list.filter(fn(n) {
      let walls = walls_list |> list.take(n) |> set.from_list
      pathfind(walls, dict.new(), queue, max_dimension) |> result.is_error
    })
    |> list.reduce(int.min)
  answer
}

fn solve_part_2(input: String) -> String {
  let walls_list = parse_input(input)
  let n = walls_list |> first_blocking_byte
  let assert Ok(Pos2d(x, y)) = walls_list |> list.drop(n - 1) |> list.first
  int.to_string(x) <> "," <> int.to_string(y)
}
