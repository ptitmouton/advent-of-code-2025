import aoc
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/yielder
import glearray as array

type MapArray =
  array.Array(array.Array(String))

pub fn run() {
  let _ = aoc.run_part(day: 4, part: 1, runner: part1)
  let _ = aoc.run_part(day: 4, part: 2, runner: part2)
}

pub fn part1(input: String) {
  let map = input |> as_map()
  let map_array = input |> as_map_array()

  let accessible_rolls_count =
    map
    |> list.index_map(fn(row, y) {
      row
      |> list.index_map(fn(cell, x) {
        case cell {
          "@" -> {
            let adjacent_rolls =
              get_adjacent_positions(map, x, y)
              |> list.filter(fn(coords) {
                let #(x, y) = coords
                get_at(map_array, x, y) == "@"
              })

            let count = list.length(adjacent_rolls)

            count < 4
          }
          _ -> False
        }
      })
    })
    |> list.flatten()
    |> list.count(fn(is_accessible) { is_accessible })

  Ok(int.to_string(accessible_rolls_count))
}

pub fn part2(input: String) {
  let map = input |> as_map()
  let map_array = input |> as_map_array()

  yielder.unfold(from: map_array, with: fn(map_array) {
    let accessible_rolls_coords =
      map
      |> list.index_map(fn(row, y) {
        row
        |> list.index_map(fn(_, x) {
          case get_at(map_array, x, y) {
            "@" -> {
              let adjacent_rolls =
                get_adjacent_positions(map, x, y)
                |> list.filter(fn(coords) {
                  let #(x, y) = coords
                  get_at(map_array, x, y) == "@"
                })

              let count = list.length(adjacent_rolls)

              case count < 4 {
                True -> option.Some(#(x, y))
                False -> option.None
              }
            }
            _ -> option.None
          }
        })
      })
      |> list.flatten()
      |> option.values()

    case list.length(accessible_rolls_coords) {
      0 -> yielder.Done
      count -> {
        let new_map_array =
          list.fold(
            accessible_rolls_coords,
            map_array,
            fn(map_array, next_coords) {
              let #(x, y) = next_coords

              remove_at(map_array, x, y)
            },
          )

        yielder.Next(element: count, accumulator: new_map_array)
      }
    }
  })
  |> yielder.to_list()
  |> list.reduce(int.add)
  |> result.map(int.to_string)
  |> result.replace_error("")
}

fn as_map(input: String) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(row) {
    row
    |> string.trim()
    |> string.split("")
  })
}

fn as_map_array(input: String) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(row) {
    row
    |> string.trim()
    |> string.split("")
    |> array.from_list()
  })
  |> array.from_list()
}

fn remove_at(map_array: MapArray, x: Int, y: Int) {
  let row_to_replace =
    map_array
    |> array.get_or_default(y, array.new())
    |> array.copy_set(x, "x")
    |> result.unwrap(array.new())

  map_array
  |> array.copy_set(y, row_to_replace)
  |> result.unwrap(array.new())
}

fn get_at(map_array: MapArray, x: Int, y: Int) {
  map_array
  |> array.get_or_default(y, array.new())
  |> array.get_or_default(x, "")
}

fn get_dimensions(map: List(List(String))) {
  let rows = map |> list.count(fn(_) { True })
  let columns =
    map |> list.first() |> result.unwrap(or: []) |> list.count(fn(_) { True })

  #(rows, columns)
}

fn get_adjacent_positions(map: List(List(String)), x: Int, y: Int) {
  let #(rows, columns) = map |> get_dimensions()

  let tops = case y {
    0 -> []
    _ if x == 0 -> [#(x, y - 1), #(x + 1, y - 1)]
    _ if x == columns - 1 -> [#(x - 1, y - 1), #(x, y - 1)]
    _ -> [#(x - 1, y - 1), #(x, y - 1), #(x + 1, y - 1)]
  }

  let same = case x {
    0 -> [#(x + 1, y)]
    _ if x == { columns - 1 } -> [#(x - 1, y)]
    _ -> [#(x - 1, y), #(x + 1, y)]
  }

  let bottoms = case y {
    _ if y == rows - 1 -> []
    _ if x == 0 -> [#(x, y + 1), #(x + 1, y + 1)]
    _ if x == columns - 1 -> [#(x - 1, y + 1), #(x, y + 1)]
    _ -> [#(x - 1, y + 1), #(x, y + 1), #(x + 1, y + 1)]
  }

  tops
  |> list.append(same)
  |> list.append(bottoms)
}
