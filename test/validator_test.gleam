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

// --- Frequency

pub fn every_0_seconds_is_invalid_test() {
  schedule(ast.Every(0, ast.Seconds))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidFrequency(
      "frequency can't be 0",
      ast.Every(0, ast.Seconds),
    )),
  )
}

pub fn every_0_minutes_is_invalid_test() {
  schedule(ast.Every(0, ast.Minutes))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidFrequency(
      "frequency can't be 0",
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
  |> should.equal(
    Error(validator.InvalidTime("invalid time", ast.Time(25, 0))),
  )
}

pub fn time_range_invalid_to_test() {
  with_timing(ast.TimeRange(ast.Time(9, 0), ast.Time(9, 60)))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidTime("invalid time", ast.Time(9, 60))),
  )
}

pub fn equal_invalid_time_range_returns_time_error_test() {
  with_timing(ast.TimeRange(ast.Time(25, 0), ast.Time(25, 0)))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidTime("invalid time", ast.Time(25, 0))),
  )
}

// --- Timing: At

pub fn at_single_valid_time_test() {
  let s = with_timing(ast.At([ast.Time(9, 0)]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn at_multiple_valid_times_test() {
  let s = with_timing(ast.At([ast.Time(9, 0), ast.Time(12, 0), ast.Time(17, 0)]))
  validator.validate(s) |> should.equal(Ok(s))
}

pub fn at_duplicate_times_is_invalid_test() {
  with_timing(ast.At([ast.Time(9, 0), ast.Time(9, 0)]))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidTimeList(
      "invalid time list, contains duplicates",
      [ast.Time(9, 0)],
    )),
  )
}

pub fn at_invalid_time_test() {
  with_timing(ast.At([ast.Time(25, 0)]))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidTime("invalid time", ast.Time(25, 0))),
  )
}

pub fn at_invalid_time_before_duplicate_check_test() {
  with_timing(ast.At([ast.Time(25, 0), ast.Time(25, 0)]))
  |> validator.validate
  |> should.equal(
    Error(validator.InvalidTime("invalid time", ast.Time(25, 0))),
  )
}
