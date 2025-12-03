import aoc
import day1/main as day1
import day2/main as day2
import day3/main as day3
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

pub fn day2_part1_test() {
  aoc.assert_result(day: 2, expectation: "1227775554", runner: day2.part1)
}

pub fn day2_part2_test() {
  aoc.assert_result(day: 2, expectation: "4174379265", runner: day2.part2)
}

pub fn day3_part1_test() {
  aoc.assert_result(day: 3, expectation: "357", runner: day3.part1)
}

pub fn day3_part2_test() {
  aoc.assert_result(day: 3, expectation: "3121910778619", runner: day3.part2)
}
