import gleam/int
import gleam/io
import gleam/result
import simplifile

pub fn run_part(
  day day: Int,
  part part: Int,
  runner runner: fn(String) -> Result(String, String),
) {
  day
  |> get_input()
  |> result.try(runner)
  |> result.map(fn(res) {
    io.println(
      "Day "
      <> int.to_string(day)
      <> " - part "
      <> int.to_string(part)
      <> " : "
      <> res,
    )

    res
  })
}

pub fn assert_result(
  day day: Int,
  expectation expectaction: String,
  runner runner: fn(String) -> Result(String, String),
) {
  let res =
    day
    |> get_test()
    |> result.map(fn(test_input) { runner(test_input) })
    |> result.flatten()

  assert res == Ok(expectaction)
}

pub fn get_input(day: Int) -> Result(String, String) {
  day
  |> get_input_filepath()
  |> simplifile.read()
  |> result.replace_error("Error reading file for day " <> int.to_string(day))
}

pub fn get_test(day: Int) -> Result(String, String) {
  day
  |> get_test_filepath()
  |> simplifile.read()
  |> result.replace_error("Error reading file for day " <> int.to_string(day))
}

fn get_input_filepath(day: Int) -> String {
  "inputs/day" <> int.to_string(day) <> "/input.txt"
}

fn get_test_filepath(day: Int) -> String {
  "inputs/day" <> int.to_string(day) <> "/test.txt"
}
