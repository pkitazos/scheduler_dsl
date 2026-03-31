import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/order
import gleam/result
import gleam/string
import library/ast
import library/ast/days
import library/utils.{find_duplicates, guard, option_try, options_symmetric}

// - [/] frequency
// - [/] timing
// - [/] days
// - [/] bounds
// - [ ] exclusion

pub type ValidatorError {
  InvalidFrequency(String, ast.Frequency)
  InvalidTime(String, ast.Time)
  InvalidTimeRange(String, ast.Timing)
  InvalidTimeList(String, List(ast.Time))
  InvalidDaysList(String, ast.Days)
  InvalidDaysOfWeek(String, List(ast.DayOfWeek))
  InvalidOrdinalDays(String, List(ast.Ordinal))
  InvalidDayOfMonth(String, ast.Ordinal)
  InvalidBounds(String, ast.Bounds)
  InvalidDate(String, ast.Date)
  InvalidExclusions(String, List(ast.Exclusion))
  InvalidExclusionsDays(String)
}

pub fn validate(schedule: ast.Schedule) -> Result(ast.Schedule, ValidatorError) {
  use _ <- result.try(validate_frequency(schedule.frequency))
  use _ <- result.try(option_try(schedule.timing, validate_timing))
  use _ <- result.try(option_try(schedule.days, validate_days))
  use _ <- result.try(option_try(schedule.bounds, validate_bounds))

  Ok(schedule)
}

fn validate_frequency(
  freq: ast.Frequency,
) -> Result(ast.Frequency, ValidatorError) {
  case freq {
    ast.Every(amount: n, unit: _) if n < 1 ->
      Error(InvalidFrequency("frequency must be 1 or more", freq))

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

    ast.At([]) -> Error(InvalidTimeList("empty list", []))
    ast.At(times) -> {
      use _times <- result.try(list.try_map(times, validate_time_result))

      use _times <- result.try(
        no_duplicates(times, fn(dups) {
          InvalidTimeList("invalid time list, contains duplicates", dups)
        }),
      )

      Ok(timing)
    }
  }
}

fn validate_days(days: ast.Days) -> Result(ast.Days, ValidatorError) {
  case days {
    ast.Weekdays -> Ok(ast.Weekdays)

    ast.Weekends -> Ok(ast.Weekends)

    ast.SpecificDays([]) -> Error(InvalidDaysOfWeek("empty list", []))

    ast.SpecificDays(days_of_week) -> {
      use _days_of_week <- result.try(
        no_duplicates(days_of_week, fn(dups) {
          InvalidDaysOfWeek("duplicate days of week", dups)
        }),
      )

      Ok(days)
    }

    ast.OrdinalDays(ordinals) -> {
      use _ordinals <- result.try(
        no_duplicates(ordinals, fn(dups) {
          InvalidOrdinalDays("duplicate ordinal days", dups)
        }),
      )

      use _ <- result.try(case ordinals {
        [x, ..xs] -> {
          xs
          |> list.try_fold(x, fn(acc, val) {
            case acc, val {
              ast.DayOfMonth(_), ast.DayOfMonth(_)
              | ast.DayOfMonth(_), ast.Last
              | ast.Last, ast.Last
              | ast.Last, ast.DayOfMonth(_)
              -> Ok(acc)
              ast.NthWeekday(_, _), ast.NthWeekday(_, _) -> Ok(acc)
              // todo: mixed bare/qualified ordinals are valid but we should emit an informational message here
              _, _ -> Ok(acc)
            }
          })
        }

        [] -> Error(InvalidOrdinalDays("empty list", []))
      })

      use _ordinals <- result.try(
        list.try_map(ordinals, fn(o) {
          case o {
            ast.DayOfMonth(n) if n > 31 || n < 1 ->
              Error(InvalidDayOfMonth("invalid day of month", ast.DayOfMonth(n)))
            _ -> Ok(o)
          }
        }),
      )

      Ok(days)
    }
  }
}

fn no_duplicates(xs: List(a), err_f: fn(List(a)) -> b) -> Result(List(a), b) {
  case find_duplicates(xs) {
    [] -> Ok(xs)
    dups -> Error(err_f(dups))
  }
}

fn validate_bounds(bounds: ast.Bounds) -> Result(ast.Bounds, ValidatorError) {
  case bounds {
    ast.Starting(ast.BoundPoint(date, time)) -> {
      use _date <- result.try(guard(
        date,
        validate_date,
        InvalidDate("invalid date", date),
      ))

      use _time <- result.try(option_try(time, validate_time_result))
      Ok(bounds)
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

// - [ ] reject exclusion that is a strict subset of another exclusion
pub fn validate_exclusions(
  exclusions: List(ast.Exclusion),
) -> Result(List(ast.Exclusion), ValidatorError) {
  case exclusions {
    [] -> Error(InvalidExclusions("empty list", []))
    xs -> {
      use _ <- result.try(
        no_duplicates(xs, fn(dups) {
          InvalidExclusions("duplicate exclusions", dups)
        }),
      )

      use _ <- result.try(
        xs
        |> list.filter_map(fn(x) {
          case x {
            ast.ExceptDays(ys) -> Ok(ys)
            _ -> Error(Nil)
          }
        })
        |> handle_specific_days_simple_overlap,
        // |> handle_oridnal_days_simple_overlap
      )

      // for now we just discard the times and bounds cause we're only working on the days validation

      let _times =
        list.filter_map(xs, fn(x) {
          case x {
            ast.ExceptTime(ys) -> Ok(ys)
            _ -> Error(Nil)
          }
        })
      // then I would follow the same pattern her

      let _bounds =
        list.filter_map(xs, fn(x) {
          case x {
            ast.ExceptBounds(ys) -> Ok(ys)
            _ -> Error(Nil)
          }
        })
      // and here
      // where I would create a pipeline of the different kinds of validations
      // I already have well defined rules that should be enforced for `time` and `bounds`
      // it's just a matter of creating the proper pipeline functions

      // then finally, when all the pipelines are in place, I would probably hae to convert them into `use` expressions
      // and then I can just return `Ok(exclusions)` like I'm doing here and any `Error`s returned by the pipelines
      // would short-circuit the function and return

      Ok(exclusions)
    }
  }
}

fn handle_specific_days_simple_overlap(
  days: List(ast.Days),
) -> Result(List(ast.Days), ValidatorError) {
  use _ <- result.try(
    days
    |> list.combination_pairs
    |> list.try_each(fn(p) {
      case days.overlap_with(p.0, p.1) {
        Ok(days.Subset(a, b)) -> {
          Error(InvalidExclusionsDays(
            string.inspect(a) <> " is contained within " <> string.inspect(b),
          ))
        }
        Ok(days.Intersection(_, _, _)) -> {
          // todo: make this a warning later on
          Ok(Nil)
        }
        Ok(days.Disjoint) -> {
          // genuinely no overlap, this one is fine to pass through
          Ok(Nil)
        }
        Error(_) -> {
          // separate ordinal exclusions may overlap, that is handled elsewhere
          // ordinal-vs-non-ordinal overlap is also handled in a separate pass
          // since it requires bounds context to resolve
          Ok(Nil)
        }
      }
    }),
  )

  Ok(days)
  // todo (v2): Minimize exclusion set
  // Given a list of day exclusions, compute the smallest equivalent set.
  //
  // For example, [Sun, Mon, Tue], [Weekends], [Weekdays], [Sat] can be
  // reduced to just [Weekends, Weekdays]. This is an optimization pass,
  // not a validation concern and should live in a separate phase after
  // validation has confirmed all exclusions are individually sound.
  // Related: if the minimal set covers all 7 days, that's equivalent to
  // "every day" which might warrant a cross-clause warning.
}

fn handle_oridnal_days_simple_overlap(
  days: List(ast.Days),
) -> Result(List(ast.Days), ValidatorError) {
  // todo: skip over non `ast.OrdinalDays`
  // for the remaining `ast.OrdinalDays` we need to check
  // if any given list of days fully contains some other list of days
  //
  // so for example:
  //  { 1st, 2nd, 3rd, 4th } fully contains { 2nd, 4th }
  // but:
  //  { 1st, 2nd, 3rd, 4th } only partially contains { 4th, 5th, 6th }
  //
  // the mechanics are very similar to the previous function,
  // we're checking for overlap between different sets of the same kind of days
  // hence the `_simple` suffix
  //
  // there may or may not later be a separate check which checks whether:
  //  { weekdays } contains { 3rd, 4th, 5th }
  // but this requires additional context to know whether those days in the given bounds are always weekdays.
  // it's not a super common scenario, in fact I doubt it would ever come up, so we may never get to it,
  // but I'd like to at least make an issue for it so I can think it through a little more.
  //
  // I'm thinking however that I may have made a mistake and that I should probably change the type of days to only
  // so instead of this:
  //
  // type Days {
  //   Weekdays
  //   Weekends
  //   SpecificDays(List(DayOfWeek))
  //   OrdinalDays(List(Ordinal))
  // }
  //
  // we have this:
  //
  // type Days {
  //   SpecificDays(List(DayOfWeek))
  //   OrdinalDays(List(Ordinal))
  // }
  //
  // and we always treat `Weekdays` and `Weekends` as sugar

  todo
}
// type DayOfWeek = Mon | Tue | Wed | Thu | Fri | Sat | Sun

// type Ordinal {
//   DayOfMonth(Int)
//   Last
//   NthWeekday(Position, DayOfWeek)
// }

// type Position = First | Second | Third | Fourth | Fifth | LastPos

// type Timing {
//   At(times: List(Time))
//   TimeRange(from: Time, to: Time)
// }

// type Bounds {
//   Starting(BoundPoint)
//   Between(from: BoundPoint, to: BoundPoint)
// }

// type Exclusion {
//   ExceptDays(Days)
//   ExceptTime(Timing)
//   ExceptBounds(Bounds)
// }
