import common/adventofcode/advent_of_code
import common/adventofcode/solution
import common/position.{type Pos2d, Pos2d}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 12),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> Dict(Pos2d, String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(plant, x) { #(Pos2d(x, y), plant) })
  })
  |> list.flatten
  |> dict.from_list
}

type Border {
  Border(inner: Pos2d, outer: Pos2d)
}

type Region {
  Region(plant: String, positions: Set(Pos2d), borders: Set(Border))
}

fn combine_regions(a: Region, b: Region) -> Region {
  case a.plant == b.plant {
    False -> panic as "unexpected plants"
    True ->
      Region(
        a.plant,
        a.positions |> set.union(b.positions),
        a.borders |> set.union(b.borders),
      )
  }
}

fn connect_region(
  grid: Dict(Pos2d, String),
  pos: Pos2d,
  visited: Set(Pos2d),
) -> #(Set(Pos2d), Region) {
  let assert Ok(plant) = grid |> dict.get(pos)
  use <- bool.guard(visited |> set.contains(pos), #(
    visited,
    Region(plant, set.new(), set.new()),
  ))
  let visited = visited |> set.insert(pos)
  let #(visited, search_list) =
    pos
    |> position.neighbors4
    |> list.map_fold(visited, fn(visited, pos2) {
      case grid |> dict.get(pos2) {
        Ok(plant2) if plant2 == plant -> {
          let #(visited, region) = connect_region(grid, pos2, visited)
          #(visited, Ok(region))
        }
        _ -> #(visited, Error(pos2))
      }
    })
  #(
    visited,
    search_list
      |> list.fold(
        Region(plant, set.new() |> set.insert(pos), set.new()),
        fn(region, search_result) {
          case search_result {
            Error(pos2) ->
              Region(
                region.plant,
                region.positions,
                region.borders |> set.insert(Border(pos, pos2)),
              )
            Ok(region2) -> combine_regions(region, region2)
          }
        },
      ),
  )
}

fn build_regions(grid: Dict(Pos2d, String)) -> List(Region) {
  let #(_, regions) =
    grid
    |> dict.keys
    |> list.map_fold(set.new(), fn(visited, pos) {
      connect_region(grid, pos, visited)
    })
  regions
}

fn region_price(region: Region) -> Int {
  { region.positions |> set.size } * { region.borders |> set.size }
}

fn distinct_sides_count(edges: Set(Border)) -> Int {
  use <- bool.guard(edges |> set.is_empty, 0)

  let edges_list =
    edges
    |> set.to_list
  let horizontal_sides =
    edges_list
    |> list.filter(fn(p) { p.inner.y == p.outer.y })
    |> list.group(fn(p) { #(p.inner.x, p.outer.x) })
    |> dict.values
    |> list.map(fn(pairs) {
      {
        pairs
        |> list.sort(fn(a, b) { int.compare(a.inner.y, b.inner.y) })
        |> list.window_by_2
        |> list.count(fn(p) {
          let #(a, b) = p
          a.inner.y != b.inner.y - 1
        })
      }
      + 1
    })
    |> int.sum
  let vertical_sides =
    edges_list
    |> list.filter(fn(p) { p.inner.x == p.outer.x })
    |> list.group(fn(p) { #(p.inner.y, p.outer.y) })
    |> dict.values
    |> list.map(fn(pairs) {
      {
        pairs
        |> list.sort(fn(a, b) { int.compare(a.inner.x, b.inner.x) })
        |> list.window_by_2
        |> list.count(fn(p) {
          let #(a, b) = p
          a.inner.x != b.inner.x - 1
        })
      }
      + 1
    })
    |> int.sum
  horizontal_sides + vertical_sides
}

fn region_price_2(region: Region) -> Int {
  { region.positions |> set.size } * { distinct_sides_count(region.borders) }
}

fn solve_part_1(input: String) -> String {
  let grid = parse_input(input)
  build_regions(grid)
  |> list.map(region_price)
  |> int.sum
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  let grid = parse_input(input)
  build_regions(grid)
  |> list.map(region_price_2)
  |> int.sum
  |> int.to_string
}
