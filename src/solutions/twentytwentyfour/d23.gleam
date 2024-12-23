import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 23),
    solve_part_1,
    solve_part_2,
  )
}

fn parse_input(input: String) -> Set(#(String, String)) {
  let pairs =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(a, b)) = line |> string.split_once("-")
      #(a, b)
    })
  let pairs_set = pairs |> set.from_list
  pairs_set
  |> set.union(
    pairs_set
    |> set.map(fn(p) {
      let #(a, b) = p
      #(b, a)
    }),
  )
}

fn all_nodes(pairs: List(#(String, String))) -> List(String) {
  pairs
  |> list.flat_map(fn(p) {
    let #(a, b) = p
    [a, b]
  })
  |> set.from_list
  |> set.to_list
}

fn grow_cliques(
  cliques: List(Set(String)),
  nodes: List(String),
  edges: Set(#(String, String)),
) -> List(Set(String)) {
  cliques
  |> list.map(fn(clique) {
    nodes
    |> list.fold(clique, fn(clique, node) {
      case
        !set.contains(clique, node)
        && list.all(clique |> set.to_list, fn(member) {
          edges |> set.contains(#(member, node))
        })
      {
        True -> clique |> set.insert(node)
        False -> clique
      }
    })
  })
}

fn grow_cliques_until_none_larger(
  cliques: List(Set(String)),
  nodes: List(String),
  edges: Set(#(String, String)),
) -> Set(String) {
  let largest_start =
    cliques
    |> list.reduce(fn(a, b) {
      case set.size(a) |> int.compare(set.size(b)) {
        order.Lt -> b
        _ -> a
      }
    })
    |> result.lazy_unwrap(fn() { panic as "expected some cliques" })
  let grown_cliques = grow_cliques(cliques, nodes, edges)
  let largest_after =
    grown_cliques
    |> list.map(set.size)
    |> list.reduce(int.max)
    |> result.lazy_unwrap(fn() { panic as "expected some cliques" })
  case set.size(largest_start) < largest_after {
    False -> largest_start
    True -> grow_cliques_until_none_larger(grown_cliques, nodes, edges)
  }
}

fn largest_clique(pairs: Set(#(String, String))) -> Set(String) {
  let nodes = all_nodes(pairs |> set.to_list)
  let cliques = nodes |> list.map(fn(n) { set.from_list([n]) })
  grow_cliques_until_none_larger(cliques, nodes, pairs)
}

type ConnectionStartingWithT {
  ConnectionStartingWithT(t: String, other: String)
}

fn triples_containing_t(
  pairs: Set(#(String, String)),
) -> List(#(String, String, String)) {
  let pairs_containing_t =
    pairs
    |> set.to_list
    |> list.filter_map(fn(p) {
      let #(a, b) = p
      case a |> string.starts_with("t"), b |> string.starts_with("t") {
        True, True -> Ok(ConnectionStartingWithT(a, b))
        True, False -> Ok(ConnectionStartingWithT(a, b))
        False, True -> Ok(ConnectionStartingWithT(b, a))
        False, False -> Error(Nil)
      }
    })
    |> list.group(fn(p) { p.t })
  pairs_containing_t
  |> dict.to_list
  |> list.flat_map(fn(entry) {
    let #(t, connections) = entry
    connections
    |> list.map(fn(c) { c.other })
    |> list.combination_pairs
    |> list.filter(set.contains(pairs, _))
    |> list.map(fn(p) {
      let #(a, b) = p
      set.from_list([t, a, b])
    })
  })
  |> set.from_list
  |> set.to_list
  |> list.map(fn(s) {
    let assert [a, b, c] = s |> set.to_list
    #(a, b, c)
  })
}

fn solve_part_1(input: String) -> String {
  parse_input(input)
  |> triples_containing_t
  |> list.length
  |> int.to_string
}

fn solve_part_2(input: String) -> String {
  parse_input(input)
  |> largest_clique
  |> set.to_list
  |> list.sort(string.compare)
  |> string.join(",")
}
