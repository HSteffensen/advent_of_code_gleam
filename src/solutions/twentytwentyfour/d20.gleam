import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/position.{type Pos2d, Pos2d}
import common/util
import gleam/bool
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 20),
    solve_part_1,
    solve_part_2,
  )
}

type MazeEntity {
  Wall
  Empty
  End
  Start
}

fn parse_input(input: String) -> Dict(Pos2d, MazeEntity) {
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
        "S" -> #(Pos2d(x, y), Start)
        "E" -> #(Pos2d(x, y), End)
        _ -> panic as "impossible input character"
      }
    })
  })
  |> list.flatten
  |> dict.from_list
}

type Cheat {
  NotYet
  Cheating1
  Cheating2
  Done
}

fn distances_to_end(grid: Dict(Pos2d, MazeEntity)) -> Dict(Pos2d, Int) {
  let assert Ok(end_pos) =
    grid
    |> dict.to_list
    |> list.filter_map(fn(entry) {
      case entry {
        #(p, End) -> Ok(p)
        _ -> Error(Nil)
      }
    })
    |> list.first
  distances_to_end_dfs(grid, dict.new(), end_pos, 0)
}

fn distances_to_end_dfs(
  grid: Dict(Pos2d, MazeEntity),
  visited: Dict(Pos2d, Int),
  pos: Pos2d,
  distance: Int,
) -> Dict(Pos2d, Int) {
  use <- bool.guard(
    case visited |> dict.get(pos) {
      Ok(d) if d <= distance -> True
      _ -> False
    },
    visited,
  )
  let assert Ok(entity) = grid |> dict.get(pos)
  case entity {
    Wall -> visited
    _ -> {
      let visited = visited |> dict.insert(pos, distance)
      pos
      |> position.neighbors4
      |> list.fold(visited, fn(visited, pos) {
        distances_to_end_dfs(grid, visited, pos, distance + 1)
      })
    }
  }
}

fn find_all_cheat_times(
  grid: Dict(Pos2d, MazeEntity),
  distances: Dict(Pos2d, Int),
) -> Dict(#(Pos2d, Pos2d), Int) {
  grid
  |> dict.to_list
  |> list.flat_map(fn(entry) {
    let #(pos, entity) = entry
    case entity {
      Wall -> {
        use farthest_neighbor_from_end <- util.result_guard(
          pos
            |> position.neighbors4
            |> list.filter_map(dict.get(distances, _))
            |> list.reduce(int.max),
          [],
        )
        pos
        |> position.neighbors4
        |> list.filter_map(fn(neighbor) {
          use neighbor_distance_to_end <- result.try(dict.get(
            distances,
            neighbor,
          ))
          case farthest_neighbor_from_end - neighbor_distance_to_end - 2 {
            d if d > 0 -> Ok(#(#(pos, neighbor), d))
            _ -> Error(Nil)
          }
        })
      }

      _ -> []
    }
  })
  |> dict.from_list
}

// fn find_all_cheat_times_up_to_old(
//   grid: Dict(Pos2d, MazeEntity),
//   distances: Dict(Pos2d, Int),
//   picoseconds: Int,
// ) -> Dict(#(Pos2d, Pos2d), Int) {
//   grid
//   |> dict.to_list
//   |> list.filter_map(fn(entry) {
//     let #(pos, entity) = entry
//     case entity {
//       Wall ->
//         pos
//         |> position.neighbors4
//         |> list.filter_map(dict.get(distances, _))
//         |> list.reduce(int.max)
//         |> result.map(fn(d) { #(pos, d) })
//       _ -> Error(Nil)
//     }
//   })
//   |> list.flat_map(fn(entry) {
//     let #(first_wall_pos, initial_distance_from_end) = entry
//     // TODO: BFS to get all the ways to exit the wall, and the distance saved by the cheat
//     find_lowest_cheat_remaining_distances(
//       grid,
//       distances,
//       picoseconds,
//       dict.new(),
//       Error(Nil),
//       deque.from_list([#(first_wall_pos, 1)]),
//     )
//     |> list.map(fn(cheat) {
//       let #(cheat_end_pos, cheat_distance) = cheat
//       #(
//         #(first_wall_pos, cheat_end_pos),
//         initial_distance_from_end - cheat_distance,
//       )
//     })
//   })
//   |> dict.from_list
// }

fn find_all_cheat_times_up_to(
  //   grid: Dict(Pos2d, MazeEntity),
  distances: Dict(Pos2d, Int),
  picoseconds: Int,
) -> Dict(#(Pos2d, Pos2d), Int) {
  distances
  |> dict.to_list
  |> list.flat_map(fn(entry) {
    let #(pos, distance) = entry
    find_lowest_cheat_remaining_distances(distances, picoseconds, pos, distance)
  })
  |> dict.from_list
}

fn find_lowest_cheat_remaining_distances(
  distances: Dict(Pos2d, Int),
  picoseconds: Int,
  pos: Pos2d,
  pos_distance: Int,
) -> List(#(#(Pos2d, Pos2d), Int)) {
  distances
  |> dict.to_list
  |> list.filter_map(fn(entry) {
    let #(p2, d2) = entry
    case
      int.absolute_value(p2.x - pos.x) + int.absolute_value(p2.y - pos.y),
      pos_distance - d2
    {
      a, _ if a > picoseconds -> Error(Nil)
      a, b if b <= a -> Error(Nil)
      a, _ -> Ok(#(#(pos, p2), pos_distance - d2 - a))
    }
  })
}

// fn find_lowest_cheat_remaining_distances_old(
//   grid: Dict(Pos2d, MazeEntity),
//   distances: Dict(Pos2d, Int),
//   max_picoseconds: Int,
//   visited: Dict(Pos2d, Int),
//   found_so_far: List(#(Pos2d, Int)),
//   queue: Deque(#(Pos2d, Int)),
// ) -> List(#(Pos2d, Int)) {
//   //   queue |> deque.to_list |> io.debug
//   use #(#(pos, elapsed_picoseconds), queue) <- util.result_guard(
//     queue |> deque.pop_front,
//     lowest_so_far,
//   )
//   use <- bool.lazy_guard(elapsed_picoseconds == max_picoseconds, fn() {
//     find_lowest_cheat_remaining_distance(
//       grid,
//       distances,
//       max_picoseconds,
//       visited,
//       lowest_so_far,
//       queue,
//     )
//   })
//   use <- bool.lazy_guard(
//     case visited |> dict.get(pos) {
//       Ok(ps) if ps <= elapsed_picoseconds -> True
//       _ -> False
//     },
//     fn() {
//       find_lowest_cheat_remaining_distance(
//         grid,
//         distances,
//         max_picoseconds,
//         visited,
//         lowest_so_far,
//         queue,
//       )
//     },
//   )
//   let visited = visited |> dict.insert(pos, elapsed_picoseconds)

//   let #(queue, lowest_so_far) =
//     pos
//     |> position.neighbors4
//     |> list.fold(#(queue, lowest_so_far), fn(acc, pos) {
//       let #(queue, lowest_so_far) = acc
//       case grid |> dict.get(pos), distances |> dict.get(pos) {
//         Error(Nil), Error(Nil) -> acc
//         Error(Nil), Ok(_) -> panic as "impossible grid state"
//         Ok(Wall), Error(Nil) -> #(
//           queue |> deque.push_back(#(pos, elapsed_picoseconds + 1)),
//           lowest_so_far,
//         )
//         Ok(Wall), Ok(_) -> panic as "impossible grid state"
//         Ok(_), Ok(distance) -> {
//           let cheat_distance = distance + elapsed_picoseconds + 1
//           #(
//             queue,
//             lowest_so_far
//               |> result.map(fn(v) {
//                 let #(_, d) = v
//                 case cheat_distance < d {
//                   True -> #(pos, cheat_distance)
//                   False -> v
//                 }
//               })
//               |> result.or(Ok(#(pos, cheat_distance))),
//           )
//         }
//         Ok(_), Error(Nil) -> panic as "impossible grid state"
//       }
//     })
//   find_lowest_cheat_remaining_distance(
//     grid,
//     distances,
//     max_picoseconds,
//     visited,
//     lowest_so_far,
//     queue,
//   )
// }

fn solve_part_1(input: String) -> String {
  let cheat_threshold = case input |> string.length < 300 {
    True -> 20
    False -> 100
  }
  let grid = parse_input(input)
  let distances = distances_to_end(grid)
  // |> io.debug
  find_all_cheat_times_up_to(distances, 2)
  |> dict.to_list
  //   |> io.debug
  |> list.filter(fn(cheat) {
    let #(_, cheat_save) = cheat
    cheat_save >= cheat_threshold
  })
  //   |> io.debug
  |> list.length
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  let cheat_threshold = case input |> string.length < 300 {
    True -> 75
    False -> 100
  }
  let grid = parse_input(input)
  let distances = distances_to_end(grid)
  find_all_cheat_times_up_to(distances, 20)
  |> dict.to_list
  |> list.filter(fn(cheat) {
    let #(_, cheat_save) = cheat
    cheat_save >= cheat_threshold
  })
  //   |> io.debug
  |> list.length
  |> int.to_string
}
