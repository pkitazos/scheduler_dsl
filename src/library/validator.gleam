import gleam/int
import gleam/io
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

      // we have three kinds of exclusions which each need to be handled slightly differently
      // so we'll separate our their innards into three separate lists
      // the `list.group` function seemed really cool for this, but then maps in gleam are pretty under-powered
      // so idk what to do from here

      let _map =
        list.group(xs, fn(x) {
          case x {
            ast.ExceptDays(_) -> "days"
            ast.ExceptTime(_) -> "time"
            ast.ExceptBounds(_) -> "bounds"
          }
        })

      // haven't figured out the best way to do this yet, so for now we'll go the long way around
      // and filter each one with an assert.
      // this is obviously not the right way to do it, but unfortunately we can't pattern match on dictionaries

      xs
      |> list.filter_map(fn(x) {
        case x {
          ast.ExceptDays(ys) -> Ok(ys)
          _ -> Error(Nil)
        }
      })
      |> handle_days

      // for now we just discard the times and bounds cause we're only working on the days validation

      let _times =
        list.filter_map(xs, fn(x) {
          case x {
            ast.ExceptTime(ys) -> Ok(ys)
            _ -> Error(Nil)
          }
        })

      let _bounds =
        list.filter_map(xs, fn(x) {
          case x {
            ast.ExceptBounds(ys) -> Ok(ys)
            _ -> Error(Nil)
          }
        })

      Ok(exclusions)
    }
  }
}

// todo: name and signature are temporary
fn handle_days(days: List(ast.Days)) -> Nil {
  let pairs =
    days
    // get all pair combinations
    |> list.combination_pairs()
    // sort em (maybe pointless, still haven't really figured out what data structure works best here)
    // right now we're using sorted tuples and then passing them to the `contained_in` function
    // which tells us the "level of containment" of the second argument in reference to the first
    |> list.map(fn(x) {
      let #(a, b) = x
      contained_in(a, b)
    })
    |> list.filter_map(fn(x) {
      case x {
        days.Subset(_, _) | days.Intersection(_, _, _) -> Ok(x)
        _ -> Error(Nil)
      }
    })

  // io.println("before:\n" <> string.inspect(days))
  // io.println("sorted:\n" <> string.inspect(list.sort(days, days.sort_days)))

  io.println("\n\n" <> string.inspect(pairs))

  // this is our test input:
  //    "except Sunday, Monday and Tuesday ; except Weekends ; except Weekdays ; except Saturday"

  // this is what the test input produces so far
  let _ = [
    #(
      ast.Weekends,
      ast.SpecificDays([ast.Sun, ast.Mon, ast.Tue]),
      days.Intersection(days.weekend(), [ast.Sun, ast.Mon, ast.Tue], [ast.Sun]),
    ),
    #(
      ast.Weekdays,
      ast.SpecificDays([ast.Sun, ast.Mon, ast.Tue]),
      days.Intersection(days.weekdays(), [ast.Sun, ast.Mon, ast.Tue], [
        ast.Mon,
        ast.Tue,
      ]),
    ),
    #(
      ast.Weekends,
      ast.SpecificDays([ast.Sat]),
      days.Subset(days.weekend(), [ast.Sat]),
    ),
  ]

  // maybe that's enough to produce the errors / warning we want
  // we'd be able to say something like:
  //    "`ast.SpecificDays([ast.Sun, ast.Mon, ast.Tue])` is contained in `ast.Weekdays` and so can be omitted"
  // or
  //    "`ast.SpecificDays([ast.Sat])` is a strict subset of `ast.Weekdends` and so can be omitted"

  // Now, it would be _really_ cool if we could look at the test input and just deduce the smallest possible combination that covers everything.
  // in this case we can just reduce this:
  //
  //    - Sunday, Monday and Tuesday
  //    - Weekends
  //    - Weekdays
  //    - Saturday
  //
  // to this:
  //
  //    - Weekends
  //    - Weekdays
  //
  // which is sorta the same as `ast.Every(1, ast.Days)` but that's a whole other can of worms

  Nil
}

pub fn contained_in(d1: ast.Days, d2: ast.Days) -> days.Overlap(ast.DayOfWeek) {
  // ! assumes that lists have all been deduped
  case d1, d2 {
    ast.OrdinalDays(_), _ -> days.Indeterminate
    _, ast.OrdinalDays(_) -> days.Indeterminate

    ast.Weekdays, ast.Weekends -> days.Disjoint
    ast.Weekends, ast.Weekdays -> days.Disjoint

    // should not be reachable from previous check
    // ! this approach of passing these lists means I'm losing info so my error messages won't be so nice
    ast.Weekdays, ast.Weekdays -> days.Subset(days.weekdays(), days.weekdays())
    ast.Weekends, ast.Weekends -> days.Subset(days.weekend(), days.weekend())

    ast.Weekdays, ast.SpecificDays(days) -> {
      // any days of the week contained within days should be flagged
      days.overlap_with(days, days.weekdays())
    }

    ast.Weekends, ast.SpecificDays(days) -> {
      // if Sat or Sun are in days should be flagged
      days.overlap_with(days, days.weekend())
    }

    ast.SpecificDays(d1), ast.SpecificDays(d2) -> {
      // check if the two lists overlap
      // emit warning that these could be merged into one clause
      days.overlap_with(d1, d2)
    }
    ast.SpecificDays(days), ast.Weekdays -> {
      // any days of the week contained within days should be flagged
      days.overlap_with(days, days.weekdays())
    }
    ast.SpecificDays(days), ast.Weekends -> {
      // if Sat AND Sun are in days should be flagged
      // ? maybe not though
      days.overlap_with(days, days.weekend())
    }
  }
}
// type Days {
//   Weekdays
//   Weekends
//   SpecificDays(List(DayOfWeek))
//   OrdinalDays(List(Ordinal))
// }

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
