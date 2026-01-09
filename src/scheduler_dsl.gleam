import gleam/io
import gleam/string
import simplifile

import library/lexer

pub fn main() {
  case simplifile.read("schedule.txt") {
    Ok(input) -> {
      case lexer.lex(input) {
        Ok(tokens) -> {
          io.println("Tokens:")
          io.println(string.inspect(tokens))
        }
        Error(err) -> {
          io.println("Lexer error:")
          io.println(string.inspect(err))
        }
      }
    }
    Error(_) -> {
      io.println("Could not read schedule.txt")
    }
  }
}
