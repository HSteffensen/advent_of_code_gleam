import common/adventofcode/advent_of_code.{type PuzzleId, type PuzzlePart}
import common/adventofcode/answer
import common/adventofcode/examples
import common/adventofcode/input
import common/adventofcode/website
import gleam/bool
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result

pub fn solve_advent(
  puzzle: PuzzleId,
  part1: fn(String) -> String,
  part2: fn(String) -> String,
) -> Result(Bool, website.AdventOfCodeError) {
  let day_string = advent_of_code.day_string(puzzle)
  io.println("Running solution for " <> day_string)
  use part1_solved <- result.try(solve_advent_part(
    puzzle,
    advent_of_code.Part1,
    part1,
  ))
  use <- bool.lazy_guard(!part1_solved, fn() {
    io.println(day_string <> " part 1 wrong.")
    Ok(False)
  })
  io.println(day_string <> " part 1 correct!")
  solve_advent_part(puzzle, advent_of_code.Part2, part2)
  |> result.map(fn(part2_solved) {
    case part2_solved {
      True -> io.println(day_string <> " part 2 correct!")
      False -> io.println(day_string <> " part 2 wrong.")
    }
    part2_solved
  })
}

fn solve_advent_part(
  puzzle: PuzzleId,
  part: PuzzlePart,
  solution: fn(String) -> String,
) -> Result(Bool, website.AdventOfCodeError) {
  use examples <- result.try(examples.get_examples_or_ask_human(puzzle, part))
  let pass_examples =
    examples
    |> list.map(fn(example) {
      let examples.PuzzleExample(
        number: number,
        input: example_input,
        answer: example_answer,
      ) = example
      let solution_answer = solution(example_input)
      let pass_example = solution_answer == example_answer
      case pass_example {
        False ->
          io.println(
            "Failed example "
            <> int.to_string(number)
            <> ": expected '"
            <> example_answer
            <> "'; got '"
            <> solution_answer
            <> "'",
          )
        True -> Nil
      }
      pass_example
    })
    |> list.all(function.identity)
  use <- bool.guard(!pass_examples, Ok(False))
  use input <- result.try(input.get_puzzle_input(puzzle))
  answer.submit_answer(puzzle, part, solution(input))
}
