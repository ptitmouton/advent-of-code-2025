import aoc
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import glearray as array

type Coord =
  #(Int, Int, Int)

pub fn run() {
  let _ = aoc.run_part(day: 8, part: 1, runner: part1)
  let _ = aoc.run_part(day: 8, part: 2, runner: part2)
}

pub fn part1(input: String) {
  let coordinates =
    input
    |> as_coordinates()

  let cables_available = case list.length(coordinates) {
    length if length < 100 -> 10
    _ -> 1000
  }

  let pairs =
    coordinates
    |> list.combination_pairs()
    |> list.sort(fn(pair1, pair2) {
      float.compare(get_pair_distance(pair1), get_pair_distance(pair2))
    })
    |> list.take(cables_available)

  let circuits =
    pairs
    |> list.fold([], fn(circuits, pair) {
      let #(coord1, coord2) = pair

      let #(did_exist, circuits) =
        circuits
        |> list.map_fold(False, fn(is_found, circuit) {
          case is_found {
            True -> #(True, circuit)
            False -> {
              let is_found =
                list.contains(circuit, coord1) || list.contains(circuit, coord2)
              case is_found {
                True -> {
                  #(True, list.unique([coord1, coord2, ..circuit]))
                }
                False -> {
                  #(False, circuit)
                }
              }
            }
          }
        })

      case did_exist {
        True -> {
          circuits
        }
        False -> [[coord1, coord2], ..circuits]
      }
      |> combine_circuits_if_necessary()
    })

  circuits
  |> list.sort(fn(c1, c2) { int.compare(list.length(c2), list.length(c1)) })
  |> list.take(3)
  |> list.map(list.length)
  |> list.reduce(int.multiply)
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
    |> list.sort(fn(pair1, pair2) {
      float.compare(get_pair_distance(pair1), get_pair_distance(pair2))
    })

  let assert [last_pairs] =
    pairs
    |> list.fold_until([], fn(circuits, pair) {
      let #(coord1, coord2) = pair

      let #(did_exist, circuits) =
        circuits
        |> list.map_fold(False, fn(is_found, circuit) {
          case is_found {
            True -> #(True, circuit)
            False -> {
              let is_found =
                list.contains(circuit, coord1) || list.contains(circuit, coord2)
              case is_found {
                True -> {
                  #(True, list.unique([coord1, coord2, ..circuit]))
                }
                False -> {
                  #(False, circuit)
                }
              }
            }
          }
        })

      let new_circuits =
        case did_exist {
          True -> {
            circuits
          }
          False -> {
            [[coord1, coord2], ..circuits]
          }
        }
        |> combine_circuits_if_necessary()
        |> list.sort(fn(c1, c2) {
          int.compare(list.length(c2), list.length(c1))
        })

      case
        list.find(new_circuits, fn(circuit) {
          list.length(circuit) == list.length(coordinates)
        })
      {
        Error(_) -> list.Continue(new_circuits)
        Ok(_) -> {
          let #(c1, c2) = pair
          list.Stop([[c1, c2]])
        }
      }
    })

  let assert [#(x1, _, _), #(x2, _, _)] = last_pairs

  Ok(int.to_string(x1 * x2))
}

fn as_coordinates(input: String) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [Ok(x), Ok(y), Ok(z)] =
      line
      |> string.trim()
      |> string.split(",")
      |> list.map(int.parse)

    #(x, y, z)
  })
}

fn get_pair_distance(pair: #(Coord, Coord)) {
  let #(coord1, coord2) = pair
  let #(x1, y1, z1) = coord1
  let #(x2, y2, z2) = coord2

  let assert Ok(x_power) = int.power(x1 - x2, 2.0)
  let assert Ok(y_power) = int.power(y1 - y2, 2.0)
  let assert Ok(z_power) = int.power(z1 - z2, 2.0)

  let assert Ok(distance) = float.square_root(x_power +. y_power +. z_power)

  distance
}

pub fn combine_circuits_if_necessary(circuits: List(List(Coord))) {
  circuits
  |> list.fold(array.new(), fn(combined_circuits, circuit) {
    let existing_circuit_in_combined =
      combined_circuits
      |> array.to_list()
      |> list.index_map(fn(c, i) { #(c, i) })
      |> list.find(fn(el) {
        let #(combined_circuit, _) = el
        list.find(circuit, fn(circuit_coord) {
          list.contains(combined_circuit, circuit_coord)
        })
        |> result.is_ok()
      })

    case existing_circuit_in_combined {
      Ok(#(existing, i)) -> {
        let assert Ok(new_array) =
          array.copy_set(
            combined_circuits,
            i,
            existing |> list.append(circuit) |> list.unique(),
          )

        new_array
      }
      Error(_) -> array.copy_push(combined_circuits, circuit)
    }
  })
  |> array.to_list()
}
