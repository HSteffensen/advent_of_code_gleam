import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string

pub type ParseStringError {
  Expected(got: String, wanted: String)
}

pub opaque type OngoingStringParser(t) {
  OngoingStringParser(result: t, tokens: String)
}

pub fn literal(
  value: String,
) -> fn(String) -> Result(OngoingStringParser(String), ParseStringError) {
  fn(input) {
    case input |> string.starts_with(value) {
      True ->
        Ok(OngoingStringParser(
          value,
          input |> string.drop_start(string.length(value)),
        ))
      False ->
        Error(Expected(value, string.slice(input, 0, string.length(value))))
    }
  }
}

pub fn then(
  first_parser: fn(String) -> Result(OngoingStringParser(a), ParseStringError),
  second_parser: fn(String) -> Result(OngoingStringParser(b), ParseStringError),
) -> fn(String) -> Result(OngoingStringParser(#(a, b)), ParseStringError) {
  fn(input) {
    use first_result <- result.try(first_parser(input))
    use second_result <- result.try(second_parser(first_result.tokens))
    Ok(OngoingStringParser(
      #(first_result.result, second_result.result),
      second_result.tokens,
    ))
  }
}

pub fn otherwise(
  first_parser: fn(String) -> Result(OngoingStringParser(t), ParseStringError),
  second_parser: fn(String) -> Result(OngoingStringParser(t), ParseStringError),
) -> fn(String) -> Result(OngoingStringParser(t), ParseStringError) {
  fn(input) {
    first_parser(input) |> result.lazy_or(fn() { second_parser(input) })
  }
}

pub fn optional(
  parser: fn(String) -> Result(OngoingStringParser(t), ParseStringError),
) -> fn(String) -> Option(OngoingStringParser(t)) {
  fn(input) { parser(input) |> option.from_result }
}

pub fn repeat(
  parser: fn(String) -> Result(OngoingStringParser(t), ParseStringError),
) -> fn(String) -> Result(OngoingStringParser(List(t)), ParseStringError) {
  fn(input) {
    case parser(input) {
      Error(_) -> Ok(OngoingStringParser([], input))
      Ok(OngoingStringParser(r1, t1)) -> {
        let assert Ok(OngoingStringParser(r2, t2)) = repeat(parser)(t1)
        Ok(OngoingStringParser([r1, ..r2], t2))
      }
    }
  }
}

pub fn map(
  parser: fn(String) -> Result(OngoingStringParser(t), ParseStringError),
  f: fn(t) -> r,
) -> fn(String) -> Result(OngoingStringParser(r), ParseStringError) {
  fn(input) {
    parser(input)
    |> result.map(fn(o) { OngoingStringParser(f(o.result), o.tokens) })
  }
}

pub fn list(
  of_parser: fn(String) -> Result(OngoingStringParser(t), ParseStringError),
  separator: fn(String) -> Result(OngoingStringParser(_), ParseStringError),
) -> fn(String) -> Result(OngoingStringParser(List(t)), ParseStringError) {
  of_parser
  |> then(
    repeat(separator |> then(of_parser))
    |> map(fn(repeat_result_list) {
      repeat_result_list
      |> list.map(fn(a) {
        let #(_, b) = a
        b
      })
    }),
  )
  |> map(fn(a) {
    let #(first, rest) = a
    [first, ..rest]
  })
}

pub fn ignore(parser: OngoingStringParser(t)) -> String {
  parser.tokens
}

pub fn get_parsed_perfect(
  parser: fn(String) -> Result(OngoingStringParser(t), ParseStringError),
) -> fn(String) -> Result(t, ParseStringError) {
  fn(input) {
    parser(input)
    |> result.then(fn(p) {
      case p {
        OngoingStringParser(result, "") -> Ok(result)
        OngoingStringParser(_, t) -> Error(Expected(t, ""))
      }
    })
  }
}

pub fn get_parsed(parser: OngoingStringParser(t)) -> t {
  parser.result
}

pub fn main() {
  io.debug("hello" |> literal("hell"))
}
