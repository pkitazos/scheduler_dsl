import gleam/int
import gleam/list
import gleam/string

pub type Token {
  // Keywords
  Every
  At
  On
  The
  And
  Except
  Starting
  Until
  From
  To

  // Frequency shortcuts
  Once
  Hourly
  Daily
  Weekly
  Monthly
  Annually

  // Time units
  Second
  Seconds
  Minute
  Minutes
  Hour
  Hours
  Day
  Days
  Week
  Weeks
  Month
  Months
  Year
  Years

  // Day groups
  Weekdays
  Weekends

  // Days of week
  Mon
  Tue
  Wed
  Thu
  Fri
  Sat
  Sun

  // Ordinal positions
  First
  // "second" is lexed as the time-unit token `Second`; the parser
  // reuses it as an ordinal position (2nd) via context-based disambiguation
  Third
  Fourth
  Fifth
  Last

  // Literals
  Integer(Int)
  Ordinal(Int)
  // 1st, 2nd, 3rd, 15th — stores just the number
  TimeLiteral(Int, Int)
  // 09:00 — stores hour, minute
  DateLiteral(Int, Int, Int)

  // 2024-01-15 — stores year, month, day
  // Punctuation
  Comma
}

pub fn to_string(tok: Token) -> String {
  case tok {
    Every -> "every"
    At -> "at"
    On -> "on"
    The -> "the"
    And -> "and"
    Except -> "except"
    Starting -> "starting"
    Until -> "until"
    From -> "from"
    To -> "to"
    Once -> "once"
    Hourly -> "hourly"
    Daily -> "daily"
    Weekly -> "weekly"
    Monthly -> "monthly"
    Annually -> "annually"
    Second -> "second"
    Seconds -> "seconds"
    Minute -> "minute"
    Minutes -> "minutes"
    Hour -> "hour"
    Hours -> "hours"
    Day -> "day"
    Days -> "days"
    Week -> "week"
    Weeks -> "weeks"
    Month -> "month"
    Months -> "months"
    Year -> "year"
    Years -> "years"
    Weekdays -> "weekdays"
    Weekends -> "weekends"
    Mon -> "monday"
    Tue -> "tuesday"
    Wed -> "wednesday"
    Thu -> "thursday"
    Fri -> "friday"
    Sat -> "saturday"
    Sun -> "sunday"
    First -> "first"
    Third -> "third"
    Fourth -> "fourth"
    Fifth -> "fifth"
    Last -> "last"
    Integer(n) -> int.to_string(n)
    Ordinal(n) -> int.to_string(n) <> ordinal_suffix(n)
    TimeLiteral(h, m) -> pad2(h) <> ":" <> pad2(m)
    DateLiteral(y, m, d) -> int.to_string(y) <> "-" <> pad2(m) <> "-" <> pad2(d)
    Comma -> ","
  }
}

pub fn list_to_string(tokens: List(Token)) -> String {
  tokens
  |> list.map(to_string)
  |> string.join(" ")
}

fn pad2(n: Int) -> String {
  case n < 10 {
    True -> "0" <> int.to_string(n)
    False -> int.to_string(n)
  }
}

fn ordinal_suffix(n: Int) -> String {
  let mod100 = n % 100
  case mod100 >= 11 && mod100 <= 13 {
    True -> "th"
    False ->
      case n % 10 {
        1 -> "st"
        2 -> "nd"
        3 -> "rd"
        _ -> "th"
      }
  }
}
