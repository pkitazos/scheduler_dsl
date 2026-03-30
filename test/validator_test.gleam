import gleam/option.{None, Some}
import gleeunit/should
import library/ast
import library/validator

// --- Helpers

fn schedule(frequency: ast.Frequency) -> ast.Schedule {
  ast.Schedule(
    frequency: frequency,
    timing: None,
    days: None,
    bounds: None,
    exclusions: None,
  )
}

fn with_timing(timing: ast.Timing) -> ast.Schedule {
  ast.Schedule(..schedule(ast.Once), timing: Some(timing))
}

fn with_bounds(bounds: ast.Bounds) -> ast.Schedule {
  ast.Schedule(..schedule(ast.Once), bounds: Some(bounds))
}

fn with_days(days: ast.Days) -> ast.Schedule {
  ast.Schedule(..schedule(ast.Once), days: Some(days))
}

// --- Frequency

pub fn negative_frequency_is_invalid_test() {
  schedule(ast.Every(-1, ast.Minutes))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidFrequency(
      "frequency must be 1 or more",
      ast.Every(-1, ast.Minutes),
    )),
  )
}

pub fn every_0_seconds_is_invalid_test() {
  schedule(ast.Every(0, ast.Seconds))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidFrequency(
      "frequency must be 1 or more",
      ast.Every(0, ast.Seconds),
    )),
  )
}

pub fn every_0_minutes_is_invalid_test() {
  schedule(ast.Every(0, ast.Minutes))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidFrequency(
      "frequency must be 1 or more",
      ast.Every(0, ast.Minutes),
    )),
  )
}

pub fn every_1_second_is_valid_test() {
  let s = schedule(ast.Every(1, ast.Seconds))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn every_5_minutes_is_valid_test() {
  let s = schedule(ast.Every(5, ast.Minutes))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn once_is_valid_test() {
  let s = schedule(ast.Once)
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn hourly_is_valid_test() {
  let s = schedule(ast.Hourly)
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn daily_is_valid_test() {
  let s = schedule(ast.Daily)
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn weekly_is_valid_test() {
  let s = schedule(ast.Weekly)
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn monthly_is_valid_test() {
  let s = schedule(ast.Monthly)
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn annually_is_valid_test() {
  let s = schedule(ast.Annually)
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
  let s = with_bounds(ast.Starting(ast.BoundPoint(ast.Date(2025, 3, 15), None)))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn starting_valid_date_and_time_test() {
  let s =
    with_bounds(
      ast.Starting(ast.BoundPoint(ast.Date(2025, 3, 15), Some(ast.Time(9, 0)))),
    )
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn starting_invalid_date_test() {
  with_bounds(ast.Starting(ast.BoundPoint(ast.Date(2025, 13, 1), None)))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 13, 1))),
  )
}

pub fn starting_valid_date_invalid_time_test() {
  with_bounds(
    ast.Starting(ast.BoundPoint(ast.Date(2025, 3, 15), Some(ast.Time(25, 0)))),
  )
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(25, 0))))
}

// --- Bounds: Starting (date edge cases)

pub fn starting_feb_29_leap_year_test() {
  let s = with_bounds(ast.Starting(ast.BoundPoint(ast.Date(2024, 2, 29), None)))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn starting_feb_29_non_leap_year_test() {
  with_bounds(ast.Starting(ast.BoundPoint(ast.Date(2025, 2, 29), None)))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 2, 29))),
  )
}

pub fn starting_day_31_on_30_day_month_test() {
  with_bounds(ast.Starting(ast.BoundPoint(ast.Date(2025, 4, 31), None)))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 4, 31))),
  )
}

pub fn starting_month_0_test() {
  with_bounds(ast.Starting(ast.BoundPoint(ast.Date(2025, 0, 1), None)))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 0, 1))),
  )
}

pub fn starting_day_0_test() {
  with_bounds(ast.Starting(ast.BoundPoint(ast.Date(2025, 1, 0), None)))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 1, 0))),
  )
}

// --- Bounds: Between

pub fn between_valid_dates_no_times_test() {
  let s =
    with_bounds(ast.Between(
      ast.BoundPoint(ast.Date(2025, 1, 1), None),
      ast.BoundPoint(ast.Date(2025, 12, 31), None),
    ))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn between_valid_dates_and_times_test() {
  let s =
    with_bounds(ast.Between(
      ast.BoundPoint(ast.Date(2025, 1, 1), Some(ast.Time(9, 0))),
      ast.BoundPoint(ast.Date(2025, 12, 31), Some(ast.Time(17, 0))),
    ))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn between_invalid_start_date_test() {
  with_bounds(ast.Between(
    ast.BoundPoint(ast.Date(2025, 13, 1), None),
    ast.BoundPoint(ast.Date(2025, 12, 31), None),
  ))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 13, 1))),
  )
}

pub fn between_invalid_end_date_test() {
  with_bounds(ast.Between(
    ast.BoundPoint(ast.Date(2025, 1, 1), None),
    ast.BoundPoint(ast.Date(2025, 2, 30), None),
  ))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidDate("invalid date", ast.Date(2025, 2, 30))),
  )
}

pub fn between_invalid_bounds_test() {
  let s =
    ast.Between(
      ast.BoundPoint(ast.Date(2025, 12, 31), None),
      ast.BoundPoint(ast.Date(2025, 1, 1), None),
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
      ast.BoundPoint(ast.Date(2025, 1, 1), None),
      ast.BoundPoint(ast.Date(2025, 1, 1), None),
    )

  with_bounds(s)
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidBounds("end date must be after start date", s)),
  )
}

pub fn between_invalid_start_time_test() {
  with_bounds(ast.Between(
    ast.BoundPoint(ast.Date(2025, 1, 1), Some(ast.Time(25, 0))),
    ast.BoundPoint(ast.Date(2025, 12, 31), Some(ast.Time(17, 0))),
  ))
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(25, 0))))
}

pub fn between_invalid_end_time_test() {
  with_bounds(ast.Between(
    ast.BoundPoint(ast.Date(2025, 1, 1), Some(ast.Time(9, 0))),
    ast.BoundPoint(ast.Date(2025, 12, 31), Some(ast.Time(9, 60))),
  ))
  |> validator.validate
  |> should.equal(Error(validator.InvalidTime("invalid time", ast.Time(9, 60))))
}

pub fn between_invalid_bounds_asymmetry_some_none_test() {
  let s =
    ast.Between(
      ast.BoundPoint(ast.Date(2025, 1, 1), Some(ast.Time(0, 0))),
      ast.BoundPoint(ast.Date(2025, 12, 31), None),
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
      ast.BoundPoint(ast.Date(2025, 1, 1), None),
      ast.BoundPoint(ast.Date(2025, 12, 31), Some(ast.Time(23, 59))),
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
  let s = with_days(ast.Weekdays)
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn weekends_is_valid_test() {
  let s = with_days(ast.Weekends)
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
