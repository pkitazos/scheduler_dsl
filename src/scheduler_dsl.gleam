import library/ast
import library/utils
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

  // except Sunday, Monday and Tuesday ; except Weekends ; except Weekdays ; except Saturday

  let res =
    validator.validate_exclusions([
      // Qualified Ordinals
      ast.ExceptDays(
        ast.QualifiedOrdinalDays([
          ast.NthWeekday(ast.First, ast.Mon),
        ]),
      ),
      ast.ExceptDays(
        ast.QualifiedOrdinalDays([
          ast.NthWeekday(ast.Last, ast.Mon),
          ast.NthWeekday(ast.First, ast.Mon),
        ]),
      ),
      ast.ExceptDays(
        ast.QualifiedOrdinalDays([
          ast.NthWeekday(ast.First, ast.Mon),
          ast.NthWeekday(ast.Last, ast.Mon),
        ]),
      ),
      ast.ExceptDays(
        ast.QualifiedOrdinalDays([ast.NthWeekday(ast.Last, ast.Mon)]),
      ),
      //
    // Bare Ordinals
    //
    // ast.ExceptDays(ast.BareOrdinalDays([ast.DayOfMonth(1)])),
    // ast.ExceptDays(
    //   ast.BareOrdinalDays([
    //     ast.DayOfMonth(1),
    //     ast.DayOfMonth(2),
    //     ast.DayOfMonth(3),
    //   ]),
    // ),
    // ast.ExceptDays(
    //   ast.BareOrdinalDays([ast.DayOfMonth(3), ast.DayOfMonth(4)]),
    // ),
    //
    // Specific Days of the Weeek
    //
    // ast.ExceptDays(ast.SpecificDays([ast.Sun, ast.Mon, ast.Tue])),
    // ast.ExceptDays(ast.SpecificDays(days.weekend())),
    // ast.ExceptDays(ast.SpecificDays(days.weekdays())),
    // ast.ExceptDays(ast.SpecificDays([ast.Sat])),
    ])

  case res {
    Ok(_) -> io.println("ok")
    Error(e) -> utils.debug(e)
  }
}
