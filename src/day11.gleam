import aoc
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import rememo/memo

type Device =
  #(String, List(String))

type DeviceMap =
  dict.Dict(String, List(String))

pub fn run() {
  let _ = aoc.run_part(day: 11, part: 1, runner: part1)
  let _ =
    aoc.run_part(day: 11, part: 2, runner: fn(input: String) {
      part2(input) |> result.replace_error("")
    })
}

pub fn part1(input: String) {
  use cache <- memo.create()
  let score =
    input
    |> get_device_map()
    |> count_steps(from: "you", to: "out", ignoring: [], use_point_cache: cache)

  Ok(int.to_string(score))
}

pub fn part2(input: String) {
  use cache <- memo.create()
  let map = input |> get_device_map()
  let count_tuple_steps = fn(pos: #(String, String)) {
    count_steps(
      on: map,
      from: pos.0,
      to: pos.1,
      ignoring: [],
      use_point_cache: cache,
    )
  }

  let left =
    [#("svr", "fft"), #("fft", "dac"), #("dac", "out")]
    |> list.map(count_tuple_steps)
    |> list.reduce(int.multiply)

  let right =
    [#("svr", "dac"), #("dac", "fft"), #("fft", "out")]
    |> list.map(count_tuple_steps)
    |> list.reduce(int.multiply)

  use left <- result.try(left)
  use right <- result.try(right)

  Ok(int.to_string(left + right))
}

fn count_steps(
  on device_map: DeviceMap,
  from current_position: String,
  to target: String,
  ignoring visited: List(#(String, String)),
  use_point_cache cache,
) {
  use <- memo.memoize(cache, #(current_position, target))
  case target == current_position {
    True -> {
      1
    }
    False -> {
      device_map
      |> dict.get(current_position)
      |> result.unwrap(or: [])
      |> list.filter(fn(pos) {
        !list.contains(visited, #(current_position, pos))
      })
      |> list.fold(0, fn(acc, next_pos) {
        acc
        + count_steps(
          on: device_map,
          from: next_pos,
          to: target,
          ignoring: [#(current_position, next_pos), ..visited],
          use_point_cache: cache,
        )
      })
    }
  }
}

fn get_device_map(input: String) -> DeviceMap {
  input
  |> get_lines()
  |> list.map(parse_device)
  |> create_map()
}

fn create_map(devices: List(Device)) -> DeviceMap {
  dict.from_list(devices)
}

fn parse_device(input: String) -> Device {
  let assert [name, ..connected_devices] =
    input
    |> string.split(" ")

  #(string.replace(name, ":", ""), list.reverse(connected_devices))
}

fn get_lines(input: String) {
  input
  |> string.trim()
  |> string.split("\n")
}
