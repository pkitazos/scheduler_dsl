import gleam/int
import gleam/list
import gleam/result
import gleam/string
import library/token.{
  type Token, And, Annually, At, Between, Comma, Daily, DateLiteral, Day, Days,
  Every, Except, First, Fourth, Friday, From, Hour, Hourly, Hours, Integer, Last,
  Minute, Minutes, Monday, Monthly, On, Ordinal, Saturday, Second, Seconds,
  Starting, Sunday, The, Third, Thursday, TimeLiteral, Tuesday, Until, Wednesday,
  Weekdays, Weekend, Weekly,
}

pub type LexError {
  UnexpectedCharacter(String)
  InvalidNumber(String)
  InvalidTime(String)
  InvalidDate(String)
}

pub fn lex(input: String) -> Result(List(Token), LexError) {
  input
  |> string.trim
  |> string.lowercase
  |> lex_tokens([])
}

fn lex_tokens(input: String, acc: List(Token)) -> Result(List(Token), LexError) {
  case string.trim_start(input) {
    "" -> Ok(list.reverse(acc))
    trimmed -> {
      use #(token, rest) <- result.try(lex_one(trimmed))
      lex_tokens(rest, [token, ..acc])
    }
  }
}

fn lex_one(input: String) -> Result(#(Token, String), LexError) {
  case input {
    "," <> rest -> Ok(#(Comma, rest))

    _ -> {
      lex_time(input)
      |> result.lazy_or(fn() { lex_date(input) })
      |> result.lazy_or(fn() { lex_word_or_number(input) })
    }
  }
}

fn lex_time(input: String) -> Result(#(Token, String), LexError) {
  case string.to_graphemes(input) {
    // matches HH:MM pattern
    [h1, h2, ":", m1, m2, ..rest] -> {
      use hour <- result.try(
        int.parse(h1 <> h2) |> result.replace_error(InvalidTime(input)),
      )
      use minute <- result.try(
        int.parse(m1 <> m2) |> result.replace_error(InvalidTime(input)),
      )
      Ok(#(TimeLiteral(hour, minute), string.concat(rest)))
    }
    _ -> Error(InvalidTime(input))
  }
}

fn lex_date(input: String) -> Result(#(Token, String), LexError) {
  case string.to_graphemes(input) {
    // matches YYYY-MM-DD pattern
    [y1, y2, y3, y4, "-", m1, m2, "-", d1, d2, ..rest] -> {
      use year <- result.try(
        int.parse(y1 <> y2 <> y3 <> y4)
        |> result.replace_error(InvalidDate(input)),
      )
      use month <- result.try(
        int.parse(m1 <> m2) |> result.replace_error(InvalidDate(input)),
      )
      use day <- result.try(
        int.parse(d1 <> d2) |> result.replace_error(InvalidDate(input)),
      )
      Ok(#(DateLiteral(year, month, day), string.concat(rest)))
    }
    _ -> Error(InvalidDate(input))
  }
}

fn lex_word_or_number(input: String) -> Result(#(Token, String), LexError) {
  let #(word, rest) = take_while(input, is_alphanumeric)

  case word {
    // Keywords
    "every" -> Ok(#(Every, rest))
    "at" -> Ok(#(At, rest))
    "on" -> Ok(#(On, rest))
    "the" -> Ok(#(The, rest))
    "and" -> Ok(#(And, rest))
    "between" -> Ok(#(Between, rest))
    "except" -> Ok(#(Except, rest))
    "starting" -> Ok(#(Starting, rest))
    "until" -> Ok(#(Until, rest))
    "from" -> Ok(#(From, rest))

    // Frequency shortcuts
    "hourly" -> Ok(#(Hourly, rest))
    "daily" -> Ok(#(Daily, rest))
    "weekly" -> Ok(#(Weekly, rest))
    "monthly" -> Ok(#(Monthly, rest))
    "annually" -> Ok(#(Annually, rest))

    // Time units
    "second" -> Ok(#(Second, rest))
    "seconds" -> Ok(#(Seconds, rest))
    "minute" -> Ok(#(Minute, rest))
    "minutes" -> Ok(#(Minutes, rest))
    "hour" -> Ok(#(Hour, rest))
    "hours" -> Ok(#(Hours, rest))
    "day" -> Ok(#(Day, rest))
    "days" -> Ok(#(Days, rest))

    // Day groups
    "weekdays" -> Ok(#(Weekdays, rest))
    "weekend" -> Ok(#(Weekend, rest))

    // Days
    "monday" -> Ok(#(Monday, rest))
    "tuesday" -> Ok(#(Tuesday, rest))
    "wednesday" -> Ok(#(Wednesday, rest))
    "thursday" -> Ok(#(Thursday, rest))
    "friday" -> Ok(#(Friday, rest))
    "saturday" -> Ok(#(Saturday, rest))
    "sunday" -> Ok(#(Sunday, rest))

    // Ordinal positions
    "first" -> Ok(#(First, rest))
    // second handled in units
    "third" -> Ok(#(Third, rest))
    "fourth" -> Ok(#(Fourth, rest))
    "last" -> Ok(#(Last, rest))

    // Ordinals like "1st", "2nd", "3rd", "15th"
    _ -> lex_number_or_ordinal(word, rest)
  }
}

fn lex_number_or_ordinal(
  word: String,
  rest: String,
) -> Result(#(Token, String), LexError) {
  case
    string.ends_with(word, "st")
    || string.ends_with(word, "nd")
    || string.ends_with(word, "rd")
    || string.ends_with(word, "th")
  {
    True -> {
      use n <- result.try(
        word
        |> string.drop_end(2)
        |> int.parse()
        |> result.replace_error(InvalidNumber(word)),
      )
      Ok(#(Ordinal(n), rest))
    }

    False -> {
      use n <- result.try(
        word
        |> int.parse()
        |> result.replace_error(InvalidNumber(word)),
      )
      Ok(#(Integer(n), rest))
    }
  }
}

fn take_while(input: String, pred: fn(String) -> Bool) -> #(String, String) {
  case string.pop_grapheme(input) {
    Error(Nil) -> #("", "")
    Ok(#(char, rest)) -> {
      case pred(char) {
        True -> {
          let #(matched, remaining) = take_while(rest, pred)
          #(char <> matched, remaining)
        }
        False -> #("", input)
      }
    }
  }
}

fn is_alphanumeric(char: String) -> Bool {
  case string.to_utf_codepoints(char) {
    [cp] -> {
      let n = string.utf_codepoint_to_int(cp)
      { n >= 97 && n <= 122 }
      || { n >= 65 && n <= 90 }
      || { n >= 48 && n <= 57 }
    }
    _ -> False
  }
}
