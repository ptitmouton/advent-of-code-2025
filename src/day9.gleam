import aoc
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Coord =
  #(Int, Int)

type Map =
  #(dict.Dict(Int, dict.Dict(Int, Bool)), #(Int, Int))

type Direction {
  Up
  Down
  Left
  Right
}

pub fn run() {
  let _ = aoc.run_part(day: 9, part: 1, runner: part1)
  let _ = aoc.run_part(day: 9, part: 2, runner: part2)
}

pub fn part1(input: String) {
  let pairs =
    input
    |> as_coordinates()
    |> list.combination_pairs()

  pairs
  |> list.map(get_pair_area)
  |> list.sort(int.compare)
  |> list.reverse()
  |> list.first()
  |> result.map(int.to_string)
  |> result.replace_error("")
}

pub fn part2(input: String) {
  let coordinates =
    input
    |> as_coordinates()

  let pairs =
    coordinates
    |> list.combination_pairs()

  let border_map = #(dict.new(), get_max_dimensions(coordinates))

  let assert Ok(last_coordinate) = list.last(coordinates)

  let #(border_map, _) =
    coordinates
    |> list.fold(#(border_map, last_coordinate), fn(acc, next_coordinate) {
      let #(border_map, last_coordinate) = acc
      #(
        trace_border(border_map, from: last_coordinate, to: next_coordinate),
        next_coordinate,
      )
    })

  pairs
  |> list.map(fn(pair) { #(pair, get_pair_area(pair)) })
  |> list.sort(fn(el1, el2) {
    let #(_, area1) = el1
    let #(_, area2) = el2
    int.compare(area2, area1)
  })
  |> list.find(fn(el) {
    let #(pair, _) = el
    pair_covers_green_tiles(pair, border_map, coordinates)
  })
  |> result.map(fn(el) {
    let #(_, area) = el
    int.to_string(area)
  })
  |> result.replace_error("")
}

fn trace_border(map: Map, from from: Coord, to to: Coord) {
  let #(to_x, to_y) = to

  let map = set_border(map, from)
  case from {
    #(from_x, from_y) if from_x == to_x && from_y == to_y -> map
    #(from_x, from_y) if from_x == to_x && from_y < to_y ->
      trace_border(map, #(from_x, from_y + 1), to)
    #(from_x, from_y) if from_x == to_x && from_y > to_y ->
      trace_border(map, #(from_x, from_y - 1), to)
    #(from_x, from_y) if from_x < to_x ->
      trace_border(map, #(from_x + 1, from_y), to)
    #(from_x, from_y) -> trace_border(map, #(from_x - 1, from_y), to)
  }
}

fn set_border(map: Map, coord: Coord) {
  let #(x, y) = coord
  let #(dicts, dimensions) = map
  let row =
    dicts
    |> dict.get(y)
    |> result.unwrap(or: dict.new())
    |> dict.insert(x, True)

  let dicts = dict.insert(dicts, y, row)

  #(dicts, dimensions)
}

fn pair_covers_green_tiles(pair: #(Coord, Coord), map: Map, coords: List(Coord)) {
  let #(c1, c2) = pair
  let #(x1, y1) = c1
  let #(x2, y2) = c2
  let min_y = int.min(y1, y2)
  let max_y = int.max(y1, y2)
  let min_x = int.min(x1, x2)
  let max_x = int.max(x1, x2)

  !list.any(coords, fn(coord) {
    let #(x, y) = coord
    x > min_x && x < max_x && y > min_y && y < min_y
  })
  // && {
  //   // this does not work an I'm not sure why. Leave it here for reference
  //   [#(min_x, min_y), #(min_x, max_y), #(max_x, min_y), #(max_x, max_y)]
  //   |> list.all(fn(coord) { is_inside_polygon(map, coord) })
  // }
  && {
    let border_top = list.range(min_x, max_x) |> list.map(fn(x) { #(x, min_y) })
    let border_bottom =
      list.range(min_x, max_x) |> list.map(fn(x) { #(x, max_y) })
    let border_left =
      list.range(min_y, max_y) |> list.map(fn(y) { #(min_x, y) })
    let border_right =
      list.range(min_y, max_y) |> list.map(fn(y) { #(max_x, y) })

    list.all(border_left, fn(cell) { reach_border(map, cell, Left) })
    && list.all(border_right, fn(cell) { reach_border(map, cell, Right) })
    && list.all(border_top, fn(cell) { reach_border(map, cell, Up) })
    && list.all(border_bottom, fn(cell) { reach_border(map, cell, Down) })
  }
}

// fn is_inside_polygon(map: Map, coord: Coord) {
//   let #(dicts, _) = map
//   let #(x, y) = coord
//   let assert Ok(row) = dict.get(dicts, y)
// 
//   let count =
//     count_walls_until_point(
//       row,
//       target: x,
//       count: 0,
//       last_cell_was_border: False,
//       current_index: 0,
//     )
//   count % 2 == 1
// }
// 
// fn count_walls_until_point(
//   row: dict.Dict(Int, Bool),
//   target target: Int,
//   count count: Int,
//   last_cell_was_border last_cell_was_border: Bool,
//   current_index current_index: Int,
// ) {
//   case dict.get(row, current_index) {
//     Ok(_) if !last_cell_was_border && current_index == target -> count + 1
//     _ if current_index == target -> count
//     Ok(_) if !last_cell_was_border ->
//       count_walls_until_point(row, target, count + 1, True, current_index + 1)
//     cell ->
//       count_walls_until_point(
//         row,
//         target,
//         count,
//         result.is_ok(cell),
//         current_index + 1,
//       )
//   }
// }

fn reach_border(map: Map, coord: Coord, dir: Direction) {
  let #(x, y) = coord
  let #(dicts, _) = map

  is_border(map, coord)
  || case dir {
    Left -> {
      {
        use row <- result.try(dict.get(dicts, y))
        let keys = dict.keys(row)
        list.find(keys, fn(px) { px < x })
      }
      |> result.is_ok()
    }
    Right -> {
      {
        use row <- result.try(dict.get(dicts, y))
        let keys = dict.keys(row)
        list.find(keys, fn(px) { px > x })
      }
      |> result.is_ok()
    }
    Up -> {
      dicts
      |> dict.filter(fn(py, _) { py < y })
      |> dict.values()
      |> list.any(fn(row) { dict.has_key(row, x) })
    }
    Down ->
      dicts
      |> dict.filter(fn(py, _) { py > y })
      |> dict.values()
      |> list.any(fn(row) { dict.has_key(row, x) })
  }
}

fn as_coordinates(input: String) -> List(Coord) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [Ok(x), Ok(y)] =
      line
      |> string.trim()
      |> string.split(",")
      |> list.map(int.parse)

    #(x, y)
  })
}

fn get_pair_area(pair: #(Coord, Coord)) {
  let #(coord1, coord2) = pair
  let #(x1, y1) = coord1
  let #(x2, y2) = coord2

  let width = int.max(x1, x2) - int.min(x1, x2) + 1
  let height = int.max(y1, y2) - int.min(y1, y2) + 1

  width * height
}

fn get_max_dimensions(coordinates: List(Coord)) {
  let assert Ok(#(x, _)) =
    coordinates
    |> list.max(fn(c1, c2) {
      let #(x1, _) = c1
      let #(x2, _) = c2
      int.compare(x1, x2)
    })

  let assert Ok(#(_, y)) =
    coordinates
    |> list.max(fn(c1, c2) {
      let #(_, y1) = c1
      let #(_, y2) = c2
      int.compare(y1, y2)
    })

  #(x, y)
}

fn is_border(map: Map, coord: Coord) {
  let #(x, y) = coord
  let #(dicts, _) = map
  let row = dict.get(dicts, y)
  result.is_ok(row)
  && {
    let assert Ok(row) = row
    dict.has_key(row, x)
  }
}
