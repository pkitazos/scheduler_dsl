import gleam/option.{None, Some}
import gleeunit/should
import library/ast
import library/validator

// --- Helpers

fn recurring(frequency: ast.Frequency) -> ast.Schedule {
  ast.Recurring(
    frequency: frequency,
    timing: None,
    days: None,
    bounds: None,
    exclusions: None,
  )
}

fn with_timing(timing: ast.Timing) -> ast.Schedule {
  let assert ast.Recurring(..) as base = recurring(ast.Every(1, ast.Days))
  ast.Recurring(..base, timing: Some(timing))
}

fn with_bounds(bounds: ast.Bounds) -> ast.Schedule {
  let assert ast.Recurring(..) as base = recurring(ast.Every(1, ast.Days))
  ast.Recurring(..base, bounds: Some(bounds))
}

fn with_days(days: ast.Days) -> ast.Schedule {
  let assert ast.Recurring(..) as base = recurring(ast.Every(1, ast.Days))
  ast.Recurring(..base, days: Some(days))
}

fn with_exclusions(exclusions: List(ast.Exclusion)) -> ast.Schedule {
  let assert ast.Recurring(..) as base = recurring(ast.Every(1, ast.Days))
  ast.Recurring(..base, exclusions: Some(exclusions))
}

// --- One-Off

pub fn once_valid_test() {
  let s = ast.OneOff(ast.Date(2026, 1, 1), ast.Time(9, 0))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn once_date_invalid_test() {
  let date = ast.Date(2026, 2, 30)

  ast.OneOff(date, ast.Time(9, 0))
  |> validator.validate
  |> should.equal(Error(validator.InvalidDate("invalid date", date)))
}

pub fn once_time_invalid_test() {
  let time = ast.Time(9, 0)

  ast.OneOff(ast.Date(2026, 1, 1), time)
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", time)))
}

// --- Recurring

// --- Frequency

pub fn negative_frequency_is_invalid_test() {
  recurring(ast.Every(-1, ast.Minutes))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidFrequency(
      "frequency must be 1 or more",
      ast.Every(-1, ast.Minutes),
    )),
  )
}

pub fn every_0_seconds_is_invalid_test() {
  recurring(ast.Every(0, ast.Seconds))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidFrequency(
      "frequency must be 1 or more",
      ast.Every(0, ast.Seconds),
    )),
  )
}

pub fn every_0_minutes_is_invalid_test() {
  recurring(ast.Every(0, ast.Minutes))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidFrequency(
      "frequency must be 1 or more",
      ast.Every(0, ast.Minutes),
    )),
  )
}

pub fn every_1_second_is_valid_test() {
  let s = recurring(ast.Every(1, ast.Seconds))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn every_5_minutes_is_valid_test() {
  let s = recurring(ast.Every(5, ast.Minutes))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn every_hour_is_valid_test() {
  let s = recurring(ast.Every(1, ast.Hours))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn every_day_is_valid_test() {
  let s = recurring(ast.Every(1, ast.Days))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn every_week_is_valid_test() {
  let s = recurring(ast.Every(1, ast.Weeks))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn every_month_is_valid_test() {
  let s = recurring(ast.Every(1, ast.Months))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn every_year_is_valid_test() {
  let s = recurring(ast.Every(1, ast.Years))
  validator.validate(s) |> should.equal(Ok(s))
}

// --- Timing: TimeRange

pub fn valid_time_range_test() {
  let s = with_timing(ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn valid_wrapping_time_range_test() {
  let s = with_timing(ast.TimeRange(ast.Time(22, 0), ast.Time(6, 0)))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn equal_time_range_is_invalid_test() {
  with_timing(ast.TimeRange(ast.Time(9, 0), ast.Time(9, 0)))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidTimeRange(
      "invalid range",
      ast.TimeRange(ast.Time(9, 0), ast.Time(9, 0)),
    )),
  )
}

pub fn time_range_invalid_from_test() {
  with_timing(ast.TimeRange(ast.Time(25, 0), ast.Time(17, 0)))
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(25, 0))))
}

pub fn time_range_invalid_to_test() {
  with_timing(ast.TimeRange(ast.Time(9, 0), ast.Time(9, 60)))
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(9, 60))))
}

pub fn equal_invalid_time_range_returns_time_error_test() {
  with_timing(ast.TimeRange(ast.Time(25, 0), ast.Time(25, 0)))
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(25, 0))))
}

// --- Timing: At

pub fn at_empty_list_is_invalid_test() {
  with_timing(ast.At([]))
  |> validator.validate
  |> should.equal(Error(validator.InvalidTimeList("empty list", [])))
}

pub fn at_single_valid_time_test() {
  let s = with_timing(ast.At([ast.Time(9, 0)]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn at_multiple_valid_times_test() {
  let s =
    with_timing(ast.At([ast.Time(9, 0), ast.Time(12, 0), ast.Time(17, 0)]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn at_duplicate_times_is_invalid_test() {
  with_timing(ast.At([ast.Time(9, 0), ast.Time(9, 0)]))
  |> validator.validate
  |> should.equal(
    Error(
      validator.InvalidTimeList("invalid time list, contains duplicates", [
        ast.Time(9, 0),
      ]),
    ),
  )
}

pub fn at_non_adjacent_duplicate_times_is_invalid_test() {
  with_timing(ast.At([ast.Time(9, 0), ast.Time(12, 0), ast.Time(9, 0)]))
  |> validator.validate
  |> should.equal(
    Error(
      validator.InvalidTimeList("invalid time list, contains duplicates", [
        ast.Time(9, 0),
      ]),
    ),
  )
}

pub fn at_invalid_time_test() {
  with_timing(ast.At([ast.Time(25, 0)]))
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(25, 0))))
}

pub fn at_invalid_time_before_duplicate_check_test() {
  with_timing(ast.At([ast.Time(25, 0), ast.Time(25, 0)]))
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(25, 0))))
}

// --- Bounds: Starting

pub fn starting_valid_date_no_time_test() {
  let s =
    with_bounds(
      ast.Starting(ast.BoundPoint(ast.Date(2025, 3, 15), ast.midnight())),
    )
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn starting_valid_date_and_time_test() {
  let s =
    with_bounds(
      ast.Starting(ast.BoundPoint(ast.Date(2025, 3, 15), ast.Time(9, 0))),
    )
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn starting_invalid_date_test() {
  with_bounds(
    ast.Starting(ast.BoundPoint(ast.Date(2025, 13, 1), ast.midnight())),
  )
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 13, 1))),
  )
}

pub fn starting_valid_date_invalid_time_test() {
  with_bounds(
    ast.Starting(ast.BoundPoint(ast.Date(2025, 3, 15), ast.Time(25, 0))),
  )
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(25, 0))))
}

// --- Bounds: Starting (date edge cases)

pub fn starting_feb_29_leap_year_test() {
  let s =
    with_bounds(
      ast.Starting(ast.BoundPoint(ast.Date(2024, 2, 29), ast.midnight())),
    )
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn starting_feb_29_non_leap_year_test() {
  with_bounds(
    ast.Starting(ast.BoundPoint(ast.Date(2025, 2, 29), ast.midnight())),
  )
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 2, 29))),
  )
}

pub fn starting_day_31_on_30_day_month_test() {
  with_bounds(
    ast.Starting(ast.BoundPoint(ast.Date(2025, 4, 31), ast.midnight())),
  )
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 4, 31))),
  )
}

pub fn starting_month_0_test() {
  with_bounds(
    ast.Starting(ast.BoundPoint(ast.Date(2025, 0, 1), ast.midnight())),
  )
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 0, 1))),
  )
}

pub fn starting_day_0_test() {
  with_bounds(
    ast.Starting(ast.BoundPoint(ast.Date(2025, 1, 0), ast.midnight())),
  )
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 1, 0))),
  )
}

// --- Bounds: Between

pub fn between_valid_dates_no_times_test() {
  let s =
    with_bounds(ast.Between(
      ast.BoundPoint(ast.Date(2025, 1, 1), ast.midnight()),
      ast.BoundPoint(ast.Date(2025, 12, 31), ast.midnight()),
    ))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn between_valid_dates_and_times_test() {
  let s =
    with_bounds(ast.Between(
      ast.BoundPoint(ast.Date(2025, 1, 1), ast.Time(9, 0)),
      ast.BoundPoint(ast.Date(2025, 12, 31), ast.Time(17, 0)),
    ))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn between_invalid_start_date_test() {
  with_bounds(ast.Between(
    ast.BoundPoint(ast.Date(2025, 13, 1), ast.midnight()),
    ast.BoundPoint(ast.Date(2025, 12, 31), ast.midnight()),
  ))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 13, 1))),
  )
}

pub fn between_invalid_end_date_test() {
  with_bounds(ast.Between(
    ast.BoundPoint(ast.Date(2025, 1, 1), ast.midnight()),
    ast.BoundPoint(ast.Date(2025, 2, 30), ast.midnight()),
  ))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 2, 30))),
  )
}

pub fn between_invalid_bounds_test() {
  let s =
    ast.Between(
      ast.BoundPoint(ast.Date(2025, 12, 31), ast.midnight()),
      ast.BoundPoint(ast.Date(2025, 1, 1), ast.midnight()),
    )

  with_bounds(s)
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidBounds("end date must be after start date", s)),
  )
}

pub fn between_invalid_no_bounds_test() {
  let s =
    ast.Between(
      ast.BoundPoint(ast.Date(2025, 1, 1), ast.midnight()),
      ast.BoundPoint(ast.Date(2025, 1, 1), ast.midnight()),
    )

  with_bounds(s)
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidBounds("end date must be after start date", s)),
  )
}

pub fn between_invalid_start_time_test() {
  with_bounds(ast.Between(
    ast.BoundPoint(ast.Date(2025, 1, 1), ast.Time(25, 0)),
    ast.BoundPoint(ast.Date(2025, 12, 31), ast.Time(17, 0)),
  ))
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(25, 0))))
}

pub fn between_invalid_end_time_test() {
  with_bounds(ast.Between(
    ast.BoundPoint(ast.Date(2025, 1, 1), ast.Time(9, 0)),
    ast.BoundPoint(ast.Date(2025, 12, 31), ast.Time(9, 60)),
  ))
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(9, 60))))
}

pub fn between_invalid_bounds_asymmetry_some_none_test() {
  let s =
    ast.Between(
      ast.BoundPoint(ast.Date(2025, 1, 1), ast.Time(0, 0)),
      ast.BoundPoint(ast.Date(2025, 12, 31), ast.midnight()),
    )
  with_bounds(s)
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidBounds(
      "both bounds must have times or neither should",
      s,
    )),
  )
}

pub fn between_invalid_bounds_asymmetry_none_some_test() {
  let s =
    ast.Between(
      ast.BoundPoint(ast.Date(2025, 1, 1), ast.midnight()),
      ast.BoundPoint(ast.Date(2025, 12, 31), ast.Time(23, 59)),
    )
  with_bounds(s)
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidBounds(
      "both bounds must have times or neither should",
      s,
    )),
  )
}

// --- Days: Weekdays / Weekends

pub fn weekdays_is_valid_test() {
  let s = with_days(ast.SpecificDays(ast.weekdays()))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn weekends_is_valid_test() {
  let s = with_days(ast.SpecificDays(ast.weekend()))
  validator.validate(s) |> should.equal(Ok(s))
}

// --- Days: SpecificDays

pub fn specific_days_empty_list_is_invalid_test() {
  with_days(ast.SpecificDays([]))
  |> validator.validate
  |> should.equal(Error(validator.InvalidDaysOfWeek("empty list", [])))
}

pub fn specific_days_single_day_test() {
  let s = with_days(ast.SpecificDays([ast.Mon]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn specific_days_multiple_days_test() {
  let s = with_days(ast.SpecificDays([ast.Mon, ast.Wed, ast.Fri]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn specific_days_duplicate_is_invalid_test() {
  with_days(ast.SpecificDays([ast.Mon, ast.Tue, ast.Mon]))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDaysOfWeek("duplicate days of week", [ast.Mon])),
  )
}

// --- Days: OrdinalDays

pub fn ordinal_days_empty_list_is_invalid_test() {
  with_days(ast.BareOrdinalDays([]))
  |> validator.validate
  |> should.equal(Error(validator.InvalidOrdinalDays("empty list", [])))
}

pub fn ordinal_days_single_day_of_month_test() {
  let s = with_days(ast.BareOrdinalDays([ast.DayOfMonth(15)]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn ordinal_days_multiple_days_of_month_test() {
  let s =
    with_days(ast.BareOrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15)]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn ordinal_days_last_test() {
  let s = with_days(ast.BareOrdinalDays([ast.LastDay]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn ordinal_days_day_of_month_and_last_mixed_test() {
  let s = with_days(ast.BareOrdinalDays([ast.DayOfMonth(1), ast.LastDay]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn ordinal_days_last_and_day_of_month_mixed_test() {
  let s = with_days(ast.BareOrdinalDays([ast.LastDay, ast.DayOfMonth(15)]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn ordinal_days_nth_weekday_test() {
  let s =
    with_days(ast.QualifiedOrdinalDays([ast.NthWeekday(ast.First, ast.Mon)]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn ordinal_days_multiple_nth_weekdays_test() {
  let s =
    with_days(
      ast.QualifiedOrdinalDays([
        ast.NthWeekday(ast.First, ast.Mon),
        ast.NthWeekday(ast.Third, ast.Fri),
      ]),
    )
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn ordinal_days_duplicate_is_invalid_test() {
  with_days(ast.BareOrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(1)]))
  |> validator.validate
  |> should.equal(
    Error(
      validator.InvalidOrdinalDays("duplicate ordinal days", [
        ast.DayOfMonth(1),
      ]),
    ),
  )
}

pub fn ordinal_days_duplicate_nth_weekday_is_invalid_test() {
  with_days(
    ast.QualifiedOrdinalDays([
      ast.NthWeekday(ast.First, ast.Mon),
      ast.NthWeekday(ast.First, ast.Mon),
    ]),
  )
  |> validator.validate
  |> should.equal(
    Error(
      validator.InvalidQualifiedOrdinalDays("duplicate ordinal days", [
        ast.NthWeekday(ast.First, ast.Mon),
      ]),
    ),
  )
}

pub fn ordinal_days_duplicate_last_is_invalid_test() {
  with_days(ast.BareOrdinalDays([ast.LastDay, ast.LastDay]))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidOrdinalDays("duplicate ordinal days", [ast.LastDay])),
  )
}

pub fn ordinal_day_of_month_0_is_invalid_test() {
  with_days(ast.BareOrdinalDays([ast.DayOfMonth(0)]))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDayOfMonth("invalid day of month", ast.DayOfMonth(0))),
  )
}

pub fn ordinal_day_of_month_32_is_invalid_test() {
  with_days(ast.BareOrdinalDays([ast.DayOfMonth(32)]))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDayOfMonth(
      "invalid day of month",
      ast.DayOfMonth(32),
    )),
  )
}

pub fn ordinal_day_of_month_1_is_valid_test() {
  let s = with_days(ast.BareOrdinalDays([ast.DayOfMonth(1)]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn ordinal_day_of_month_31_is_valid_test() {
  let s = with_days(ast.BareOrdinalDays([ast.DayOfMonth(31)]))
  validator.validate(s) |> should.equal(Ok(s))
}

// --- Exclusions: ExceptTime

pub fn except_time_valid_range_test() {
  let s =
    with_exclusions([
      ast.ExceptTime(ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0))),
    ])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn except_time_valid_at_test() {
  let s = with_exclusions([ast.ExceptTime(ast.At([ast.Time(9, 0)]))])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn except_time_valid_at_multiple_test() {
  let s =
    with_exclusions([
      ast.ExceptTime(ast.At([ast.Time(9, 0), ast.Time(12, 0), ast.Time(17, 0)])),
    ])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn except_time_zero_width_range_is_invalid_test() {
  with_exclusions([
    ast.ExceptTime(ast.TimeRange(ast.Time(9, 0), ast.Time(9, 0))),
  ])
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidTimeRange(
      "invalid range",
      ast.TimeRange(ast.Time(9, 0), ast.Time(9, 0)),
    )),
  )
}

pub fn except_time_empty_at_is_invalid_test() {
  with_exclusions([ast.ExceptTime(ast.At([]))])
  |> validator.validate
  |> should.equal(Error(validator.InvalidTimeList("empty list", [])))
}

pub fn except_time_duplicate_at_is_invalid_test() {
  with_exclusions([ast.ExceptTime(ast.At([ast.Time(9, 0), ast.Time(9, 0)]))])
  |> validator.validate
  |> should.equal(
    Error(
      validator.InvalidTimeList("invalid time list, contains duplicates", [
        ast.Time(9, 0),
      ]),
    ),
  )
}

pub fn except_time_invalid_time_in_range_test() {
  with_exclusions([
    ast.ExceptTime(ast.TimeRange(ast.Time(25, 0), ast.Time(17, 0))),
  ])
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(25, 0))))
}

pub fn except_time_invalid_time_in_at_test() {
  with_exclusions([ast.ExceptTime(ast.At([ast.Time(25, 0)]))])
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(25, 0))))
}

// --- Exclusions: ExceptDays

pub fn except_days_weekdays_test() {
  let s = with_exclusions([ast.ExceptDays(ast.SpecificDays(ast.weekdays()))])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn except_days_weekends_test() {
  let s = with_exclusions([ast.ExceptDays(ast.SpecificDays(ast.weekend()))])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn except_days_specific_days_test() {
  let s =
    with_exclusions([ast.ExceptDays(ast.SpecificDays([ast.Mon, ast.Wed]))])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn except_days_empty_specific_days_is_invalid_test() {
  with_exclusions([ast.ExceptDays(ast.SpecificDays([]))])
  |> validator.validate
  |> should.equal(Error(validator.InvalidDaysOfWeek("empty list", [])))
}

pub fn except_days_duplicate_specific_days_is_invalid_test() {
  with_exclusions([ast.ExceptDays(ast.SpecificDays([ast.Mon, ast.Mon]))])
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDaysOfWeek("duplicate days of week", [ast.Mon])),
  )
}

pub fn except_days_ordinal_valid_test() {
  let s =
    with_exclusions([ast.ExceptDays(ast.BareOrdinalDays([ast.DayOfMonth(1)]))])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn except_days_ordinal_empty_is_invalid_test() {
  with_exclusions([ast.ExceptDays(ast.BareOrdinalDays([]))])
  |> validator.validate
  |> should.equal(Error(validator.InvalidOrdinalDays("empty list", [])))
}

pub fn except_days_ordinal_out_of_range_is_invalid_test() {
  with_exclusions([ast.ExceptDays(ast.BareOrdinalDays([ast.DayOfMonth(32)]))])
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDayOfMonth(
      "invalid day of month",
      ast.DayOfMonth(32),
    )),
  )
}

pub fn except_days_ordinal_duplicate_is_invalid_test() {
  with_exclusions([
    ast.ExceptDays(ast.BareOrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(1)])),
  ])
  |> validator.validate
  |> should.equal(
    Error(
      validator.InvalidOrdinalDays("duplicate ordinal days", [
        ast.DayOfMonth(1),
      ]),
    ),
  )
}

// --- Exclusions: ExceptBounds

pub fn except_bounds_valid_starting_test() {
  let s =
    with_exclusions([
      ast.ExceptBounds(
        ast.Starting(ast.BoundPoint(ast.Date(2025, 1, 1), ast.midnight())),
      ),
    ])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn except_bounds_valid_between_test() {
  let s =
    with_exclusions([
      ast.ExceptBounds(ast.Between(
        ast.BoundPoint(ast.Date(2025, 1, 1), ast.midnight()),
        ast.BoundPoint(ast.Date(2025, 12, 31), ast.midnight()),
      )),
    ])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn except_bounds_invalid_date_test() {
  with_exclusions([
    ast.ExceptBounds(
      ast.Starting(ast.BoundPoint(ast.Date(2025, 13, 1), ast.midnight())),
    ),
  ])
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 13, 1))),
  )
}

pub fn except_bounds_end_before_start_is_invalid_test() {
  let bounds =
    ast.Between(
      ast.BoundPoint(ast.Date(2025, 12, 31), ast.midnight()),
      ast.BoundPoint(ast.Date(2025, 1, 1), ast.midnight()),
    )
  with_exclusions([ast.ExceptBounds(bounds)])
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidBounds("end date must be after start date", bounds)),
  )
}

pub fn except_bounds_time_asymmetry_is_invalid_test() {
  let bounds =
    ast.Between(
      ast.BoundPoint(ast.Date(2025, 1, 1), ast.Time(9, 0)),
      ast.BoundPoint(ast.Date(2025, 12, 31), ast.midnight()),
    )
  with_exclusions([ast.ExceptBounds(bounds)])
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidBounds(
      "both bounds must have times or neither should",
      bounds,
    )),
  )
}

// --- Exclusions: Empty list

pub fn empty_exclusions_list_is_invalid_test() {
  with_exclusions([])
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidExclusions("empty exclusions list", [])),
  )
}

// --- Exclusions: Duplicates

pub fn duplicate_except_days_is_invalid_test() {
  let exclusions = [
    ast.ExceptDays(ast.SpecificDays(ast.weekdays())),
    ast.ExceptDays(ast.SpecificDays(ast.weekdays())),
  ]
  with_exclusions(exclusions)
  |> validator.validate
  |> should.equal(
    Error(
      validator.InvalidExclusions("duplicate exclusions", [
        ast.ExceptDays(ast.SpecificDays(ast.weekdays())),
      ]),
    ),
  )
}

pub fn duplicate_except_time_is_invalid_test() {
  let exclusions = [
    ast.ExceptTime(ast.At([ast.Time(9, 0)])),
    ast.ExceptTime(ast.At([ast.Time(9, 0)])),
  ]
  with_exclusions(exclusions)
  |> validator.validate
  |> should.equal(
    Error(
      validator.InvalidExclusions("duplicate exclusions", [
        ast.ExceptTime(ast.At([ast.Time(9, 0)])),
      ]),
    ),
  )
}

pub fn duplicate_except_bounds_is_invalid_test() {
  let bound = ast.Starting(ast.BoundPoint(ast.Date(2025, 1, 1), ast.midnight()))
  let exclusions = [ast.ExceptBounds(bound), ast.ExceptBounds(bound)]
  with_exclusions(exclusions)
  |> validator.validate
  |> should.equal(
    Error(
      validator.InvalidExclusions("duplicate exclusions", [
        ast.ExceptBounds(bound),
      ]),
    ),
  )
}

pub fn different_exclusions_is_valid_test() {
  let s =
    with_exclusions([
      ast.ExceptDays(ast.SpecificDays(ast.weekdays())),
      ast.ExceptDays(ast.SpecificDays(ast.weekend())),
    ])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn different_exclusion_types_is_valid_test() {
  let s =
    with_exclusions([
      ast.ExceptDays(ast.SpecificDays(ast.weekdays())),
      ast.ExceptTime(ast.At([ast.Time(9, 0)])),
    ])
  validator.validate(s) |> should.equal(Ok(s))
}

// --- Exclusions: Redundant (strict structural subset)

pub fn redundant_specific_days_subset_is_invalid_test() {
  let exclusions = [
    ast.ExceptDays(ast.SpecificDays([ast.Mon])),
    ast.ExceptDays(ast.SpecificDays([ast.Mon, ast.Tue])),
  ]
  with_exclusions(exclusions)
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidExclusions("redundant exclusions", exclusions)),
  )
}

pub fn redundant_at_times_subset_is_invalid_test() {
  let exclusions = [
    ast.ExceptTime(ast.At([ast.Time(9, 0)])),
    ast.ExceptTime(ast.At([ast.Time(9, 0), ast.Time(12, 0)])),
  ]
  with_exclusions(exclusions)
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidExclusions("redundant exclusions", exclusions)),
  )
}

pub fn redundant_ordinal_days_subset_is_invalid_test() {
  let exclusions = [
    ast.ExceptDays(ast.BareOrdinalDays([ast.DayOfMonth(1)])),
    ast.ExceptDays(ast.BareOrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15)])),
  ]
  with_exclusions(exclusions)
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidExclusions("redundant exclusions", exclusions)),
  )
}

pub fn redundant_nth_weekday_subset_is_invalid_test() {
  let exclusions = [
    ast.ExceptDays(
      ast.QualifiedOrdinalDays([ast.NthWeekday(ast.First, ast.Mon)]),
    ),
    ast.ExceptDays(
      ast.QualifiedOrdinalDays([
        ast.NthWeekday(ast.First, ast.Mon),
        ast.NthWeekday(ast.Third, ast.Fri),
      ]),
    ),
  ]
  with_exclusions(exclusions)
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidExclusions("redundant exclusions", exclusions)),
  )
}

pub fn non_overlapping_specific_days_is_valid_test() {
  let s =
    with_exclusions([
      ast.ExceptDays(ast.SpecificDays([ast.Mon])),
      ast.ExceptDays(ast.SpecificDays([ast.Tue])),
    ])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn partial_overlap_not_subset_is_valid_test() {
  let s =
    with_exclusions([
      ast.ExceptDays(ast.SpecificDays([ast.Mon, ast.Wed])),
      ast.ExceptDays(ast.SpecificDays([ast.Mon, ast.Fri])),
    ])
  validator.validate(s) |> should.equal(Ok(s))
}

// --- Exclusions: Multiple valid

pub fn multiple_distinct_exclusions_test() {
  let s =
    with_exclusions([
      ast.ExceptDays(ast.SpecificDays(ast.weekend())),
      ast.ExceptTime(ast.TimeRange(ast.Time(22, 0), ast.Time(6, 0))),
    ])
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn three_distinct_exclusions_test() {
  let s =
    with_exclusions([
      ast.ExceptDays(ast.SpecificDays(ast.weekend())),
      ast.ExceptTime(ast.At([ast.Time(12, 0)])),
      ast.ExceptBounds(
        ast.Starting(ast.BoundPoint(ast.Date(2025, 6, 1), ast.midnight())),
      ),
    ])
  validator.validate(s) |> should.equal(Ok(s))
}
