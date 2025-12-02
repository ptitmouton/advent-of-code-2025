import aoc
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn run() {
  let _ = aoc.run_part(day: 2, part: 1, runner: part1)
  let _ = aoc.run_part(day: 2, part: 2, runner: part2)
}

pub fn part1(input: String) {
  let res =
    input
    |> string.trim()
    |> get_search_hay()
    |> list.fold(0, fn(current, next) {
      case is_invalid_number(next) {
        True -> next + current
        False -> current
      }
    })
    |> int.to_string()

  Ok(res)
}

pub fn part2(input: String) {
  let res =
    input
    |> string.trim()
    |> get_search_hay()
    |> list.fold(0, fn(current, next) {
      case is_new_invalid_number(next) {
        True -> {
          next + current
        }
        False -> current
      }
    })
    |> int.to_string()

  Ok(res)
}

fn get_search_hay(input: String) {
  let splitted = string.split(input, ",")

  splitted
  |> list.map(fn(range_description) {
    let first_and_lasts =
      range_description
      |> string.split("-")
      |> list.map(fn(n) { result.unwrap(int.parse(n), or: 0) })

    let first = result.unwrap(list.first(first_and_lasts), or: 0)
    let last = result.unwrap(list.last(first_and_lasts), or: 0)

    list.range(from: first, to: last)
  })
  |> list.flatten()
}

fn is_invalid_number(number: Int) {
  case check_invalidity(number) {
    Ok(_) -> True
    Error(_) -> False
  }
}

fn is_new_invalid_number(number: Int) {
  let input_number = int.to_string(number)
  let length = string.length(input_number)

  let half_point = case check_even_length(input_number) {
    Ok(_) -> length / 2
    Error(_) -> { length - 1 } / 2
  }

  list.range(1, half_point)
  |> list.fold(False, fn(found_invalidity, length_to_check) {
    case found_invalidity {
      True -> True
      False -> is_repeating(input_number, length_to_check)
    }
  })
}

fn check_invalidity(number: Int) {
  let input_number = int.to_string(number)
  use length <- result.try(check_even_length(input_number))

  let half_point = length / 2
  let first_half =
    string.slice(from: input_number, at_index: 0, length: half_point)
  let second_half =
    string.slice(
      from: input_number,
      at_index: half_point,
      length: string.length(input_number),
    )

  case first_half == second_half {
    True -> Ok(Nil)
    False -> Error(Nil)
  }
}

fn is_repeating(str: String, times: Int) {
  let str_length = string.length(str)
  case int.modulo(str_length, times) {
    _ if str_length <= 1 -> False
    Ok(0) -> {
      let check_str =
        str
        |> string.slice(at_index: 0, length: times)
        |> string.repeat(str_length / times)

      check_str == str
    }
    Ok(_) -> False
    Error(_) -> False
  }
}

fn check_even_length(number: String) {
  let str_length = string.length(number)
  case str_length % 2 {
    0 -> Ok(str_length)
    _ -> Error(Nil)
  }
}
