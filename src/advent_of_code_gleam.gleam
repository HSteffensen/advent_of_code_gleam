import common/adventofcode/auth
import gleam/io

pub fn main() {
  let session = auth.get_session_or_ask_human()
  io.println(session)
}
