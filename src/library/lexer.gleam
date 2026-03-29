import gleam/int
import gleam/list
import gleam/result
import gleam/string
import library/token.{type Token}

pub type LexError {
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
    "," <> rest -> Ok(#(token.Comma, rest))

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
      Ok(#(token.TimeLiteral(hour, minute), string.concat(rest)))
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
      Ok(#(token.DateLiteral(year, month, day), string.concat(rest)))
    }
    _ -> Error(InvalidDate(input))
  }
}

fn lex_word_or_number(input: String) -> Result(#(Token, String), LexError) {
  let #(word, rest) = take_while(input, is_alphanumeric)

  case word {
    // Keywords
    "every" -> Ok(#(token.Every, rest))
    "at" -> Ok(#(token.At, rest))
    "on" -> Ok(#(token.On, rest))
    "the" -> Ok(#(token.The, rest))
    "and" -> Ok(#(token.And, rest))
    "except" -> Ok(#(token.Except, rest))
    "starting" -> Ok(#(token.Starting, rest))
    "until" -> Ok(#(token.Until, rest))
    "from" -> Ok(#(token.From, rest))
    "to" -> Ok(#(token.To, rest))

    // Frequency shortcuts
    "once" -> Ok(#(token.Once, rest))
    "hourly" -> Ok(#(token.Hourly, rest))
    "daily" -> Ok(#(token.Daily, rest))
    "weekly" -> Ok(#(token.Weekly, rest))
    "monthly" -> Ok(#(token.Monthly, rest))
    "annually" -> Ok(#(token.Annually, rest))

    // Time units
    "second" -> Ok(#(token.Second, rest))
    "seconds" -> Ok(#(token.Seconds, rest))
    "minute" -> Ok(#(token.Minute, rest))
    "minutes" -> Ok(#(token.Minutes, rest))
    "hour" -> Ok(#(token.Hour, rest))
    "hours" -> Ok(#(token.Hours, rest))
    "day" -> Ok(#(token.Day, rest))
    "days" -> Ok(#(token.Days, rest))
    "week" -> Ok(#(token.Week, rest))
    "weeks" -> Ok(#(token.Weeks, rest))
    "month" -> Ok(#(token.Month, rest))
    "months" -> Ok(#(token.Months, rest))
    "year" -> Ok(#(token.Year, rest))
    "years" -> Ok(#(token.Years, rest))

    // Day groups
    "weekdays" -> Ok(#(token.Weekdays, rest))
    "weekends" -> Ok(#(token.Weekends, rest))

    // Days
    "monday" -> Ok(#(token.Mon, rest))
    "tuesday" -> Ok(#(token.Tue, rest))
    "wednesday" -> Ok(#(token.Wed, rest))
    "thursday" -> Ok(#(token.Thu, rest))
    "friday" -> Ok(#(token.Fri, rest))
    "saturday" -> Ok(#(token.Sat, rest))
    "sunday" -> Ok(#(token.Sun, rest))

    // Ordinal positions
    "first" -> Ok(#(token.First, rest))
    // second handled in units
    "third" -> Ok(#(token.Third, rest))
    "fourth" -> Ok(#(token.Fourth, rest))
    "fifth" -> Ok(#(token.Fifth, rest))
    "last" -> Ok(#(token.Last, rest))

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
      Ok(#(token.Ordinal(n), rest))
    }

    False -> {
      use n <- result.try(
        word
        |> int.parse()
        |> result.replace_error(InvalidNumber(word)),
      )
      Ok(#(token.Integer(n), rest))
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
