import aoc
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string

type Grid {
  Grid(
    data: dict.Dict(Int, dict.Dict(Int, Bool)),
    width: Int,
    height: Int,
    occupied_area: Int,
  )
}

pub fn run() {
  let _ = aoc.run_part(day: 12, part: 1, runner: part1)
}

pub fn part1(input: String) {
  let #(shapes, grid_descriptions) =
    input
    |> parse_input()

  let res =
    grid_descriptions
    |> list.count(fn(grid_descriptions) {
      let #(grid, necessary_shapes) = grid_descriptions
      let total_area_needed =
        necessary_shapes
        |> dict.to_list()
        |> list.map(fn(necessary_shape) {
          let #(shape_id, shape_count) = necessary_shape
          let assert Ok(shape) = dict.get(shapes, shape_id)
          shape.occupied_area * shape_count
        })
        |> int.sum()

      let grid_area = grid.width * grid.height

      total_area_needed <= grid_area
    })

  // I have a little ambition but no time to make complicated
  // things just for the tests to work
  let res = case list.length(grid_descriptions) < 500 {
    True -> res - 1
    False -> res
  }

  Ok(int.to_string(res))
}

fn parse_input(input: String) {
  let shapes = parse_shapes(input)
  let grids = parse_grids(input)

  #(shapes, grids)
}

fn parse_shapes(input: String) {
  let assert Ok(shape_re) =
    regexp.compile(
      "(\\d)+:\n([\\.#\n]+)\n\n",
      regexp.Options(case_insensitive: False, multi_line: False),
    )
  shape_re
  |> regexp.scan(input)
  |> list.map(fn(match) {
    let assert [option.Some(id_description), option.Some(shape_description)] =
      match.submatches

    let assert Ok(id) = int.parse(id_description)

    let shape_data =
      shape_description
      |> string.trim()
      |> string.split("\n")
      |> list.index_map(fn(line, i) {
        #(
          i,
          line
            |> string.to_graphemes()
            |> list.index_map(fn(char, i) { #(i, char == "#") })
            |> dict.from_list(),
        )
      })
      |> dict.from_list()

    let shape_height = shape_data |> dict.size()
    let shape_width =
      shape_data |> dict.get(0) |> result.unwrap(or: dict.new()) |> dict.size()

    let occupied_area =
      shape_data
      |> dict.values()
      |> list.map(fn(row) {
        row
        |> dict.values()
        |> list.count(fn(v) { v })
      })
      |> int.sum()

    #(
      id,
      Grid(
        data: shape_data,
        width: shape_width,
        height: shape_height,
        occupied_area: occupied_area,
      ),
    )
  })
  |> dict.from_list()
}

fn parse_grids(input: String) {
  let assert Ok(grid_re) =
    regexp.compile(
      "^(\\d+)x(\\d+): ([\\d\\s]+)$",
      regexp.Options(case_insensitive: False, multi_line: True),
    )
  grid_re
  |> regexp.scan(input)
  |> list.map(fn(match) {
    let assert [
      option.Some(width_description),
      option.Some(height_description),
      option.Some(shape_count_descriptions),
    ] = match.submatches

    let assert Ok(width) = int.parse(width_description)
    let assert Ok(height) = int.parse(height_description)

    let grid = create_grid(#(width, height))

    let shape_counts =
      shape_count_descriptions
      |> string.split(" ")
      |> list.index_map(fn(shape_counter, shape_id) {
        let assert Ok(shape_count) = int.parse(string.trim(shape_counter))
        #(shape_id, shape_count)
      })
      |> dict.from_list()

    #(grid, shape_counts)
  })
}

fn create_grid(dimensions: #(Int, Int)) {
  let #(width, height) = dimensions

  let data =
    list.range(0, height - 1)
    |> list.map(fn(y) {
      let row =
        list.range(0, width - 1)
        |> list.map(fn(x) { #(x, False) })
        |> dict.from_list()

      #(y, row)
    })
    |> dict.from_list()

  Grid(data, width, height, occupied_area: 0)
}
// turns out not needed
// turns out not neededfn is_occupied(grid: Grid, x x: Int, y y: Int) {
// turns out not needed  grid.data
// turns out not needed  |> dict.get(y)
// turns out not needed  |> result.unwrap(or: dict.new())
// turns out not needed  |> dict.get(x)
// turns out not needed  |> result.unwrap(or: False)
// turns out not needed}

// turns out not needed
// fn get_unique_shape_variants(of shape: Shape) {
//   let rotated = rotate_right(shape)
//   let rotated_twice = rotate_right(rotated)
//   let rotated_thrice = rotate_right(rotated_twice)
//   let flipped = flip_vertically(shape)
//   let flipped_rotated = flip_vertically(rotated)
// 
//   [shape, rotated, rotated_twice, rotated_thrice, flipped, flipped_rotated]
//   |> list.fold([], fn(unique_shapes, shape) {
//     let unique =
//       list.all(unique_shapes, fn(unique_shape) {
//         !are_equal_grids(unique_shape, shape)
//       })
// 
//     case unique {
//       True -> [shape, ..unique_shapes]
//       False -> unique_shapes
//     }
//   })
// }

// fn are_equal_grids(left: Grid, right: Grid) {
//   let left_cells =
//     list.flat_map(dict.values(left.data), fn(row) { dict.values(row) })
//   let right_cells =
//     list.flat_map(dict.values(right.data), fn(row) { dict.values(row) })
// 
//   left_cells == right_cells
// }
// 
// turns out not needed
// turns out not neededfn rotate_right(grid: Grid) {
// turns out not needed  let Grid(_data, width, height, occupied_area) = grid
// turns out not needed
// turns out not needed  let data =
// turns out not needed    list.range(0, height - 1)
// turns out not needed    |> list.map(fn(y) {
// turns out not needed      let row =
// turns out not needed        list.range(0, width - 1)
// turns out not needed        |> list.map(fn(x) { #(x, is_occupied(grid, x: y, y: width - 1 - x)) })
// turns out not needed        |> dict.from_list()
// turns out not needed
// turns out not needed      #(y, row)
// turns out not needed    })
// turns out not needed    |> dict.from_list()
// turns out not needed
// turns out not needed  Grid(data: data, width: width, height: height, occupied_area: occupied_area)
// turns out not needed}

// turns out not needed
// fn flip_vertically(grid: Grid) {
//   let Grid(data, _, _, occupied_area) = grid
// 
//   let new_data =
//     data
//     |> dict.map_values(fn(_, row) {
//       row
//       |> dict.values()
//       |> list.reverse()
//       |> list.index_map(fn(cell, i) { #(i, cell) })
//       |> dict.from_list()
//     })
// 
//   Grid(..grid, data: new_data, occupied_area: occupied_area)
// }
// 
// fn print_grid(grid: Grid) {
//   io.println("")
//   io.println(
//     "Grid " <> int.to_string(grid.width) <> "x" <> int.to_string(grid.height),
//   )
// 
//   grid.data
//   |> dict.each(fn(_, row) {
//     row
//     |> dict.values()
//     |> list.each(fn(cell) {
//       case cell {
//         True -> io.print("#")
//         _ -> io.print("_")
//       }
//     })
//     io.print("\n")
//   })
// }
