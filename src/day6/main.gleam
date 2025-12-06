import aoc
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import glearray as array

pub fn run() {
  let _ = aoc.run_part(day: 6, part: 1, runner: part1)
  let _ = aoc.run_part(day: 6, part: 2, runner: part2)
}

pub fn part1(input: String) {
  let assert Ok(splitter_re) = regexp.from_string("\\s+")

  let rows =
    input
    |> string.trim()
    |> string.split("\n")
    |> list.map(string.trim)

  let rows_length = list.length(rows)

  let number_rows =
    rows
    |> list.take(rows_length - 1)
    |> list.map(fn(row) {
      splitter_re
      |> regexp.split(row)
      |> list.map(fn(str) {
        let assert Ok(n) = int.parse(str)
        n
      })
      |> array.from_list()
    })

  let operators =
    regexp.split(splitter_re, list.last(rows) |> result.unwrap(""))

  let commands =
    operators
    |> list.index_map(fn(operator, i) {
      #(
        operator,
        number_rows
          |> list.map(fn(arr) { arr |> array.get_or_default(i, 0) }),
      )
    })

  exec_commands(commands)
  |> list.reduce(int.add)
  |> result.map(int.to_string)
  |> result.replace_error("")
}

pub fn part2(input: String) {
  let assert Ok(operator_re) = regexp.from_string("(?:\\s(?=(?:\\+|\\*|\\$)))")

  let rows =
    input
    |> string.split("\n")
    |> list.filter(fn(line) { string.length(line) > 0 })

  let rows_length = list.length(rows)

  let number_rows =
    rows
    |> list.take(rows_length - 1)

  let assert Ok(operator_row) = list.last(rows)

  let #(operators, _) =
    regexp.split(operator_re, operator_row)
    |> list.fold(#([], 0), fn(acc, operator_section) {
      let #(operator_list, next_start_index) = acc

      let assert Ok(operator) = string.first(operator_section)
      let from = next_start_index
      let length = string.length(operator_section)

      #(
        [#(operator, from, length), ..operator_list],
        next_start_index + length + 1,
      )
    })

  let commands =
    operators
    |> list.map(fn(operator) {
      let #(operator, from, length) = operator

      let numbers =
        list.range(from + length - 1, from)
        |> list.map(fn(i) {
          let number =
            list.fold(number_rows, "", fn(acc, row) {
              acc <> string.slice(row, i, 1)
            })

          let assert Ok(num) = int.parse(string.trim(number))

          num
        })

      #(operator, numbers)
    })

  exec_commands(commands)
  |> list.reduce(int.add)
  |> result.map(int.to_string)
  |> result.replace_error("")
}

fn exec_commands(commands: List(#(String, List(Int)))) {
  commands
  |> list.map(fn(command) {
    let #(command, numbers) = command
    case command {
      "*" -> list.reduce(numbers, int.multiply) |> result.unwrap(0)
      "+" -> list.reduce(numbers, int.add) |> result.unwrap(0)
      _cmd -> 0
    }
  })
}
