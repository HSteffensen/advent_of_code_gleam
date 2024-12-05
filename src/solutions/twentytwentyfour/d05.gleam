import common/adventofcode/advent_of_code
import common/adventofcode/solution
import gleam/bool
import gleam/int
import gleam/list
import gleam/regexp
import gleam/string

pub fn main() {
  solution.solve_advent(
    advent_of_code.PuzzleId(2024, 5),
    solve_part_1,
    solve_part_2,
  )
}

type ManualsInput {
  ManualsInput(rules: List(PageRule), print_jobs: List(String))
}

type PageRule {
  PageRule(first: String, second: String)
}

fn parse_input(input: String) -> ManualsInput {
  let assert Ok(#(rules, jobs)) =
    input |> string.trim |> string.split_once("\n\n")
  ManualsInput(
    rules: rules
      |> string.split("\n")
      |> list.map(fn(line) {
        let assert Ok(#(a, b)) = line |> string.split_once("|")
        PageRule(a, b)
      }),
    print_jobs: jobs |> string.split("\n"),
  )
}

fn follows_rule(print_job: String, rule: PageRule) -> Bool {
  let assert Ok(re) =
    regexp.from_string(
      "\\b" <> rule.second <> "\\b.*\\b" <> rule.first <> "\\b",
    )
  regexp.check(re, print_job) |> bool.negate
}

fn middle_number(print_job: String) -> Int {
  let pages = print_job |> string.split(",")
  let assert Ok(num_string) =
    pages |> list.drop(list.length(pages) / 2) |> list.first
  let assert Ok(num) = int.parse(num_string)
  num
}

fn solve_part_1(input: String) -> String {
  let input = parse_input(input)
  input.print_jobs
  |> list.filter(fn(job) { input.rules |> list.all(follows_rule(job, _)) })
  |> list.map(middle_number)
  |> int.sum
  |> int.to_string
}

fn fix_print_job(print_job: String, rules: List(PageRule)) -> String {
  rules |> list.fold(print_job, fix_print_job_with_rule)
}

fn fix_print_job_with_rule(print_job: String, rule: PageRule) -> String {
  case follows_rule(print_job, rule) {
    True -> print_job
    False -> {
      print_job
      |> string.replace(rule.first, "xx")
      |> string.replace(rule.second, rule.first)
      |> string.replace("xx", rule.second)
    }
  }
}

fn solve_part_2(input: String) -> String {
  let input = parse_input(input)
  input.print_jobs
  |> list.filter(fn(job) {
    input.rules |> list.all(follows_rule(job, _)) |> bool.negate
  })
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(fix_print_job(_, input.rules))
  |> list.map(middle_number)
  |> int.sum
  |> int.to_string
}
