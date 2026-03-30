import library/ast
import library/validator

import gleam/io

// import gleam/result
// import gleam/string
// import library/lexer
// import library/parser
// import simplifile

pub fn main() {
  // let result = {
  //   use input <- result.try(
  //     simplifile.read("schedule.txt") |> result.map_error(string.inspect),
  //   )

  //   use tokens <- result.try(
  //     lexer.lex(input) |> result.map_error(string.inspect),
  //   )

  //   use schedule <- result.try(
  //     parser.parse(tokens) |> result.map_error(string.inspect),
  //   )

  //   Ok(schedule)
  // }

  // case result {
  //   Ok(schedule) -> io.println(string.inspect(schedule))
  //   Error(msg) -> io.println(msg)
  // }

  io.println("")
  io.println("")
  io.println("")

  // except Sunday, Monday and Tuesday ; except Weekends ; except Weekdays ; except Saturday

  validator.validate_exclusions([
    ast.ExceptDays(ast.SpecificDays([ast.Sun, ast.Mon, ast.Tue])),
    ast.ExceptDays(ast.Weekends),
    ast.ExceptDays(ast.Weekdays),
    ast.ExceptDays(ast.SpecificDays([ast.Sat])),
  ])
}
