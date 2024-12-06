import common/adventofcode/advent_of_code.{type PuzzleId, type PuzzlePart}
import common/adventofcode/answer
import common/adventofcode/examples
import common/adventofcode/input
import common/adventofcode/website
import gleam/bool
import gleam/float
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import tempo/duration

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
  use input <- result.try(input.get_puzzle_input(puzzle))
  let part_string = advent_of_code.part_int_string(part)
  io.println("Running examples for part " <> part_string <> ".")
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
      let pass_example = solution_answer == { example_answer |> string.trim }
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
  io.println("Passed all examples for part " <> part_string <> "!")
  io.println("Running solution for part " <> part_string <> ".")
  let timer = duration.start_monotonic()
  let answer = solution(input)
  let solution_time = timer |> duration.stop_monotonic()
  io.println(
    "Took "
    <> float.to_string(
      duration.as_microseconds(solution_time)
      |> int.to_float
      |> float.divide(1_000_000.0)
      |> result.unwrap(-1.0),
    )
    <> " seconds to run part "
    <> advent_of_code.part_int_string(part)
    <> ".",
  )
  io.println("Answer: " <> answer)
  answer.submit_answer(puzzle, part, answer)
}
