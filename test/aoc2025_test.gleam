import aoc
import day1/main as day1
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn day1_part1_test() {
  aoc.assert_result(day: 1, expectation: "3", runner: day1.part1)
}

pub fn day1_part2_test() {
  aoc.assert_result(day: 1, expectation: "6", runner: day1.part2)
}
