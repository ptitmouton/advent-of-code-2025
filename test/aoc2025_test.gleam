import aoc
import day1/main as day1
import day2/main as day2
import day3/main as day3
import day4/main as day4
import day5/main as day5
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

pub fn day4_part1_test() {
  aoc.assert_result(day: 4, expectation: "13", runner: day4.part1)
}

pub fn day4_part2_test() {
  aoc.assert_result(day: 4, expectation: "43", runner: day4.part2)
}

pub fn day5_part1_test() {
  aoc.assert_result(day: 5, expectation: "3", runner: day5.part1)
}

pub fn day5_part2_test() {
  aoc.assert_result(day: 5, expectation: "14", runner: day5.part2)
}
