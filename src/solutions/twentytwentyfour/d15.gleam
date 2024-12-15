import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/position.{type Direction, type Pos2d, Pos2d}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 15),
    solve_part_1,
    solve_part_2,
  )
}

type Entity {
  Box
  Wall
}

type Warehouse {
  Warehouse(robot: Pos2d, grid: Dict(Pos2d, Entity))
}

fn warehouse_pretty_print(warehouse: Warehouse) -> Warehouse {
  let xs = warehouse.grid |> dict.keys |> list.map(fn(p) { p.x })
  let assert Ok(max_x) = xs |> list.reduce(int.max)
  let ys = warehouse.grid |> dict.keys |> list.map(fn(p) { p.y })
  let assert Ok(max_y) = ys |> list.reduce(int.max)

  list.range(0, max_y)
  |> list.map(fn(y) {
    list.range(0, max_x)
    |> list.map(fn(x) {
      let pos = Pos2d(x, y)
      case warehouse.robot == pos, warehouse.grid |> dict.get(pos) {
        True, Error(Nil) -> "@"
        False, Ok(Wall) -> "#"
        False, Ok(Box) -> "O"
        False, Error(Nil) -> "."
        _, _ -> panic as "impossible warehouse printout"
      }
    })
    |> string.join("")
    |> io.println
  })
  warehouse
}

fn find_robot(input: String) -> Pos2d {
  let assert Ok(pos) =
    input
    |> string.trim
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(c, x) {
        case c {
          "@" -> Ok(Pos2d(x, y))
          _ -> Error(Nil)
        }
      })
    })
    |> list.flatten
    |> result.values
    |> list.first
  pos
}

fn parse_warehouse_grid(input: String) -> Dict(Pos2d, Entity) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(c, x) {
      case c {
        "#" -> Ok(#(Pos2d(x, y), Wall))
        "O" -> Ok(#(Pos2d(x, y), Box))
        "@" -> Error(Nil)
        // empty
        "." -> Error(Nil)
        // empty
        _ -> panic as "impossible warehouse entity"
      }
    })
  })
  |> list.flatten
  |> result.values
  |> dict.from_list
}

fn parse_directions(input: String) -> List(Direction) {
  input
  |> string.trim
  |> string.replace("\n", "")
  |> string.to_graphemes
  |> list.map(fn(c) {
    case c {
      "^" -> position.North
      "v" -> position.South
      "<" -> position.West
      ">" -> position.East
      _ -> panic as "impossible direction"
    }
  })
}

fn parse_input(input: String) -> #(Warehouse, List(Direction)) {
  let assert Ok(#(warehouse, directions)) = input |> string.split_once("\n\n")
  #(
    Warehouse(find_robot(warehouse), parse_warehouse_grid(warehouse)),
    parse_directions(directions),
  )
}

fn push_box(
  grid: Dict(Pos2d, Entity),
  pos: Pos2d,
  direction: Direction,
) -> Result(Dict(Pos2d, Entity), Nil) {
  let next_pos = pos |> position.step(direction)
  case grid |> dict.get(next_pos) {
    Error(Nil) -> Ok(grid)
    // step into empty space
    Ok(Wall) -> Error(Nil)
    // fail to step into a wall
    Ok(Box) -> {
      // attempt to push that box too
      push_box(grid, next_pos, direction)
      |> result.map(fn(new_grid) {
        let next_next_pos = next_pos |> position.step(direction)
        new_grid
        |> dict.drop([next_pos])
        |> dict.insert(next_next_pos, Box)
      })
    }
  }
}

fn move_robot(warehouse: Warehouse, direction: Direction) -> Warehouse {
  let Warehouse(robot, grid) = warehouse
  case push_box(grid, robot, direction) {
    Ok(new_grid) -> Warehouse(robot |> position.step(direction), new_grid)
    Error(Nil) -> warehouse
  }
}

fn box_gps_score(warehouse: Warehouse) -> Int {
  warehouse.grid
  |> dict.to_list
  |> list.map(fn(entry) {
    case entry {
      #(Pos2d(x, y), Box) -> x + { 100 * y }
      _ -> 0
    }
  })
  |> int.sum
}

fn solve_part_1(input: String) -> String {
  let #(warehouse, directions) = parse_input(input)
  directions
  |> list.fold(warehouse, move_robot)
  |> box_gps_score
  |> int.to_string
}

fn wide_warehouse_pretty_print(warehouse: Warehouse) -> Warehouse {
  let xs = warehouse.grid |> dict.keys |> list.map(fn(p) { p.x })
  let assert Ok(max_x) = xs |> list.reduce(int.max)
  let ys = warehouse.grid |> dict.keys |> list.map(fn(p) { p.y })
  let assert Ok(max_y) = ys |> list.reduce(int.max)

  list.range(0, max_y)
  |> list.map(fn(y) {
    list.range(0, max_x)
    |> list.map(fn(x) {
      let pos = Pos2d(x, y)
      case
        warehouse.robot == pos,
        warehouse.grid |> dict.get(pos |> position.step(position.West)),
        warehouse.grid |> dict.get(pos),
        warehouse.grid |> dict.get(pos |> position.step(position.East))
      {
        True, _, _, _ -> "@"
        False, _, Ok(Box), Error(Nil) -> "["
        False, Ok(Box), Error(Nil), _ -> "]"
        False, _, Ok(Wall), _ -> "#"
        False, _, Error(Nil), _ -> "."
        _, _, _, _ -> panic as "impossible warehouse printout"
      }
    })
    |> string.join("")
    |> io.println
  })
  warehouse
}

fn find_wide_robot(input: String) -> Pos2d {
  let assert Ok(pos) =
    input
    |> string.trim
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(c, x) {
        case c {
          "@" -> Ok(Pos2d(2 * x, y))
          _ -> Error(Nil)
        }
      })
    })
    |> list.flatten
    |> result.values
    |> list.first
  pos
}

fn parse_wide_warehouse_grid(input: String) -> Dict(Pos2d, Entity) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(c, x) {
      case c {
        "#" -> [#(Pos2d(2 * x, y), Wall), #(Pos2d(2 * x + 1, y), Wall)]
        "O" -> [#(Pos2d(2 * x, y), Box)]
        "@" -> []
        // empty
        "." -> []
        // empty
        _ -> panic as "impossible warehouse entity"
      }
    })
    |> list.flatten
  })
  |> list.flatten
  |> dict.from_list
}

fn parse_wide_input(input: String) -> #(Warehouse, List(Direction)) {
  let assert Ok(#(warehouse, directions)) = input |> string.split_once("\n\n")
  #(
    Warehouse(find_wide_robot(warehouse), parse_wide_warehouse_grid(warehouse)),
    parse_directions(directions),
  )
}

fn push_wide_box_north_south(
  grid: Dict(Pos2d, Entity),
  pos: Pos2d,
  is_north: Bool,
) -> Result(Dict(Pos2d, Entity), Nil) {
  let direction = case is_north {
    False -> position.South
    True -> position.North
  }
  let up1 = pos |> position.step(direction)
  let up1left = up1 |> position.step(position.West)
  let up1right = up1 |> position.step(position.East)
  case
    grid |> dict.get(up1left),
    grid |> dict.get(up1),
    grid |> dict.get(up1right)
  {
    Ok(Box), Error(Nil), _ -> move_wide_box_north_south(grid, up1left, is_north)
    Ok(Box), _, _ -> panic as "impossible box 1"
    _, Ok(Box), Error(Nil) -> move_wide_box_north_south(grid, up1, is_north)
    _, Ok(Box), _ -> panic as "impossible box 2"
    _, Ok(Wall), _ -> Error(Nil)
    _, Error(Nil), _ -> Ok(grid)
  }
}

fn move_wide_box_north_south(
  grid: Dict(Pos2d, Entity),
  pos: Pos2d,
  is_north: Bool,
) -> Result(Dict(Pos2d, Entity), Nil) {
  let direction = case is_north {
    False -> position.South
    True -> position.North
  }
  let assert Ok(Box) = grid |> dict.get(pos)
  let up1 = pos |> position.step(direction)
  let up1left = up1 |> position.step(position.West)
  let up1right1 = up1 |> position.step(position.East)
  let up1right2 = up1right1 |> position.step(position.East)

  case
    grid |> dict.get(up1left),
    grid |> dict.get(up1),
    grid |> dict.get(up1right1),
    grid |> dict.get(up1right2)
  {
    _, Ok(Wall), _, _ -> Error(Nil)
    _, _, Ok(Wall), _ -> Error(Nil)
    Ok(Box), Error(Nil), Ok(Box), Error(Nil) ->
      move_wide_box_north_south(grid, up1left, is_north)
      |> result.then(move_wide_box_north_south(_, up1right1, is_north))
    Ok(Box), _, Ok(Box), _ -> panic as "impossible box 3"
    Ok(Box), Error(Nil), Error(Nil), _ ->
      move_wide_box_north_south(grid, up1left, is_north)
    Ok(Box), _, _, _ -> panic as "impossible box 4"
    _, Error(Nil), Ok(Box), Error(Nil) ->
      move_wide_box_north_south(grid, up1right1, is_north)
    _, _, Ok(Box), _ -> panic as "impossible box 5"
    _, Ok(Box), Error(Nil), _ -> move_wide_box_north_south(grid, up1, is_north)
    // _, Ok(Box), _, _ -> panic as "impossible box 6" // actually impossible according to the compiler :)
    _, Error(Nil), Error(Nil), _ -> Ok(grid)
  }
  |> result.map(fn(next_grid) {
    next_grid |> dict.drop([pos]) |> dict.insert(up1, Box)
  })
}

fn push_wide_box_west(
  grid: Dict(Pos2d, Entity),
  pos: Pos2d,
) -> Result(Dict(Pos2d, Entity), Nil) {
  let next_pos = pos |> position.step(position.West)
  let next_next_pos = next_pos |> position.step(position.West)
  case grid |> dict.get(next_next_pos), grid |> dict.get(next_pos) {
    Ok(Box), Error(Nil) -> {
      push_wide_box_west(grid, next_next_pos)
      |> result.map(fn(next_grid) {
        let next_box_pos =
          next_next_pos
          |> position.step(position.West)
        next_grid
        |> dict.drop([next_next_pos])
        |> dict.insert(next_box_pos, Box)
      })
    }
    Ok(Box), _ -> panic as "impossible box 7"
    _, Ok(Box) -> panic as "impossible box 8"
    _, Error(Nil) -> Ok(grid)
    _, Ok(Wall) -> Error(Nil)
  }
}

fn push_wide_box_east(
  grid: Dict(Pos2d, Entity),
  pos: Pos2d,
) -> Result(Dict(Pos2d, Entity), Nil) {
  let next_pos = pos |> position.step(position.East)
  let next_next_pos = next_pos |> position.step(position.East)
  //   next_pos |> io.debug
  //   next_next_pos |> io.debug
  //   #(grid |> dict.get(next_pos), grid |> dict.get(next_next_pos)) |> io.debug
  case grid |> dict.get(next_pos), grid |> dict.get(next_next_pos) {
    Ok(Box), Error(Nil) -> {
      push_wide_box_east(grid, next_next_pos)
      |> result.map(fn(next_grid) {
        next_grid
        |> dict.drop([next_pos])
        |> dict.insert(next_next_pos, Box)
      })
    }
    Ok(Box), _ -> panic as "impossible box 9"
    Error(Nil), _ -> Ok(grid)
    Ok(Wall), _ -> Error(Nil)
  }
}

fn push_wide_box(
  grid: Dict(Pos2d, Entity),
  pos: Pos2d,
  direction: Direction,
) -> Result(Dict(Pos2d, Entity), Nil) {
  case direction {
    position.North -> push_wide_box_north_south(grid, pos, True)
    position.South -> push_wide_box_north_south(grid, pos, False)
    position.West -> push_wide_box_west(grid, pos)
    position.East -> push_wide_box_east(grid, pos)
  }
}

fn move_wide_robot(warehouse: Warehouse, direction: Direction) -> Warehouse {
  //   direction |> string.inspect |> io.println
  //   warehouse |> wide_warehouse_pretty_print
  let Warehouse(robot, grid) = warehouse
  case push_wide_box(grid, robot, direction) {
    Ok(new_grid) -> Warehouse(robot |> position.step(direction), new_grid)
    Error(Nil) -> warehouse
  }
}

fn solve_part_2(input: String) -> String {
  let #(warehouse, directions) = parse_wide_input(input)
  directions
  |> list.fold(warehouse, move_wide_robot)
  |> box_gps_score
  |> int.to_string
}
