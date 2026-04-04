import gleam/function.{identity as id}
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import library/ast
import library/ast/bounds
import library/ast/days
import library/ast/timing
import library/overlap
import library/utils.{guard, no_duplicates, option_try}

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
  InvalidQualifiedOrdinalDays(String, List(ast.NthWeekday))
  InvalidExclusions(String, List(ast.Exclusion))
  InvalidExclusionsDays(String, #(ast.Days, ast.Days))
  InvalidExclusionsDaysMixing(String)
  InvalidExclusionsTime(String, #(ast.Timing, ast.Timing))
  InvalidExclusionsBounds(String)
  InExclusion(ast.Exclusion, ValidatorError)
}

pub fn validate(schedule: ast.Schedule) -> Result(ast.Schedule, ValidatorError) {
  case schedule {
    ast.OneOff(date, time) -> {
      use _date <- result.try(guard(
        date,
        ast.check_date,
        InvalidDate("invalid date", date),
      ))
      use _time <- result.try(validate_time(time))

      Ok(schedule)
    }
    ast.Recurring(frequency, timing, days, bounds, exclusions) -> {
      use _ <- result.try(validate_frequency(frequency))
      use _ <- result.try(option_try(timing, validate_timing))
      use _ <- result.try(option_try(days, validate_days))
      use _ <- result.try(option_try(bounds, validate_bounds))
      use _ <- result.try(option_try(exclusions, validate_exclusions))

      Ok(schedule)
    }
  }
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
      use _from <- result.try(validate_time(from))
      Error(InvalidTimeRange("invalid range", timing))
    }

    ast.TimeRange(from, to) -> {
      use _from <- result.try(validate_time(from))
      use _to <- result.try(validate_time(to))
      Ok(timing)
    }

    ast.At([]) -> Error(InvalidTimeList("empty list", []))
    ast.At(times) -> {
      use _times <- result.try(list.try_map(times, validate_time))

      use _times <- result.try(
        no_duplicates(times, id, fn(dups) {
          InvalidTimeList("invalid time list, contains duplicates", dups)
        }),
      )

      Ok(timing)
    }
  }
}

pub fn validate_days(days: ast.Days) -> Result(ast.Days, ValidatorError) {
  case days {
    ast.SpecificDays([]) -> Error(InvalidDaysOfWeek("empty list", []))

    ast.SpecificDays(days_of_week) -> {
      use _days_of_week <- result.try(
        no_duplicates(days_of_week, id, fn(dups) {
          InvalidDaysOfWeek("duplicate days of week", dups)
        }),
      )

      Ok(days)
    }

    ast.BareOrdinalDays([]) -> Error(InvalidOrdinalDays("empty list", []))

    ast.BareOrdinalDays(ordinals) -> {
      use _ordinals <- result.try(
        no_duplicates(ordinals, id, fn(dups) {
          InvalidOrdinalDays("duplicate ordinal days", dups)
        }),
      )

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

    ast.QualifiedOrdinalDays([]) ->
      Error(InvalidQualifiedOrdinalDays("empty list", []))

    ast.QualifiedOrdinalDays(qualified_weekdays) -> {
      use _days_of_week <- result.try(
        no_duplicates(qualified_weekdays, id, fn(dups) {
          InvalidQualifiedOrdinalDays("duplicate qualified weekdays", dups)
        }),
      )

      Ok(days)
    }
  }
}

fn validate_bounds(bounds: ast.Bounds) -> Result(ast.Bounds, ValidatorError) {
  case bounds {
    ast.Starting(ast.BoundPoint(date, time)) -> {
      use _date <- result.try(guard(
        date,
        ast.check_date,
        InvalidDate("invalid date", date),
      ))

      use _time <- result.try(validate_time(time))
      Ok(bounds)
    }

    ast.Between(
      ast.BoundPoint(start_date, start_time),
      ast.BoundPoint(end_date, end_time),
    ) -> {
      use start_date <- result.try(guard(
        start_date,
        ast.check_date,
        InvalidDate("invalid date", start_date),
      ))

      use start_time <- result.try(validate_time(start_time))

      use end_date <- result.try(guard(
        end_date,
        ast.check_date,
        InvalidDate("invalid date", end_date),
      ))

      use end_time <- result.try(validate_time(end_time))

      // use _ <- result.try(options_symmetric(
      //   start_time,
      //   end_time,
      //   InvalidBounds("both bounds must have times or neither should", bounds),
      // ))

      let start = ast.BoundPoint(start_date, start_time)
      let end = ast.BoundPoint(end_date, end_time)

      case ast.compare_bound_point(start, end) {
        order.Lt -> Ok(bounds)
        _ -> Error(InvalidBounds("end date must be after start date", bounds))
      }
    }
  }
}

fn validate_time(time: ast.Time) -> Result(ast.Time, ValidatorError) {
  case ast.check_time(time) {
    True -> Ok(time)
    False -> Error(InvalidTime("invalid time", time))
  }
}

pub fn validate_exclusions(
  exclusions: List(ast.Exclusion),
) -> Result(List(ast.Exclusion), ValidatorError) {
  case exclusions {
    [] -> Error(InvalidExclusions("empty exclusions list", []))
    xs -> {
      use _ <- result.try(
        no_duplicates(xs, ast.normalise_exclusion, fn(dups) {
          InvalidExclusions("duplicate exclusions", dups)
        }),
      )

      let exclusions_days_list =
        list.filter_map(xs, fn(x) {
          case x {
            ast.ExceptDays(ys) -> Ok(ys)
            _ -> Error(Nil)
          }
        })

      let exclusions_timing =
        list.filter_map(xs, fn(x) {
          case x {
            ast.ExceptTime(ys) -> Ok(ys)
            _ -> Error(Nil)
          }
        })

      let exclusions_bounds =
        list.filter_map(xs, fn(x) {
          case x {
            ast.ExceptBounds(ys) -> Ok(ys)
            _ -> Error(Nil)
          }
        })

      use _ <- result.try(handle_day_list_simple_overlap(exclusions_days_list))

      use _ <- result.try({
        use days <- list.try_each(exclusions_days_list)
        use err <- result.map_error(validate_days(days))
        InExclusion(ast.ExceptDays(days), err)
      })

      // todo: timing overlap

      // so let's say a schedule uses a time list like:
      //
      //  At(00:00, 06:00, 07:30)
      //
      // and an exclusion says something like:
      //
      //  (a) Except(10:00)
      //  (b) Except(from: 7:00, to: 08:00)
      //
      // - The first clause is pointless (and should be flagged in the cross-clause validation)
      // - The second clause actually does something.
      //
      // In my earlier notes I said that I should not allow mixing the two, but actually why not?
      // I mean it's a bit silly to allow this in the proper schedule, but in the negation where we
      // are just poking wholes, totally fine.
      // All our validation should do is check two things:
      // 1) does the exclusion not target anything? (a)
      // 2) does the exclusion cancel the entire schedule? e.g `Except(from: 00:00, to: 07:30)`
      // 3) does one exclusion (time range) completely contain another? (subset)
      // 4) does one exclusion (time range) partially overlap with another? (intersection)
      use _ <- result.try(handle_time_range_simple_overlap(exclusions_timing))

      use _ <- result.try({
        use timing <- list.try_each(exclusions_timing)
        use err <- result.map_error(validate_timing(timing))
        InExclusion(ast.ExceptTime(timing), err)
      })

      use _ <- result.try(handle_bounds_simple_overlap(exclusions_bounds))

      use _ <- result.try({
        use bounds <- list.try_each(exclusions_bounds)
        use err <- result.map_error(validate_bounds(bounds))
        InExclusion(ast.ExceptBounds(bounds), err)
      })

      Ok(exclusions)
    }
  }
}

fn handle_day_list_simple_overlap(
  days: List(ast.Days),
) -> Result(List(ast.Days), ValidatorError) {
  use _ <- result.try(
    days
    |> list.combination_pairs
    |> list.try_each(fn(p) {
      case days.overlap_with(p.0, p.1) {
        Ok(overlap.Subset(a, b)) -> {
          Error(InvalidExclusionsDays("redundant exclusions", #(a, b)))
        }
        Ok(overlap.Intersection(_, _, _)) -> {
          // todo: make this a warning later on
          Ok(Nil)
        }
        Ok(overlap.Disjoint) -> {
          // genuinely no overlap, this one is fine to pass through
          Ok(Nil)
        }
        Ok(overlap.Adjacent(_, _, _)) -> {
          // not possible with day lists
          Ok(Nil)
        }
        Error(_) -> {
          // ordinal-vs-non-ordinal overlap may be handled in a separate pass
          // since it requires bounds context to resolve
          // or it may just not be allowed
          Error(InvalidExclusionsDaysMixing(
            "cannot mix Ordinal and Week days in the same schedule",
          ))
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

fn handle_time_range_simple_overlap(
  timings: List(ast.Timing),
) -> Result(List(ast.Timing), ValidatorError) {
  use _ <- result.try(
    timings
    |> list.combination_pairs
    |> list.try_each(fn(p) {
      case timing.overlap_with(p.0, p.1) {
        overlap.Subset(a, b) -> {
          Error(InvalidExclusionsTime("redundant exclusions", #(a, b)))
        }
        overlap.Intersection(_, _, _) -> {
          // todo: make this a warning later on
          Ok(Nil)
        }
        overlap.Adjacent(_, _, _) -> {
          // todo: make this a warning later on
          Ok(Nil)
        }
        overlap.Disjoint -> Ok(Nil)
      }
    }),
  )

  Ok(timings)
}

fn handle_bounds_simple_overlap(
  bounds_list: List(ast.Bounds),
) -> Result(List(ast.Bounds), ValidatorError) {
  use _ <- result.try(
    bounds_list
    |> list.combination_pairs
    |> list.try_each(fn(p) {
      case bounds.overlap_with(p.0, p.1) {
        overlap.Subset(a, b) -> {
          Error(InvalidExclusionsBounds(
            string.inspect(a) <> " is contained within " <> string.inspect(b),
          ))
        }
        overlap.Intersection(_, _, _) -> {
          // todo: make this a warning later on
          Ok(Nil)
        }
        overlap.Adjacent(_, _, _) -> {
          // todo: make this a warning later on
          Ok(Nil)
        }
        overlap.Disjoint -> Ok(Nil)
      }
    }),
  )

  Ok(bounds_list)
}
