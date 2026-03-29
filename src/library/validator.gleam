import gleam/option.{type Option, None, Some}
import gleam/result
import library/ast

// - [ ] frequency
// - [ ] timing
// - [ ] days
// - [ ] time_range
// - [/] bounds
// - [ ] exclusion

pub type ValidatorError {
  InvalidDate(String, ast.Date)
  InvalidTime(String, ast.Time)
}

pub fn validate(schedule: ast.Schedule) -> Result(ast.Schedule, ValidatorError) {
  case schedule.bounds {
    Some(bounds) -> {
      use bounds <- result.try(validate_bounds(bounds))
      Ok(ast.Schedule(..schedule, bounds: Some(bounds)))
    }
    None -> Ok(schedule)
  }
}

fn validate_bounds(bounds: ast.Bounds) -> Result(ast.Bounds, ValidatorError) {
  case bounds {
    ast.Starting(ast.BoundPoint(date, time)) -> {
      use date <- result.try(guard(
        date,
        validate_date,
        InvalidDate("invalid date", date),
      ))

      use time <- result.try(option_try(time, validate_time_result))
      Ok(ast.Starting(ast.BoundPoint(date, time)))
    }

    ast.Between(
      ast.BoundPoint(start_date, start_time),
      ast.BoundPoint(end_date, end_time),
    ) -> {
      use start_date <- result.try(guard(
        start_date,
        validate_date,
        InvalidDate("invalid date", start_date),
      ))

      use start_time <- result.try(option_try(start_time, validate_time_result))

      use end_date <- result.try(guard(
        end_date,
        validate_date,
        InvalidDate("invalid date", end_date),
      ))

      use end_time <- result.try(option_try(end_time, validate_time_result))

      Ok(ast.Between(
        ast.BoundPoint(start_date, start_time),
        ast.BoundPoint(end_date, end_time),
      ))
    }
  }
}

fn validate_date(date: ast.Date) -> Bool {
  let ast.Date(year, month, day) = date
  let is_leap = year % 4 == 0 && { year % 100 != 0 || year % 400 == 0 }

  let days_in_month = case month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
    4 | 6 | 9 | 11 -> 30
    2 if is_leap -> 29
    2 -> 28
    _ -> 0
  }

  year >= 1 && month >= 1 && month <= 12 && day >= 1 && day <= days_in_month
}

fn validate_time(time: ast.Time) -> Bool {
  let ast.Time(hour, minute) = time
  hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59
}

fn validate_time_result(time: ast.Time) -> Result(ast.Time, ValidatorError) {
  case validate_time(time) {
    True -> Ok(time)
    False -> Error(InvalidTime("invalid time", time))
  }
}

// --- Generic helpers

/// Wraps a clause in a Result if it satisfies a predicate.
fn guard(clause: a, f: fn(a) -> Bool, b) -> Result(a, b) {
  case f(clause) {
    True -> Ok(clause)
    False -> Error(b)
  }
}

/// Apply a fallible function to an Option's inner value.
/// None passes through as Ok(None).
/// Some(a) becomes Ok(Some(a)) if f succeeds, or Error(e) if it fails.
fn option_try(opt: Option(a), f: fn(a) -> Result(b, e)) -> Result(Option(b), e) {
  case opt {
    None -> Ok(None)
    Some(value) -> result.map(f(value), Some)
  }
}
