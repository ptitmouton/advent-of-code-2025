import aoc
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn run() {
  let _ = aoc.run_part(day: 3, part: 1, runner: part1)
  let _ = aoc.run_part(day: 3, part: 2, runner: part2)
}

pub fn part1(input: String) {
  let res =
    input
    |> get_battery_banks()
    |> list.map(fn(bank) {
      let res = get_biggest_joltage(bank, length: 2)
      res
    })
    |> list.fold(0, int.add)

  Ok(int.to_string(res))
}

pub fn part2(input: String) {
  let res =
    input
    |> get_battery_banks()
    |> list.map(fn(bank) {
      let res = get_biggest_joltage(bank, length: 12)
      res
    })
    |> list.fold(0, int.add)

  Ok(int.to_string(res))
}

fn get_battery_banks(input: String) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.trim()
    |> string.to_graphemes()
    |> list.map(fn(char) {
      char
      |> int.parse()
      |> result.unwrap(or: 0)
    })
  })
}

fn get_biggest_joltage(bank: List(Int), length length: Int) {
  let length_range = list.range(length - 1, 0)

  let #(_, value) =
    length_range
    |> list.fold(#(bank, 0), fn(acc, next_n_index) {
      let #(current_bank, current_res) = acc
      let list_length = list.length(current_bank)
      let bank_without_lasts =
        current_bank |> list.take(list_length - next_n_index)
      let #(number, index) = find_biggest_number(bank_without_lasts)
      let next_bank = current_bank |> list.drop(index + 1)

      #(next_bank, current_res * 10 + number)
    })

  value
}

fn find_biggest_number(bank: List(Int)) {
  let bank_with_index = bank |> list.index_map(fn(el, i) { #(el, i) })
  let #(value, index) =
    bank_with_index
    |> list.sort(by: fn(el1, el2) {
      let #(value1, _) = el1
      let #(value2, _) = el2
      int.compare(value2, value1)
    })
    |> list.first()
    |> result.unwrap(or: #(0, 0))

  #(value, index)
}
