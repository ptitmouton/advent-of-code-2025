import aoc
import day1
import day10
import day11
import day12
import day2
import day3
import day4
import day5
import day6
import day7
import day8
import day9
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

pub fn day6_part1_test() {
  aoc.assert_result(day: 6, expectation: "4277556", runner: day6.part1)
}

pub fn day6_part2_test() {
  aoc.assert_result(day: 6, expectation: "3263827", runner: day6.part2)
}

pub fn day7_part1_test() {
  aoc.assert_result(day: 7, expectation: "21", runner: day7.part1)
}

pub fn day7_part2_test() {
  aoc.assert_result(day: 7, expectation: "40", runner: day7.part2)
}

pub fn day8_part1_test() {
  aoc.assert_result(day: 8, expectation: "40", runner: day8.part1)
}

pub fn day8_part2_test() {
  aoc.assert_result(day: 8, expectation: "25272", runner: day8.part2)
}

pub fn day9_part1_test() {
  aoc.assert_result(day: 9, expectation: "50", runner: day9.part1)
}

pub fn day9_part2_test() {
  aoc.assert_result(day: 9, expectation: "24", runner: day9.part2)
}

pub fn day10_part1_test() {
  aoc.assert_result(day: 10, expectation: "7", runner: day10.part1)
}

pub fn day10_part2_test() {
  aoc.assert_result(day: 10, expectation: "33", runner: day10.part2)
}

pub fn day11_part1_test() {
  aoc.assert_result(day: 11, expectation: "5", runner: day11.part1)
}

// day11 part2 is not really well testable in this context as its test input
// not the same
// pub fn day11_part2_test() {
//   aoc.assert_result(day: 11, expectation: "2", runner: day11.part2)
// }

pub fn day12_part1_test() {
  aoc.assert_result(day: 12, expectation: "2", runner: day12.part1)
}
