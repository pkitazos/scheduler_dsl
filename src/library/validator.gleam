import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import library/ast

// - [ ] frequency
// - [ ] timing
// - [ ] days
// - [/] bounds
// - [ ] exclusion

pub type ValidatorError {
  InvalidFrequency(String, ast.Frequency)
  InvalidDate(String, ast.Date)
  InvalidBounds(String, ast.Bounds)
  InvalidTime(String, ast.Time)
  InvalidTimeRange(String, ast.Timing)
  InvalidTimeList(String, List(ast.Time))
}

// todo: this is obviously bad and will get fixed once I'm done writing the individual functions
pub fn validate(schedule: ast.Schedule) -> Result(ast.Schedule, ValidatorError) {
  use _frequency <- result.try(validate_frequency(schedule.frequency))

  case schedule.timing {
    Some(timing) -> {
      use timing <- result.try(validate_timing(timing))

      case schedule.bounds {
        Some(bounds) -> {
          use bounds <- result.try(validate_bounds(bounds))

          Ok(
            ast.Schedule(..schedule, timing: Some(timing), bounds: Some(bounds)),
          )
        }

        None -> Ok(ast.Schedule(..schedule, timing: Some(timing)))
      }
    }

    None -> {
      case schedule.bounds {
        Some(bounds) -> {
          use bounds <- result.try(validate_bounds(bounds))

          Ok(ast.Schedule(..schedule, bounds: Some(bounds)))
        }

        None -> Ok(schedule)
      }
    }
  }
}

fn validate_frequency(
  freq: ast.Frequency,
) -> Result(ast.Frequency, ValidatorError) {
  case freq {
    ast.Every(amount: 0, unit: _) ->
      Error(InvalidFrequency("frequency can't be 0", freq))

    _ -> Ok(freq)
  }
}

fn validate_timing(timing: ast.Timing) -> Result(ast.Timing, ValidatorError) {
  case timing {
    ast.TimeRange(from, to) if from == to -> {
      use _from <- result.try(validate_time_result(from))
      Error(InvalidTimeRange("invalid range", timing))
    }

    ast.TimeRange(from, to) -> {
      use _from <- result.try(validate_time_result(from))
      use _to <- result.try(validate_time_result(to))
      Ok(timing)
    }

    ast.At(times) -> {
      use _times <- result.try(list.try_map(times, validate_time_result))

      case find_duplicates(times) {
        [] -> Ok(timing)
        dups ->
          Error(InvalidTimeList("invalid time list, contains duplicates", dups))
      }
    }
  }
}

fn find_duplicates(xs: List(a)) -> List(a) {
  xs
  |> list.fold(dict.new(), fn(acc, x) {
    dict.upsert(acc, x, fn(count) { option.unwrap(count, 0) + 1 })
  })
  |> dict.filter(fn(_, value) { value > 1 })
  |> dict.keys
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

      use _ <- result.try(options_symmetric(
        start_time,
        end_time,
        InvalidBounds("both bounds must have times or neither should", bounds),
      ))

      let start = ast.BoundPoint(start_date, start_time)
      let end = ast.BoundPoint(end_date, end_time)

      case validate_bound_point_order(start, end) {
        True -> Ok(bounds)
        False ->
          Error(InvalidBounds("end date must be after start date", bounds))
      }
    }
  }
}

fn date_cmp(d1: ast.Date, d2: ast.Date) -> order.Order {
  case int.compare(d1.year, d2.year) {
    order.Eq ->
      case int.compare(d1.month, d2.month) {
        order.Eq -> int.compare(d1.day, d2.day)
        ord -> ord
      }
    ord -> ord
  }
}

fn bound_point_cmp(b1: ast.BoundPoint, b2: ast.BoundPoint) -> order.Order {
  case date_cmp(b1.date, b2.date) {
    order.Eq ->
      case b1.time, b2.time {
        Some(t1), Some(t2) ->
          case int.compare(t1.hour, t2.hour) {
            order.Eq -> int.compare(t1.minute, t2.minute)
            ord -> ord
          }
        _, _ -> order.Eq
      }
    ord -> ord
  }
}

fn validate_bound_point_order(
  start: ast.BoundPoint,
  end: ast.BoundPoint,
) -> Bool {
  bound_point_cmp(start, end) == order.Lt
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

/// Checks that two Options are both Some or both None.
fn options_symmetric(a: Option(a), b: Option(b), err: e) -> Result(Nil, e) {
  case a, b {
    Some(_), Some(_) | None, None -> Ok(Nil)
    _, _ -> Error(err)
  }
}
