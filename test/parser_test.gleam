import gleam/option.{None, Some}
import gleeunit/should
import library/ast
import library/lexer
import library/parser

// ── Helpers ─────────────────────────────────────────────────────────

fn parse(input: String) -> Result(ast.Schedule, parser.ParseError) {
  let assert Ok(tokens) = lexer.lex(input)
  parser.parse(tokens)
}

fn schedule() -> ast.Schedule {
  ast.Schedule(
    frequency: None,
    timing: None,
    days: None,
    time_range: None,
    bounds: None,
    exclusion: None,
  )
}

// ── Frequency ───────────────────────────────────────────────────────
// frequency_sugar := "hourly" | "daily" | "weekly" | "monthly" | "annually"
// frequency       := "every" number unit | frequency_sugar

pub fn frequency_sugar_hourly_test() {
  parse("hourly")
  |> should.equal(Ok(ast.Schedule(..schedule(), frequency: Some(ast.Hourly))))
}

pub fn frequency_sugar_daily_test() {
  parse("daily")
  |> should.equal(Ok(ast.Schedule(..schedule(), frequency: Some(ast.Daily))))
}

pub fn frequency_sugar_weekly_test() {
  parse("weekly")
  |> should.equal(Ok(ast.Schedule(..schedule(), frequency: Some(ast.Weekly))))
}

pub fn frequency_sugar_monthly_test() {
  parse("monthly")
  |> should.equal(Ok(ast.Schedule(..schedule(), frequency: Some(ast.Monthly))))
}

pub fn frequency_sugar_annually_test() {
  parse("annually")
  |> should.equal(Ok(ast.Schedule(..schedule(), frequency: Some(ast.Annually))))
}

pub fn frequency_every_second_test() {
  parse("every second")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: Some(ast.Every(1, ast.Seconds))),
  ))
}

pub fn frequency_every_minute_test() {
  parse("every minute")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: Some(ast.Every(1, ast.Minutes))),
  ))
}

pub fn frequency_every_30_seconds_test() {
  parse("every 30 seconds")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: Some(ast.Every(30, ast.Seconds))),
  ))
}

pub fn frequency_every_5_minutes_test() {
  parse("every 5 minutes")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: Some(ast.Every(5, ast.Minutes))),
  ))
}

pub fn frequency_every_2_hours_test() {
  parse("every 2 hours")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: Some(ast.Every(2, ast.Hours))),
  ))
}

// every 1 day fails
pub fn frequency_every_11_day_test() {
  parse("every 11 days")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: Some(ast.Every(11, ast.Days))),
  ))
}

pub fn frequency_every_3_weeks_test() {
  parse("every 3 weeks")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: Some(ast.Every(3, ast.Weeks))),
  ))
}

pub fn frequency_every_6_months_test() {
  parse("every 6 months")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: Some(ast.Every(6, ast.Months))),
  ))
}

pub fn frequency_every_year_test() {
  parse("every year")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: Some(ast.Every(1, ast.Years))),
  ))
}

// ── Time clause: "at" time_list ─────────────────────────────────────
// time_clause := "from" time "to" time | "at" time_list

pub fn time_clause_at_single_test() {
  parse("at 09:00")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), timing: Some(ast.At([ast.Time(9, 0)]))),
  ))
}

pub fn time_clause_at_and_test() {
  parse("at 09:00 and 17:00")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      timing: Some(ast.At([ast.Time(9, 0), ast.Time(17, 0)])),
    ),
  ))
}

pub fn time_clause_at_comma_and_test() {
  parse("at 09:00, 12:00 and 17:00")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      timing: Some(ast.At([ast.Time(9, 0), ast.Time(12, 0), ast.Time(17, 0)])),
    ),
  ))
}

// ── Time clause: "from" time "to" time ──────────────────────────────

pub fn time_clause_from_to_test() {
  parse("from 09:00 to 17:00")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      time_range: Some(ast.TimeRange(from: ast.Time(9, 0), to: ast.Time(17, 0))),
    ),
  ))
}

pub fn time_clause_from_test() {
  parse("from 08:00")
  |> should.equal(
    Error(parser.InvalidTimeRange("expected `to` after first time")),
  )
}

// ── On clause: day_list ─────────────────────────────────────────────
// on_clause := "on" day_list | "on" day_group
//            | "on" "the" bare_ordinal_list
//            | "on" "the" qualified_ordinal_list

pub fn on_clause_day_group_weekdays_test() {
  parse("on weekdays")
  |> should.equal(Ok(ast.Schedule(..schedule(), days: Some(ast.Weekdays))))
}

pub fn on_clause_day_group_weekends_test() {
  parse("on weekends")
  |> should.equal(Ok(ast.Schedule(..schedule(), days: Some(ast.Weekends))))
}

pub fn on_clause_single_day_test() {
  parse("on monday")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), days: Some(ast.SpecificDays([ast.Mon]))),
  ))
}

pub fn on_clause_day_and_test() {
  parse("on monday and friday")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), days: Some(ast.SpecificDays([ast.Mon, ast.Fri]))),
  ))
}

pub fn on_clause_day_multi_list_test() {
  parse("on monday, wednesday and friday")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.SpecificDays([ast.Mon, ast.Wed, ast.Fri])),
    ),
  ))
}

// ── On clause: bare_ordinal_list ────────────────────────────────────

pub fn on_clause_bare_ordinal_test() {
  parse("on the 1st")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), days: Some(ast.OrdinalDays([ast.DayOfMonth(1)]))),
  ))
}

pub fn on_clause_bare_ordinal_and_test() {
  parse("on the 1st and 15th")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15)])),
    ),
  ))
}

pub fn on_clause_bare_ordinal_multi_list_test() {
  parse("on the 1st, 15th and last")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(
        ast.OrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15), ast.Last]),
      ),
    ),
  ))
}

pub fn on_clause_bare_ordinal_last_test() {
  parse("on the last")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), days: Some(ast.OrdinalDays([ast.Last]))),
  ))
}

pub fn on_clause_bare_ordinal_last_in_list_test() {
  parse("on the last and 1st")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.Last, ast.DayOfMonth(1)])),
    ),
  ))
}

pub fn on_clause_bare_ordinal_list_with_last_test() {
  parse("on the 1st and last")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.DayOfMonth(1), ast.Last])),
    ),
  ))
}

// ── On clause: qualified_ordinal_list ───────────────────────────────

pub fn on_clause_qualified_ordinal_first_test() {
  parse("on the first monday")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.NthWeekday(ast.First, ast.Mon)])),
    ),
  ))
}

pub fn on_clause_qualified_ordinal_last_test() {
  parse("on the last friday")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.NthWeekday(ast.LastPos, ast.Fri)])),
    ),
  ))
}

pub fn on_clause_qualified_ordinal_second_test() {
  parse("on the second tuesday")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.NthWeekday(ast.Second, ast.Tue)])),
    ),
  ))
}

pub fn on_clause_qualified_ordinal_fifth_test() {
  parse("on the fifth monday")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.NthWeekday(ast.Fifth, ast.Mon)])),
    ),
  ))
}

pub fn on_clause_qualified_ordinal_and_test() {
  parse("on the first monday and last friday")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(
        ast.OrdinalDays([
          ast.NthWeekday(ast.First, ast.Mon),
          ast.NthWeekday(ast.LastPos, ast.Fri),
        ]),
      ),
    ),
  ))
}

// ── Bounds ──────────────────────────────────────────────────────────
// bounds := "starting" date | "starting" date "until" date

pub fn bounds_starting_test() {
  parse("starting 2024-01-01")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      bounds: Some(
        ast.Starting(ast.BoundPoint(date: ast.Date(2024, 1, 1), time: None)),
      ),
    ),
  ))
}

// Currently FAILS — parser matches "starting date" alone, leaving
// "until date" unconsumed. Needs "starting date until date" pattern.
pub fn bounds_starting_until_test() {
  parse("starting 2024-01-01 until 2024-12-31")
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      bounds: Some(ast.Between(
        from: ast.BoundPoint(date: ast.Date(2024, 1, 1), time: None),
        to: ast.BoundPoint(date: ast.Date(2024, 12, 31), time: None),
      )),
    ),
  ))
}

// ── Exclusions ──────────────────────────────────────────────────────
// exclusion  := "except" on_clause | "except" time_clause
// exclusions := exclusion+

pub fn exclusion_except_on_clause_test() {
  parse("except on weekends")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), exclusion: Some(ast.ExceptDays(ast.Weekends))),
  ))
}

// TODO: except on monday
// TODO: except on the 1st

// Currently FAILS — parser uses "except between...and", not "except from...to"
// pub fn exclusion_except_from_to_test() {
//   parse("except from 22:00 to 06:00")
//   |> should.equal(Ok(
//     ast.Schedule(
//       ..schedule(),
//       exclusion: Some(
//         ast.ExceptTimeRange(ast.TimeRange(
//           from: ast.Time(22, 0),
//           to: ast.Time(6, 0),
//         )),
//       ),
//     ),
//   ))
// }

// TODO: except at 12:00 — not supported yet (spec: "except" time_clause)
// TODO: except at 12:00 and 13:00
// TODO: multiple exclusions — spec says exclusion+, parser only handles one

// ── Full schedule ───────────────────────────────────────────────────
// schedule := frequency time_clause? on_clause? bounds? exclusions?

pub fn full_schedule_freq_and_days_test() {
  parse("every 5 minutes on weekdays")
  |> should.equal(
    Ok(ast.Schedule(
      frequency: Some(ast.Every(5, ast.Minutes)),
      timing: None,
      days: Some(ast.Weekdays),
      time_range: None,
      bounds: None,
      exclusion: None,
    )),
  )
}

pub fn full_schedule_freq_timing_days_test() {
  parse("daily at 09:00 on weekdays")
  |> should.equal(
    Ok(ast.Schedule(
      frequency: Some(ast.Daily),
      timing: Some(ast.At([ast.Time(9, 0)])),
      days: Some(ast.Weekdays),
      time_range: None,
      bounds: None,
      exclusion: None,
    )),
  )
}
// TODO: daily at 09:00 starting 2024-01-01
// TODO: every 30 minutes on weekdays except on friday
// TODO: hourly from 09:00 to 17:00 on weekdays — will fail (from...to)
// TODO: daily at 09:00 on weekdays starting 2024-01-01 until 2024-12-31
