import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/position.{type Pos2d, Pos2d}
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 14),
    solve_part_1,
    solve_part_2,
  )
}

type Robot {
  Robot(pos: Pos2d, velocity: Pos2d)
}

fn parse_robot(line: String) -> Robot {
  let line = line |> string.drop_start(2)
  let assert Ok(#(p, v)) = line |> string.split_once(" v=")
  let assert Ok(#(px, py)) = p |> string.split_once(",")
  let assert Ok(#(vx, vy)) = v |> string.split_once(",")
  let assert Ok(px) = int.parse(px)
  let assert Ok(py) = int.parse(py)
  let assert Ok(vx) = int.parse(vx)
  let assert Ok(vy) = int.parse(vy)

  Robot(Pos2d(px, py), Pos2d(vx, vy))
}

fn parse_input(input: String) -> #(Pos2d, List(Robot)) {
  let robots =
    input |> string.trim |> string.split("\n") |> list.map(parse_robot)
  let assert Ok(max_x) =
    robots |> list.map(fn(r) { r.pos.x }) |> list.reduce(int.max)
  case max_x >= 11 {
    True -> #(Pos2d(101, 103), robots)
    False -> #(Pos2d(11, 7), robots)
  }
}

fn step_robots(robots: List(Robot), steps: Int, room_size: Pos2d) -> List(Robot) {
  robots
  |> list.map(fn(r) {
    let assert Ok(new_x) =
      int.modulo(r.pos.x + { r.velocity.x * steps }, room_size.x)
    let assert Ok(new_y) =
      int.modulo(r.pos.y + { r.velocity.y * steps }, room_size.y)
    Robot(Pos2d(new_x, new_y), r.velocity)
  })
}

fn safety_factor(robots: List(Robot), room_size: Pos2d) -> Int {
  let mid_x = room_size.x / 2
  let mid_y = room_size.y / 2
  let nw_quadrant_count =
    robots
    |> list.count(fn(r) { r.pos.x < mid_x && r.pos.y < mid_y })
  let ne_quadrant_count =
    robots
    |> list.count(fn(r) { r.pos.x > mid_x && r.pos.y < mid_y })
  let sw_quadrant_count =
    robots
    |> list.count(fn(r) { r.pos.x < mid_x && r.pos.y > mid_y })
  let se_quadrant_count =
    robots
    |> list.count(fn(r) { r.pos.x > mid_x && r.pos.y > mid_y })

  nw_quadrant_count * ne_quadrant_count * sw_quadrant_count * se_quadrant_count
}

fn solve_part_1(input: String) -> String {
  let #(room_size, robots) = parse_input(input)
  safety_factor(step_robots(robots, 100, room_size), room_size)
  |> int.to_string
}

fn pretty_print(robots: List(Robot), room_size: Pos2d) -> List(Robot) {
  let positions = robots |> list.map(fn(r) { r.pos }) |> set.from_list
  list.range(0, room_size.y - 1)
  |> list.map(fn(y) {
    list.range(0, room_size.x - 1)
    |> list.map(fn(x) {
      case positions |> set.contains(Pos2d(x, y)) {
        False -> " "
        True -> "X"
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println
  robots
}

fn solve_part_2(input: String) -> String {
  use <- bool.guard(input == "", "0")
  let #(room_size, robots) = parse_input(input)
  list.range(1, 1000)
  |> list.fold(robots, fn(r, step) {
    io.println("step " <> int.to_string(step))
    step_robots(r, 1, room_size) |> pretty_print(room_size)
  })
  panic as "check output manually"
  // step 18: strange vertical arrangement
  // step 119: strange vertical arrangement
  // so we expect strange vertical arrangement every 18+101n steps?
  // step 76: strange horizontal arrangement
  // step 179: strange horizontal arrangement
  // so we expect strange horizontal arrangement every 76+103n steps?
  // chinese remainder theorem: google "chinese remainder theorem calculator" -> this gave me the correct answer
}
