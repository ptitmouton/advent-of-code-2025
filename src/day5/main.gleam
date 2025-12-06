import aoc
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import glearray as array

pub fn run() {
  let _ = aoc.run_part(day: 5, part: 1, runner: part1)
  let _ = aoc.run_part(day: 5, part: 2, runner: part2)
}

pub fn part1(input: String) {
  let #(ranges, ids) = parse_input(input)

  let fresh_ids =
    ids
    |> list.filter(fn(id) { id_is_in_ranges(id, ranges) })

  Ok(int.to_string(list.length(fresh_ids)))
}

pub fn part2(input: String) {
  let #(ranges, _) = parse_input(input)

  let consolidated_ranges = consolidate_ranges(ranges)
  let res =
    list.map(consolidated_ranges, fn(range) {
      let #(from, to) = range

      to - from + 1
    })
    |> list.reduce(int.add)
    |> result.unwrap(0)

  Ok(int.to_string(res))
}

fn id_is_in_ranges(id: Int, ranges: List(#(Int, Int))) {
  ranges
  |> list.find(fn(range) { id_is_in_range(id, range) })
  |> result.is_ok()
}

fn id_is_in_range(id: Int, range: #(Int, Int)) {
  let #(from, to) = range
  id >= from && id <= to
}

fn consolidate_ranges(ranges: List(#(Int, Int))) {
  ranges
  |> list.fold(array.new(), fn(consolidated, next_range) {
    case find_overlapping_range(consolidated, next_range) {
      option.None -> {
        array.copy_push(consolidated, next_range)
      }
      option.Some(#(combined_range, overlapping_index)) -> {
        consolidated
        |> array.copy_set(overlapping_index, combined_range)
        |> result.unwrap(or: array.new())
      }
    }
  })
  |> array.to_list()
}

fn find_overlapping_range(
  haystack: array.Array(#(Int, Int)),
  needle: #(Int, Int),
) {
  let overlapping =
    haystack
    |> array.to_list()
    |> list.index_map(fn(r, i) { #(r, i) })
    |> list.find(fn(value_with_index) {
      let #(range, _) = value_with_index
      let #(_, range_to) = range
      let #(needle_from, _) = needle

      { needle_from <= range_to }
    })

  case overlapping {
    Ok(#(range, index)) -> option.Some(#(combine_ranges(range, needle), index))
    Error(_) -> option.None
  }
}

fn combine_ranges(range1: #(Int, Int), range2: #(Int, Int)) {
  let #(from1, to1) = range1
  let #(from2, to2) = range2

  #(int.min(from1, from2), int.max(to1, to2))
}

fn parse_ranges(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let range =
      line
      |> string.split("-")
      |> list.map(fn(number) {
        number
        |> int.parse()
        |> result.unwrap(or: 0)
      })

    case range {
      [from, to] -> #(from, to)
      _ -> #(0, 0)
    }
  })
  |> list.sort(fn(range1, range2) {
    let #(from1, _) = range1
    let #(from2, _) = range2

    int.compare(from1, from2)
  })
}

fn parse_ingredient_ids(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(number) {
    number
    |> int.parse()
    |> result.unwrap(or: 0)
  })
}

fn parse_input(input: String) {
  let sections =
    input
    |> string.trim()
    |> string.split("\n\n")
    |> list.map(string.trim)

  case sections {
    [first, second] -> #(parse_ranges(first), parse_ingredient_ids(second))
    _ -> #([], [])
  }
}
