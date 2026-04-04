import gleam/io
import gleam/result
import gleam/string
import library/lexer
import library/parser
import simplifile

pub fn main() {
  let result = {
    use input <- result.try(
      simplifile.read("schedule.txt") |> result.map_error(string.inspect),
    )

    use tokens <- result.try(
      lexer.lex(input) |> result.map_error(string.inspect),
    )

    use schedule <- result.try(
      parser.parse(tokens) |> result.map_error(string.inspect),
    )

    Ok(schedule)
  }

  case result {
    Ok(schedule) -> io.println(string.inspect(schedule))
    Error(msg) -> io.println(msg)
  }
}
