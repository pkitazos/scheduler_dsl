import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import library/ast.{
  type DayOfWeek, type Days, type Exclusion, type Frequency, type Ordinal,
  type Position, type Schedule, type Time, type Timing,
}

import library/token.{type Token}

pub type ParseError {
  InvalidSchedule(String)
  InvalidFrequency(String)
  InvalidTiming(String)
  InvalidDays(String)
  InvalidTimeRange(String)
  InvalidBounds(String)
  InvalidExclusion(String)
}

pub fn parse(tokens: List(Token)) -> Result(Schedule, ParseError) {
  use #(freq, rest) <- result.try(parse_frequency(tokens))
  use #(timing, rest) <- result.try(parse_timing(rest))
  use #(days, rest) <- result.try(parse_days(rest))
  use #(bounds, rest) <- result.try(parse_bounds(rest))
  use #(exclusions, rest) <- result.try(parse_exclusions(rest))

  case rest {
    [] ->
      Ok(ast.Schedule(
        frequency: freq,
        timing: timing,
        days: days,
        bounds: bounds,
        exclusions: exclusions,
      ))

    rest ->
      Error(InvalidSchedule(
        "unexpected tokens after schedule: `"
        <> token.list_to_string(rest)
        <> "`",
      ))
  }
}

fn parse_frequency(
  tokens: List(Token),
) -> Result(#(Frequency, List(Token)), ParseError) {
  case tokens {
    [token.Once, ..rest] -> Ok(#(ast.Once, rest))
    [token.Hourly, ..rest] -> Ok(#(ast.Hourly, rest))
    [token.Daily, ..rest] -> Ok(#(ast.Daily, rest))
    [token.Weekly, ..rest] -> Ok(#(ast.Weekly, rest))
    [token.Monthly, ..rest] -> Ok(#(ast.Monthly, rest))
    [token.Annually, ..rest] -> Ok(#(ast.Annually, rest))

    [token.Every, token.Second, ..rest] ->
      Ok(#(ast.Every(1, ast.Seconds), rest))
    [token.Every, token.Minute, ..rest] ->
      Ok(#(ast.Every(1, ast.Minutes), rest))
    [token.Every, token.Hour, ..rest] -> Ok(#(ast.Every(1, ast.Hours), rest))
    [token.Every, token.Day, ..rest] -> Ok(#(ast.Every(1, ast.Days), rest))
    [token.Every, token.Week, ..rest] -> Ok(#(ast.Every(1, ast.Weeks), rest))
    [token.Every, token.Month, ..rest] -> Ok(#(ast.Every(1, ast.Months), rest))
    [token.Every, token.Year, ..rest] -> Ok(#(ast.Every(1, ast.Years), rest))

    [token.Every, token.Integer(1), token.Second, ..rest] ->
      Ok(#(ast.Every(1, ast.Seconds), rest))
    [token.Every, token.Integer(1), token.Minute, ..rest] ->
      Ok(#(ast.Every(1, ast.Minutes), rest))
    [token.Every, token.Integer(1), token.Hour, ..rest] ->
      Ok(#(ast.Every(1, ast.Hours), rest))
    [token.Every, token.Integer(1), token.Day, ..rest] ->
      Ok(#(ast.Every(1, ast.Days), rest))
    [token.Every, token.Integer(1), token.Week, ..rest] ->
      Ok(#(ast.Every(1, ast.Weeks), rest))
    [token.Every, token.Integer(1), token.Month, ..rest] ->
      Ok(#(ast.Every(1, ast.Months), rest))
    [token.Every, token.Integer(1), token.Year, ..rest] ->
      Ok(#(ast.Every(1, ast.Years), rest))

    [token.Every, token.Integer(n), token.Seconds, ..rest] ->
      Ok(#(ast.Every(n, ast.Seconds), rest))
    [token.Every, token.Integer(n), token.Minutes, ..rest] ->
      Ok(#(ast.Every(n, ast.Minutes), rest))
    [token.Every, token.Integer(n), token.Hours, ..rest] ->
      Ok(#(ast.Every(n, ast.Hours), rest))
    [token.Every, token.Integer(n), token.Days, ..rest] ->
      Ok(#(ast.Every(n, ast.Days), rest))
    [token.Every, token.Integer(n), token.Weeks, ..rest] ->
      Ok(#(ast.Every(n, ast.Weeks), rest))
    [token.Every, token.Integer(n), token.Months, ..rest] ->
      Ok(#(ast.Every(n, ast.Months), rest))
    [token.Every, token.Integer(n), token.Years, ..rest] ->
      Ok(#(ast.Every(n, ast.Years), rest))

    [token.Every, token.Integer(n), other, ..] ->
      Error(InvalidFrequency(
        "`every "
        <> int.to_string(n)
        <> " "
        <> token.to_string(other)
        <> "` doesn't make sense",
      ))

    [token.Every, token.Integer(n)] ->
      Error(InvalidFrequency("`every " <> int.to_string(n) <> "` is incomplete"))

    [token.Every, other, ..] ->
      Error(InvalidFrequency(
        "`every " <> token.to_string(other) <> "` doesn't make sense",
      ))

    other ->
      Error(InvalidFrequency(
        "`"
        <> token.list_to_string(other)
        <> "` doesn't include a valid frequency",
      ))
  }
}

fn parse_timing(
  tokens: List(Token),
) -> Result(#(Option(Timing), List(Token)), ParseError) {
  case tokens {
    [token.At, token.TimeLiteral(h, m), ..rest] -> {
      let first_time = ast.Time(hour: h, minute: m)
      use #(rest_times, rest2) <- result.try(parse_time_list(rest))
      Ok(#(Some(ast.At(times: [first_time, ..rest_times])), rest2))
    }

    [token.At, ..] -> {
      Error(InvalidTiming("expected time literal HH:mm after `at`"))
    }

    [
      token.From,
      token.TimeLiteral(h1, m1),
      token.To,
      token.TimeLiteral(h2, m2),
      ..rest
    ] ->
      Ok(#(
        Some(ast.TimeRange(
          from: ast.Time(hour: h1, minute: m1),
          to: ast.Time(hour: h2, minute: m2),
        )),
        rest,
      ))

    [token.From, token.TimeLiteral(_, _), token.To, ..] ->
      Error(InvalidTimeRange("expected time after `to`"))

    [token.From, token.TimeLiteral(_, _), ..] ->
      Error(InvalidTimeRange("expected `to` after first time"))

    [token.From, ..] -> Error(InvalidTimeRange("expected time after `from`"))

    _ -> Ok(#(None, tokens))
  }
}

fn parse_time_list(
  tokens: List(Token),
) -> Result(#(List(Time), List(Token)), ParseError) {
  case tokens {
    [token.Comma, token.TimeLiteral(h, m), ..rest] -> {
      let time = ast.Time(hour: h, minute: m)
      use #(more, rest2) <- result.try(parse_time_list(rest))
      Ok(#([time, ..more], rest2))
    }

    [token.And, token.TimeLiteral(h, m), ..rest] ->
      Ok(#([ast.Time(hour: h, minute: m)], rest))

    [token.Comma, ..] -> Error(InvalidTiming("expected time after comma"))

    [token.And, ..] -> Error(InvalidTiming("expected time after `and`"))

    _ -> Ok(#([], tokens))
  }
}

fn parse_days(
  tokens: List(Token),
) -> Result(#(Option(Days), List(Token)), ParseError) {
  case tokens {
    // [token.On, token.Weekdays, ..rest] ->
    //   Ok(#(Some(ast.SpecificDays(days.weekdays())), rest))
    [token.On, token.Weekdays, ..rest] -> Ok(#(Some(ast.Weekdays), rest))

    // [token.On, token.Weekends, ..rest] ->
    //   Ok(#(Some(ast.SpecificDays(days.weekend())), rest))
    [token.On, token.Weekends, ..rest] -> Ok(#(Some(ast.Weekends), rest))

    [token.On, token.The, token.Ordinal(n), ..rest] -> {
      use #(rest_days, rest2) <- result.try(parse_ord_day_list(rest))
      Ok(#(Some(ast.OrdinalDays([ast.DayOfMonth(n), ..rest_days])), rest2))
    }

    [token.On, token.The, token.Last, day_token, ..rest] -> {
      case token_to_weekday(day_token) {
        Ok(day) -> {
          use #(rest_days, rest2) <- result.try(parse_ord_day_list(rest))
          Ok(#(
            Some(
              ast.OrdinalDays([ast.NthWeekday(ast.LastPos, day), ..rest_days]),
            ),
            rest2,
          ))
        }
        Error(_) -> {
          use #(rest_days, rest2) <- result.try(
            parse_ord_day_list([day_token, ..rest]),
          )
          Ok(#(Some(ast.OrdinalDays([ast.Last, ..rest_days])), rest2))
        }
      }
    }

    [token.On, token.The, token.Last, ..rest] -> {
      use #(rest_days, rest2) <- result.try(parse_ord_day_list(rest))
      Ok(#(Some(ast.OrdinalDays([ast.Last, ..rest_days])), rest2))
    }

    [token.On, token.The, position_token, day_token, ..rest] -> {
      use day <- result.try(token_to_weekday(day_token))
      use pos <- result.try(token_to_ordinal_position(position_token))
      use #(rest_days, rest2) <- result.try(parse_ord_day_list(rest))
      Ok(#(
        Some(ast.OrdinalDays([ast.NthWeekday(pos, day), ..rest_days])),
        rest2,
      ))
    }

    [token.On, day_token, ..rest] -> {
      use day <- result.try(token_to_weekday(day_token))
      use #(rest_days, rest2) <- result.try(parse_day_of_week_list(rest))
      Ok(#(Some(ast.SpecificDays([day, ..rest_days])), rest2))
    }

    _ -> Ok(#(None, tokens))
  }
}

fn parse_ord_day_list(
  tokens: List(Token),
) -> Result(#(List(Ordinal), List(Token)), ParseError) {
  case tokens {
    [token.Comma, token.Ordinal(n), ..rest] -> {
      use #(more, rest2) <- result.try(parse_ord_day_list(rest))
      Ok(#([ast.DayOfMonth(n), ..more], rest2))
    }

    [token.Comma, position_token, day_token, ..rest] -> {
      use pos <- result.try(token_to_ordinal_position(position_token))
      use day <- result.try(token_to_weekday(day_token))
      use #(more, rest2) <- result.try(parse_ord_day_list(rest))
      Ok(#([ast.NthWeekday(pos, day), ..more], rest2))
    }

    [token.Comma, token.Last, ..rest] -> {
      use #(more, rest2) <- result.try(parse_ord_day_list(rest))
      Ok(#([ast.Last, ..more], rest2))
    }

    [token.And, token.Ordinal(n), ..rest] -> Ok(#([ast.DayOfMonth(n)], rest))

    [token.And, position_token, day_token, ..rest] -> {
      use pos <- result.try(token_to_ordinal_position(position_token))
      use day <- result.try(token_to_weekday(day_token))
      Ok(#([ast.NthWeekday(pos, day)], rest))
    }

    [token.And, token.Last, ..rest] -> Ok(#([ast.Last], rest))

    [token.Comma, ..] -> Error(InvalidDays("expected ordinal after comma"))
    [token.And, ..] -> Error(InvalidDays("expected ordinal after `and`"))

    _ -> Ok(#([], tokens))
  }
}

fn parse_day_of_week_list(
  tokens: List(Token),
) -> Result(#(List(DayOfWeek), List(Token)), ParseError) {
  case tokens {
    [token.Comma, day_token, ..rest] -> {
      use day <- result.try(token_to_weekday(day_token))
      use #(more, rest2) <- result.try(parse_day_of_week_list(rest))
      Ok(#([day, ..more], rest2))
    }

    [token.And, day_token, ..rest] -> {
      use day <- result.try(token_to_weekday(day_token))
      Ok(#([day], rest))
    }

    [token.Comma, ..] -> Error(InvalidDays("expected day after comma"))

    [token.And, ..] -> Error(InvalidDays("expected day after `and`"))

    _ -> Ok(#([], tokens))
  }
}

fn token_to_weekday(tok: Token) -> Result(DayOfWeek, ParseError) {
  case tok {
    token.Mon -> Ok(ast.Mon)
    token.Tue -> Ok(ast.Tue)
    token.Wed -> Ok(ast.Wed)
    token.Thu -> Ok(ast.Thu)
    token.Fri -> Ok(ast.Fri)
    token.Sat -> Ok(ast.Sat)
    token.Sun -> Ok(ast.Sun)
    _ -> Error(InvalidDays("token not a valid day"))
  }
}

fn token_to_ordinal_position(tok: Token) -> Result(Position, ParseError) {
  case tok {
    token.First -> Ok(ast.First)
    token.Second -> Ok(ast.Second)
    token.Third -> Ok(ast.Third)
    token.Fourth -> Ok(ast.Fourth)
    token.Fifth -> Ok(ast.Fifth)
    token.Last -> Ok(ast.LastPos)
    _ -> Error(InvalidDays("expected position"))
  }
}

fn parse_bounds(
  tokens: List(Token),
) -> Result(#(Option(ast.Bounds), List(Token)), ParseError) {
  case tokens {
    [
      token.Starting,
      token.DateLiteral(year1, month1, day1),
      token.At,
      token.TimeLiteral(hour1, minute1),
      token.Until,
      token.DateLiteral(year2, month2, day2),
      token.At,
      token.TimeLiteral(hour2, minute2),
      ..rest
    ] -> {
      Ok(#(
        Some(ast.Between(
          from: ast.BoundPoint(
            date: ast.Date(year: year1, month: month1, day: day1),
            time: Some(ast.Time(hour: hour1, minute: minute1)),
          ),
          to: ast.BoundPoint(
            date: ast.Date(year: year2, month: month2, day: day2),
            time: Some(ast.Time(hour: hour2, minute: minute2)),
          ),
        )),
        rest,
      ))
    }

    [
      token.Starting,
      token.DateLiteral(year1, month1, day1),
      token.At,
      token.TimeLiteral(hour1, minute1),
      token.Until,
      token.DateLiteral(year2, month2, day2),
      ..rest
    ] -> {
      Ok(#(
        Some(ast.Between(
          from: ast.BoundPoint(
            date: ast.Date(year: year1, month: month1, day: day1),
            time: Some(ast.Time(hour: hour1, minute: minute1)),
          ),
          to: ast.BoundPoint(
            date: ast.Date(year: year2, month: month2, day: day2),
            time: None,
          ),
        )),
        rest,
      ))
    }

    [
      token.Starting,
      token.DateLiteral(year1, month1, day1),
      token.Until,
      token.DateLiteral(year2, month2, day2),
      token.At,
      token.TimeLiteral(hour2, minute2),
      ..rest
    ] -> {
      Ok(#(
        Some(ast.Between(
          from: ast.BoundPoint(
            date: ast.Date(year: year1, month: month1, day: day1),
            time: None,
          ),
          to: ast.BoundPoint(
            date: ast.Date(year: year2, month: month2, day: day2),
            time: Some(ast.Time(hour: hour2, minute: minute2)),
          ),
        )),
        rest,
      ))
    }

    [
      token.Starting,
      token.DateLiteral(year1, month1, day1),
      token.Until,
      token.DateLiteral(year2, month2, day2),
      ..rest
    ] -> {
      Ok(#(
        Some(ast.Between(
          from: ast.BoundPoint(
            date: ast.Date(year: year1, month: month1, day: day1),
            time: None,
          ),
          to: ast.BoundPoint(
            date: ast.Date(year: year2, month: month2, day: day2),
            time: None,
          ),
        )),
        rest,
      ))
    }

    [
      token.Starting,
      token.DateLiteral(_, _, _),
      token.At,
      token.TimeLiteral(_, _),
      token.Until,
      ..
    ] -> Error(InvalidBounds("expected date after `until`"))

    [token.Starting, token.DateLiteral(_, _, _), token.Until, ..] ->
      Error(InvalidBounds("expected date after `until`"))

    [
      token.Starting,
      token.DateLiteral(year, month, day),
      token.At,
      token.TimeLiteral(hour, minute),
      ..rest
    ] -> {
      Ok(#(
        Some(
          ast.Starting(ast.BoundPoint(
            date: ast.Date(year: year, month: month, day: day),
            time: Some(ast.Time(hour: hour, minute: minute)),
          )),
        ),
        rest,
      ))
    }

    [token.Starting, token.DateLiteral(year, month, day), ..rest] -> {
      Ok(#(
        Some(
          ast.Starting(ast.BoundPoint(
            date: ast.Date(year: year, month: month, day: day),
            time: None,
          )),
        ),
        rest,
      ))
    }

    [token.Starting, ..] ->
      Error(InvalidBounds("expected date after `starting`"))

    [token.Until, ..] -> Error(InvalidBounds("expected date after `until`"))
    _ -> Ok(#(None, tokens))
  }
}

fn require(option: Option(a), error: ParseError) -> Result(a, ParseError) {
  case option {
    Some(value) -> Ok(value)
    None -> Error(error)
  }
}

fn parse_exclusions(
  tokens: List(Token),
) -> Result(#(Option(List(Exclusion)), List(Token)), ParseError) {
  case tokens {
    [token.Except, ..] -> {
      use #(exclusions, rest) <- result.try(collect_exclusions(tokens, []))
      Ok(#(Some(exclusions), rest))
    }
    _ -> Ok(#(None, tokens))
  }
}

fn collect_exclusions(
  tokens: List(Token),
  acc: List(Exclusion),
) -> Result(#(List(Exclusion), List(Token)), ParseError) {
  use #(maybe_excl, rest) <- result.try(parse_single_exclusion(tokens))
  case maybe_excl {
    None -> Ok(#(list.reverse(acc), tokens))
    Some(excl) -> collect_exclusions(rest, [excl, ..acc])
  }
}

fn parse_single_exclusion(
  tokens: List(Token),
) -> Result(#(Option(Exclusion), List(Token)), ParseError) {
  case tokens {
    [token.Except, token.From, ..rest] -> {
      use #(maybe_timing, rest2) <- result.try(
        parse_timing([token.From, ..rest]),
      )

      use timing <- result.try(require(
        maybe_timing,
        InvalidExclusion("expected time range after `except from`"),
      ))

      Ok(#(Some(ast.ExceptTime(timing)), rest2))
    }

    [token.Except, token.At, ..rest] -> {
      use #(maybe_timing, rest2) <- result.try(parse_timing([token.At, ..rest]))

      use timing <- result.try(require(
        maybe_timing,
        InvalidExclusion("expected time after `except at`"),
      ))

      Ok(#(Some(ast.ExceptTime(timing)), rest2))
    }

    [token.Except, token.On, ..rest] -> {
      use #(maybe_days, rest2) <- result.try(parse_days([token.On, ..rest]))

      use days <- result.try(require(
        maybe_days,
        InvalidExclusion("expected days after `except on`"),
      ))

      Ok(#(Some(ast.ExceptDays(days)), rest2))
    }

    [token.Except, token.Starting, ..rest] -> {
      use #(maybe_bounds, rest2) <- result.try(
        parse_bounds([token.Starting, ..rest]),
      )

      use bounds <- result.try(require(
        maybe_bounds,
        InvalidExclusion("expected bounds expression after `except starting`"),
      ))

      Ok(#(Some(ast.ExceptBounds(bounds)), rest2))
    }

    [token.Except, ..] ->
      Error(InvalidExclusion("expected days or time range after `except`"))

    _ -> Ok(#(None, tokens))
  }
}
