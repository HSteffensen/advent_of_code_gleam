import gleeunit
import gleeunit/should
import tempo/date
import tempo/datetime
import tempo/period

pub fn main() {
  gleeunit.main()
}

pub fn tempo_datetime_period_test() {
  let assert Ok(test_datetime) =
    datetime.from_string("2024-12-11T08:55:32.424420250Z")
  let difference = datetime.as_period(test_datetime, test_datetime)
  difference |> period.as_seconds |> should.equal(0)
}

pub fn tempo_date_period_test() {
  let assert Ok(test_date) = date.from_string("2024-12-11")
  let difference = date.as_period(test_date, test_date)
  difference |> period.as_days |> should.equal(0)
}
