import common/parsing/parser
import gleeunit/should

pub fn list_single_test() {
  {
    parser.list(parser.literal("a"), parser.literal(","))
    |> parser.get_parsed_perfect()
  }("a")
  |> should.equal(Ok(["a"]))
}

pub fn list_test() {
  {
    parser.list(parser.literal("a"), parser.literal(","))
    |> parser.get_parsed_perfect()
  }("a,a,a,a")
  |> should.equal(Ok(["a", "a", "a", "a"]))
}

pub fn list_empty_test() {
  {
    parser.list(parser.literal("a"), parser.literal(","))
    |> parser.get_parsed_perfect()
  }("")
  |> should.equal(Ok(["a"]))
}
