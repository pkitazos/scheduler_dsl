import gleam/option.{None}
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
