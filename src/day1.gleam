import aoc
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn run() {
  let _ = aoc.run_part(day: 1, part: 1, runner: part1)
  let _ = aoc.run_part(day: 1, part: 2, runner: part2)
}

pub fn part1(input: String) {
  let commands = input |> string.trim |> string.split("\n")
  let current_position = 50

  commands
  |> list.fold(Ok(#(0, current_position)), fn(result_tuple, command) {
    use #(zero_counts, current_position) <- result.try(result_tuple)
    use #(_, new_position) <- result.try(get_next_position(
      current_position,
      command,
    ))

    let new_zero_count = case new_position {
      0 -> zero_counts + 1
      _other -> zero_counts
    }

    Ok(#(new_zero_count, new_position))
  })
  |> result.map(fn(result_tuple) {
    let #(zero_counts, _) = result_tuple

    int.to_string(zero_counts)
  })
}

pub fn part2(input: String) {
  let commands = input |> string.trim |> string.split("\n")
  let current_position = 50

  commands
  |> list.fold(Ok(#(0, current_position)), fn(result_tuple, command) {
    use #(zero_counts, current_position) <- result.try(result_tuple)
    use #(zeros_passed, new_position) <- result.try(get_next_position(
      current_position,
      command,
    ))

    let new_zero_count = zero_counts + zeros_passed

    Ok(#(new_zero_count, new_position))
  })
  |> result.map(fn(result_tuple) {
    let #(zero_counts, _) = result_tuple

    int.to_string(zero_counts)
  })
}

fn get_next_position(current_position, command) -> Result(#(Int, Int), String) {
  case command {
    "L" <> steps -> {
      let steps =
        steps
        |> int.parse()
        |> result.replace_error("Could not parse steps")

      use steps <- result.try(steps)
      use new_position <- result.try(
        int.modulo(current_position - steps, 100)
        |> result.replace_error("Error calculating module"),
      )

      let overflow_count = case steps > current_position {
        True if new_position > current_position -> steps / 100 + 1
        True -> steps / 100
        False -> 0
      }

      let zeros_passed = case new_position {
        0 if current_position == 0 -> overflow_count
        0 -> overflow_count + 1
        _other if current_position == 0 -> overflow_count - 1
        _other -> overflow_count
      }

      Ok(#(zeros_passed, new_position))
    }
    "R" <> steps -> {
      let steps =
        steps
        |> int.parse()
        |> result.replace_error("Could not parse steps")

      use steps <- result.try(steps)
      use new_position <- result.try(
        int.modulo(current_position + steps, 100)
        |> result.replace_error("Error calculating module"),
      )

      let overflow_count = case steps >= 100 - current_position {
        True if new_position < current_position -> steps / 100 + 1
        True -> steps / 100
        False -> 0
      }

      Ok(#(overflow_count, new_position))
    }
    _ -> Error("input line has wrong format")
  }
}
