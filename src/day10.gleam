import aoc
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string

type Lights =
  List(Bool)

type Button =
  List(Int)

type Joltings =
  List(Int)

type MachineDescription =
  #(Lights, List(Button), Joltings)

pub fn run() {
  let _ = aoc.run_part(day: 10, part: 1, runner: part1)
  let _ = aoc.run_part(day: 10, part: 2, runner: part2)
}

pub fn part1(input: String) {
  input
  |> parse_input()
  |> list.map(find_shortest_light_sequence)
  |> list.reduce(int.add)
  |> result.map(int.to_string)
  |> result.replace_error("")
}

pub fn part2(input: String) {
  input
  |> parse_input()
  |> list.map(fn(line) {
    let #(_, buttons, target) = line
    buttons
    |> list.filter(fn(button) {
      list.any(list.index_map(target, fn(_, i) { i }), fn(i) {
        list.contains(button, i)
      })
    })
    |> find_shortest_joltings_sequence(target)
  })
  |> list.reduce(int.add)
  |> result.map(int.to_string)
  |> result.replace_error("")
}

fn find_shortest_light_sequence(line: MachineDescription) -> Int {
  let #(lights, buttons, _) = line

  let lights_off = list.map(lights, fn(_) { False })
  let current_light_states =
    buttons
    |> list.map(fn(_) { lights_off })

  count_button_pushes_until_light_target(
    target: lights,
    current: current_light_states,
    buttons: buttons,
    push_counter: 0,
    walked_paths: [],
  )
}

fn count_button_pushes_until_light_target(
  target target: Lights,
  current current: List(Lights),
  buttons buttons: List(Button),
  push_counter push_counter: Int,
  walked_paths walked_paths: List(#(String, Button)),
) {
  let push_counter = push_counter + 1
  let #(current, walked_paths) =
    current
    |> list.fold(#([], walked_paths), fn(acc, current_state) {
      buttons
      |> list.filter(fn(button) {
        !list.any(walked_paths, fn(path) {
          path == #(lights_string(current_state), button)
        })
      })
      |> list.fold(acc, fn(acc, button) {
        let state = push_light_button(current_state, button)
        let path = #(lights_string(current_state), button)

        #(list.unique([state, ..acc.0]), list.unique([path, ..acc.1]))
      })
    })

  case list.contains(current, target) {
    True -> push_counter
    False -> {
      count_button_pushes_until_light_target(
        target,
        current,
        buttons,
        push_counter,
        walked_paths,
      )
    }
  }
}

fn push_light_button(lights: Lights, button: Button) {
  lights
  |> list.index_map(fn(is_on, i) {
    case list.contains(button, i) {
      True -> !is_on
      _ -> is_on
    }
  })
}

fn find_shortest_joltings_sequence(
  buttons: List(Button),
  target: Joltings,
) -> Int {
  let cost_table =
    buttons
    |> create_cost_table(target)

  get_cost_to_reach_target(target, with_cost_table: cost_table)
}

fn get_cost_to_reach_target(
  target: Joltings,
  with_cost_table cost_table: dict.Dict(List(Int), Int),
) {
  case list.all(target, fn(v) { v == 0 }) {
    True -> 0
    False -> {
      cost_table
      |> dict.fold(100_000, fn(current_result, pattern, pattern_cost) {
        let assert Ok(compare_tuple) = list.strict_zip(pattern, target)
        let does_not_overshoot =
          list.all(compare_tuple, fn(t) { t.0 <= t.1 && t.0 % 2 == t.1 % 2 })

        case does_not_overshoot {
          True -> {
            let new_target =
              list.map(compare_tuple, fn(t) {
                let result = { t.1 - t.0 } / 2

                result
              })

            int.min(
              current_result,
              pattern_cost
                + {
                2
                * get_cost_to_reach_target(
                  new_target,
                  with_cost_table: cost_table,
                )
              },
            )
          }
          False -> current_result
        }
      })
    }
  }
}

fn create_empty_pattern(from_target target: Joltings) {
  list.repeat(0, times: list.length(target))
}

fn create_cost_table(buttons: List(Button), target: Joltings) {
  let button_count = list.length(buttons)
  list.range(0, button_count)
  |> list.flat_map(fn(button_count) {
    buttons
    |> list.combinations(button_count)
    |> list.map(fn(button_combination) {
      #(
        target
          |> create_empty_pattern()
          |> list.index_map(fn(_, i) {
            list.count(button_combination, fn(joltings) {
              list.contains(joltings, i)
            })
          }),
        button_count,
      )
    })
  })
  |> list.sort(fn(el1, el2) { int.compare(el1.1, el2.1) })
  |> list.fold(dict.new(), fn(acc, el) {
    let #(pattern, cost) = el
    case dict.get(acc, pattern) {
      Ok(existing_cost) if cost >= existing_cost -> acc
      _ -> dict.insert(acc, pattern, cost)
    }
  })
}

pub fn patterns(buttons: List(Button)) {
  let assert Ok(button) = list.first(buttons)
  let joltages_count = list.length(button)
  let buttons_count = list.length(buttons)

  let empty_pattern = list.repeat(0, times: joltages_count)

  list.range(1, buttons_count)
  |> list.flat_map(fn(pattern_len) {
    buttons
    |> list.index_map(fn(c, i) { #(i, c) })
    |> list.combinations(pattern_len)
    |> list.map(fn(buttons) {
      let pattern =
        buttons
        |> list.flat_map(fn(b) {
          list.zip(empty_pattern, b.1)
          |> list.map(fn(el) { [el.0, el.1] })
        })
      #(list.flatten(pattern), pattern_len)
    })
  })
  |> list.fold(dict.new(), fn(acc, pair) {
    case dict.has_key(acc, pair.0) {
      True -> acc
      False -> dict.insert(acc, pair.0, pair.1)
    }
  })
}

fn lights_string(lights: Lights) {
  lights |> list.map(bool_to_char) |> string.join("")
}

fn bool_to_char(bool: Bool) {
  case bool {
    True -> "#"
    False -> "."
  }
}

fn parse_input(input: String) -> List(MachineDescription) {
  let assert Ok(re) =
    regexp.compile(
      "^\\[([.#]+)\\]\\s*([\\s\\d\\)\\(,]*)\\s*{([\\d,]*)}$",
      regexp.Options(case_insensitive: False, multi_line: True),
    )
  regexp.scan(with: re, content: input)
  |> list.map(fn(match) {
    let assert [
      option.Some(lights_str),
      option.Some(buttons_str),
      option.Some(joltings_str),
    ] = match.submatches
    let lights =
      lights_str
      |> string.to_graphemes()
      |> list.map(fn(char) { char == "#" })

    let buttons =
      buttons_str
      |> string.split(") (")
      |> list.map(fn(button_str) {
        button_str
        |> string.replace("(", "")
        |> string.replace(")", "")
        |> string.trim()
        |> string.split(",")
        |> list.map(fn(button_i) {
          let assert Ok(n) = int.parse(button_i)
          n
        })
      })

    let joltings =
      joltings_str
      |> string.split(",")
      |> list.map(fn(button_i) {
        let assert Ok(n) = int.parse(button_i)
        n
      })

    #(lights, buttons, joltings)
  })
}
