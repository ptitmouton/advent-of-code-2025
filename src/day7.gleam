import aoc
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import glearray as array

type MapArray =
  array.Array(array.Array(String))

type Coord =
  #(Int, Int)

pub fn run() {
  let _ = aoc.run_part(day: 7, part: 1, runner: part1)
  let _ = aoc.run_part(day: 7, part: 2, runner: part2)
}

pub fn part1(input: String) {
  let map = input |> as_map()
  let map_array = input |> as_map_array()
  let start_position = get_start_pos(map)

  let #(split_count, _beams) =
    map
    |> list.fold(#(0, []), fn(acc, _) {
      let #(split_count, beams) = acc
      case beams {
        [last_inserted, ..rest] -> {
          let #(new_split_count, new_beams) =
            last_inserted
            |> list.fold(#(0, []), fn(acc, coord) {
              let #(count, new_inserted_beams) = acc
              let #(x, y) = coord
              let new_coord = #(x, y + 1)
              case is_splitter(map_array, new_coord) {
                option.Some(new_coords) -> #(
                  count + 1,
                  list.append(new_coords, new_inserted_beams) |> list.unique(),
                )
                option.None -> #(
                  count,
                  list.append([new_coord], new_inserted_beams),
                )
              }
            })

          #(split_count + new_split_count, [new_beams, last_inserted, ..rest])
        }
        [] -> {
          let #(x, y) = start_position
          #(0, [[#(x, y + 1)]])
        }
      }
    })

  Ok(int.to_string(split_count))
}

pub fn part2(input: String) {
  let map = input |> as_map()
  let map_array = input |> as_map_array()
  let start_position = get_start_pos(map)

  let visited_map =
    map
    |> list.map(fn(row) {
      let row =
        row
        |> list.map(fn(_) { 0 })
      row
      |> array.from_list()
    })
    |> array.from_list()
    |> visit_cell(start_position, 1)

  let #(visited_map, _) =
    map
    |> list.drop(1)
    |> list.fold(#(visited_map, [start_position]), fn(acc, _) {
      let #(visited_map, last_inserted) = acc
      let #(new_visited_map, new_beams) =
        last_inserted
        |> list.fold(#(visited_map, []), fn(acc, coord) {
          let #(new_visited_map, new_inserted_beams) = acc
          let #(x, y) = coord
          let new_coord = #(x, y + 1)
          let new_coord_visited = get_cell_count(new_visited_map, coord)

          case is_splitter(map_array, new_coord) {
            option.Some(new_coords) -> {
              #(
                new_coords
                  |> list.fold(new_visited_map, fn(map, updated_coord) {
                    visit_cell(map, updated_coord, new_coord_visited)
                  }),
                list.append(new_coords, new_inserted_beams) |> list.unique(),
              )
            }
            option.None -> #(
              visit_cell(new_visited_map, new_coord, new_coord_visited),
              [new_coord, ..new_inserted_beams],
            )
          }
        })

      #(new_visited_map, new_beams)
    })

  let assert Ok(counts) =
    visited_map
    |> array.to_list()
    |> list.last()
    |> result.unwrap(array.new())
    |> array.to_list()
    |> list.reduce(int.add)
  Ok(int.to_string(counts))
}

fn get_start_pos(map: List(List(String))) {
  let assert Ok(first_row) = list.first(map)
  let first_row_with_index = first_row |> list.index_map(fn(v, i) { #(v, i) })

  let assert Ok(#(_, i)) =
    first_row_with_index
    |> list.find(fn(field_with_index) {
      let #(cell, _) = field_with_index
      cell == "S"
    })

  #(i, 0)
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

fn visit_cell(map: array.Array(array.Array(Int)), coord: Coord, visits: Int) {
  let #(x, y) = coord
  let assert Ok(row) = array.get(map, y)
  let assert Ok(count) = array.get(row, x)

  let assert Ok(updated_row) = array.copy_set(row, x, count + visits)
  let assert Ok(updated_map) = array.copy_set(map, y, updated_row)

  updated_map
}

fn get_cell_count(map: array.Array(array.Array(Int)), coord: Coord) {
  let #(x, y) = coord
  let assert Ok(row) = array.get(map, y)
  let assert Ok(count) = array.get(row, x)
  count
}

fn get_cell(map: MapArray, coord: Coord) -> String {
  let #(x, y) = coord
  map
  |> array.get_or_default(y, array.new())
  |> array.get_or_default(x, "")
}

fn is_splitter(map: MapArray, coord: Coord) -> option.Option(List(Coord)) {
  case get_cell(map, coord) {
    "^" -> {
      let #(x, y) = coord
      option.Some([#(x - 1, y), #(x + 1, y)])
    }
    _ -> option.None
  }
}
