import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 8),
    solve_part_1,
    solve_part_2,
  )
}

type AntennaGrid {
  AntennaGrid(
    width: Int,
    height: Int,
    antennas: dict.Dict(String, List(#(Int, Int))),
  )
}

fn parse_input(input: String) -> AntennaGrid {
  let lines = input |> string.trim |> string.split("\n")
  let height = lines |> list.length
  let assert Ok(width) = lines |> list.first |> result.map(string.length)
  let antennas =
    lines
    |> list.index_map(fn(line, y) {
      line |> string.to_graphemes |> list.index_map(fn(c, x) { #(c, x, y) })
    })
    |> list.flatten
    |> list.filter(fn(it) {
      case it {
        #(".", _, _) -> False
        _ -> True
      }
    })
    |> list.group(fn(it) {
      let #(c, _, _) = it
      c
    })
    |> dict.map_values(fn(_, it) {
      it
      |> list.map(fn(it2) {
        let #(_, x, y) = it2
        #(x, y)
      })
    })
  AntennaGrid(width, height, antennas)
}

fn antinodes(pair: #(#(Int, Int), #(Int, Int))) -> List(#(Int, Int)) {
  let #(a, b) = pair
  let #(ax, ay) = a
  let #(bx, by) = b
  let dx = bx - ax
  let dy = by - ay
  [#(ax - dx, ay - dy), #(bx + dx, by + dy)]
}

fn antinodes_2(
  pair: #(#(Int, Int), #(Int, Int)),
  iterations: Int,
) -> List(#(Int, Int)) {
  let #(a, b) = pair
  let #(ax, ay) = a
  let #(bx, by) = b
  let dx = bx - ax
  let dy = by - ay
  list.range(0, iterations - 1)
  |> list.map(fn(i) { #(ax - i * dx, ay - i * dy) })
  |> list.append(
    list.range(0, iterations - 1)
    |> list.map(fn(i) { #(bx + i * dx, by + i * dy) }),
  )
}

fn inside_bounds(
  xmin: Int,
  xmax: Int,
  ymin: Int,
  ymax: Int,
  pos: #(Int, Int),
) -> Bool {
  let #(x, y) = pos
  x >= xmin && x < xmax && y >= ymin && y < ymax
}

fn solve_part_1(input: String) -> String {
  let grid = parse_input(input)
  grid.antennas
  |> dict.values
  |> list.flat_map(fn(antennas) {
    antennas |> list.combination_pairs |> list.flat_map(antinodes)
  })
  |> list.filter(inside_bounds(0, grid.width, 0, grid.height, _))
  |> list.unique
  |> list.length
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  let grid = parse_input(input)
  grid.antennas
  |> dict.values
  |> list.flat_map(fn(antennas) {
    antennas
    |> list.combination_pairs
    |> list.flat_map(antinodes_2(_, int.max(grid.width, grid.height)))
  })
  |> list.filter(inside_bounds(0, grid.width, 0, grid.height, _))
  |> list.unique
  |> list.length
  |> int.to_string
}
