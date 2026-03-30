import gleam/option.{None, Some}
import gleeunit/should
import library/ast
import library/lexer
import library/parser

// --- Helpers

fn parse(input: String) -> Result(ast.Schedule, parser.ParseError) {
  let assert Ok(tokens) = lexer.lex(input)
  parser.parse(tokens)
}

fn schedule() -> ast.Schedule {
  ast.Schedule(
    frequency: ast.Once,
    timing: None,
    days: None,
    bounds: None,
    exclusions: None,
  )
}

fn once(expr: String) -> String {
  "once " <> expr
}

// --- Frequency
// frequency_sugar := "hourly" | "daily" | "weekly" | "monthly" | "annually"
// frequency       := "every" number unit | frequency_sugar

pub fn frequency_sugar_hourly_test() {
  parse("hourly")
  |> should.equal(Ok(ast.Schedule(..schedule(), frequency: ast.Hourly)))
}

pub fn frequency_sugar_daily_test() {
  parse("daily")
  |> should.equal(Ok(ast.Schedule(..schedule(), frequency: ast.Daily)))
}

pub fn frequency_sugar_weekly_test() {
  parse("weekly")
  |> should.equal(Ok(ast.Schedule(..schedule(), frequency: ast.Weekly)))
}

pub fn frequency_sugar_monthly_test() {
  parse("monthly")
  |> should.equal(Ok(ast.Schedule(..schedule(), frequency: ast.Monthly)))
}

pub fn frequency_sugar_annually_test() {
  parse("annually")
  |> should.equal(Ok(ast.Schedule(..schedule(), frequency: ast.Annually)))
}

pub fn frequency_every_second_test() {
  parse("every second")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(1, ast.Seconds)),
  ))
}

pub fn frequency_every_minute_test() {
  parse("every minute")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(1, ast.Minutes)),
  ))
}

pub fn frequency_every_1_second_test() {
  parse("every 1 second")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(1, ast.Seconds)),
  ))
}

pub fn frequency_every_1_minute_test() {
  parse("every 1 minute")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(1, ast.Minutes)),
  ))
}

pub fn frequency_every_1_day_test() {
  parse("every 1 day")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(1, ast.Days)),
  ))
}

pub fn frequency_every_30_seconds_test() {
  parse("every 30 seconds")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(30, ast.Seconds)),
  ))
}

pub fn frequency_every_5_minutes_test() {
  parse("every 5 minutes")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(5, ast.Minutes)),
  ))
}

pub fn frequency_every_2_hours_test() {
  parse("every 2 hours")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(2, ast.Hours)),
  ))
}

pub fn frequency_every_11_days_test() {
  parse("every 11 days")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(11, ast.Days)),
  ))
}

pub fn frequency_every_3_weeks_test() {
  parse("every 3 weeks")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(3, ast.Weeks)),
  ))
}

pub fn frequency_every_6_months_test() {
  parse("every 6 months")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(6, ast.Months)),
  ))
}

pub fn frequency_every_year_test() {
  parse("every year")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(1, ast.Years)),
  ))
}

pub fn frequency_every_2_years_test() {
  parse("every 2 years")
  |> should.equal(Ok(
    ast.Schedule(..schedule(), frequency: ast.Every(2, ast.Years)),
  ))
}

pub fn frequency_every_n_invalid_unit_error_test() {
  parse("every 5 weekdays")
  |> should.equal(
    Error(parser.InvalidFrequency("`every 5 weekdays` doesn't make sense")),
  )
}

pub fn frequency_every_n_incomplete_error_test() {
  parse("every 5")
  |> should.equal(Error(parser.InvalidFrequency("`every 5` is incomplete")))
}

pub fn frequency_every_invalid_error_test() {
  parse("every ,")
  |> should.equal(
    Error(parser.InvalidFrequency("`every ,` doesn't make sense")),
  )
}

pub fn frequency_missing_error_test() {
  parse("on weekdays")
  |> should.equal(
    Error(parser.InvalidFrequency(
      "`on weekdays` doesn't include a valid frequency",
    )),
  )
}

// --- Time clause: "at" time_list
// time_clause := "from" time "to" time | "at" time_list

pub fn time_clause_at_single_test() {
  once("at 09:00")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(..schedule(), timing: Some(ast.At([ast.Time(9, 0)]))),
  ))
}

pub fn time_clause_at_and_test() {
  once("at 09:00 and 17:00")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      timing: Some(ast.At([ast.Time(9, 0), ast.Time(17, 0)])),
    ),
  ))
}

pub fn time_clause_at_comma_and_test() {
  once("at 09:00, 12:00 and 17:00")
  |> parse
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      timing: Some(ast.At([ast.Time(9, 0), ast.Time(12, 0), ast.Time(17, 0)])),
    ),
  ))
}

pub fn time_clause_at_no_time_error_test() {
  parse("daily at on weekdays")
  |> should.equal(
    Error(parser.InvalidTiming("expected time literal HH:mm after `at`")),
  )
}

pub fn time_clause_at_dangling_comma_error_test() {
  once("at 09:00,")
  |> parse()
  |> should.equal(Error(parser.InvalidTiming("expected time after comma")))
}

pub fn time_clause_at_dangling_and_error_test() {
  once("at 09:00 and")
  |> parse()
  |> should.equal(Error(parser.InvalidTiming("expected time after `and`")))
}

// --- Time clause: "from" time "to" time

pub fn time_clause_from_to_test() {
  once("from 09:00 to 17:00")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      timing: Some(ast.TimeRange(from: ast.Time(9, 0), to: ast.Time(17, 0))),
    ),
  ))
}

pub fn time_clause_from_incomplete_error_test() {
  once("from 08:00")
  |> parse()
  |> should.equal(
    Error(parser.InvalidTimeRange("expected `to` after first time")),
  )
}

pub fn time_clause_from_no_time_error_test() {
  once("from on weekdays")
  |> parse()
  |> should.equal(Error(parser.InvalidTimeRange("expected time after `from`")))
}

pub fn time_clause_from_to_no_end_time_error_test() {
  once("from 09:00 to on")
  |> parse()
  |> should.equal(Error(parser.InvalidTimeRange("expected time after `to`")))
}

// --- On clause: day_list
// on_clause := "on" day_list | "on" day_group
//            | "on" "the" bare_ordinal_list
//            | "on" "the" qualified_ordinal_list

pub fn on_clause_day_group_weekdays_test() {
  once("on weekdays")
  |> parse()
  |> should.equal(Ok(ast.Schedule(..schedule(), days: Some(ast.Weekdays))))
}

pub fn on_clause_day_group_weekends_test() {
  once("on weekends")
  |> parse()
  |> should.equal(Ok(ast.Schedule(..schedule(), days: Some(ast.Weekends))))
}

pub fn on_clause_single_day_test() {
  once("on monday")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(..schedule(), days: Some(ast.SpecificDays([ast.Mon]))),
  ))
}

pub fn on_clause_day_and_test() {
  once("on monday and friday")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(..schedule(), days: Some(ast.SpecificDays([ast.Mon, ast.Fri]))),
  ))
}

pub fn on_clause_day_multi_list_test() {
  once("on monday, wednesday and friday")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.SpecificDays([ast.Mon, ast.Wed, ast.Fri])),
    ),
  ))
}

pub fn on_clause_invalid_day_error_test() {
  once("on 15th")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("token not a valid day")))
}

pub fn on_clause_day_dangling_comma_error_test() {
  once("on monday,")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected day after comma")))
}

pub fn on_clause_day_dangling_and_error_test() {
  once("on monday and")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected day after `and`")))
}

// --- On clause: bare_ordinal_list

pub fn on_clause_bare_ordinal_test() {
  once("on the 1st")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(..schedule(), days: Some(ast.OrdinalDays([ast.DayOfMonth(1)]))),
  ))
}

pub fn on_clause_bare_ordinal_and_test() {
  once("on the 1st and 15th")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15)])),
    ),
  ))
}

pub fn on_clause_bare_ordinal_multi_list_test() {
  once("on the 1st, 15th and last")
  |> parse()
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
  once("on the last")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(..schedule(), days: Some(ast.OrdinalDays([ast.Last]))),
  ))
}

pub fn on_clause_bare_ordinal_last_in_list_test() {
  once("on the last and 1st")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.Last, ast.DayOfMonth(1)])),
    ),
  ))
}

pub fn on_clause_bare_ordinal_list_with_last_test() {
  once("on the 1st and last")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.DayOfMonth(1), ast.Last])),
    ),
  ))
}

pub fn on_clause_ordinal_comma_then_last_test() {
  once("on the 1st, last")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.DayOfMonth(1), ast.Last])),
    ),
  ))
}

pub fn on_clause_ordinal_dangling_comma_error_test() {
  once("on the 1st,")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected ordinal after comma")))
}

pub fn on_clause_ordinal_dangling_and_error_test() {
  once("on the 1st and")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected ordinal after `and`")))
}

// --- On clause: qualified_ordinal_list

pub fn on_clause_qualified_ordinal_first_test() {
  once("on the first monday")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.NthWeekday(ast.First, ast.Mon)])),
    ),
  ))
}

pub fn on_clause_qualified_ordinal_last_test() {
  once("on the last friday")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.NthWeekday(ast.LastPos, ast.Fri)])),
    ),
  ))
}

pub fn on_clause_qualified_ordinal_second_test() {
  once("on the second tuesday")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.NthWeekday(ast.Second, ast.Tue)])),
    ),
  ))
}

pub fn on_clause_qualified_ordinal_fifth_test() {
  once("on the fifth monday")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      days: Some(ast.OrdinalDays([ast.NthWeekday(ast.Fifth, ast.Mon)])),
    ),
  ))
}

pub fn on_clause_qualified_ordinal_and_test() {
  once("on the first monday and last friday")
  |> parse()
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

pub fn on_clause_qualified_ordinal_comma_list_test() {
  once("on the first monday, last friday")
  |> parse()
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

pub fn on_clause_qualified_no_weekday_error_test() {
  once("on the first at")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("token not a valid day")))
}

// --- Bounds
// bounds := "starting" date | "starting" date "until" date

pub fn bounds_starting_test() {
  once("starting 2024-01-01")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      bounds: Some(
        ast.Starting(ast.BoundPoint(date: ast.Date(2024, 1, 1), time: None)),
      ),
    ),
  ))
}

pub fn bounds_starting_with_time_test() {
  once("starting 2024-01-01 at 09:00")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      bounds: Some(
        ast.Starting(ast.BoundPoint(
          date: ast.Date(2024, 1, 1),
          time: Some(ast.Time(9, 0)),
        )),
      ),
    ),
  ))
}

pub fn bounds_starting_until_test() {
  once("starting 2024-01-01 until 2024-12-31")
  |> parse()
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

pub fn bounds_starting_until_with_time_schedule_test() {
  once("starting 2024-01-01 at 09:00 until 2024-12-31 at 17:00")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      bounds: Some(ast.Between(
        from: ast.BoundPoint(
          date: ast.Date(2024, 1, 1),
          time: Some(ast.Time(9, 0)),
        ),
        to: ast.BoundPoint(
          date: ast.Date(2024, 12, 31),
          time: Some(ast.Time(17, 0)),
        ),
      )),
    ),
  ))
}

pub fn bounds_starting_with_time_until_no_time_test() {
  once("starting 2024-01-01 at 09:00 until 2024-12-31")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      bounds: Some(ast.Between(
        from: ast.BoundPoint(
          date: ast.Date(2024, 1, 1),
          time: Some(ast.Time(9, 0)),
        ),
        to: ast.BoundPoint(date: ast.Date(2024, 12, 31), time: None),
      )),
    ),
  ))
}

pub fn bounds_starting_no_time_until_with_time_test() {
  once("starting 2024-01-01 until 2024-12-31 at 17:00")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      bounds: Some(ast.Between(
        from: ast.BoundPoint(date: ast.Date(2024, 1, 1), time: None),
        to: ast.BoundPoint(
          date: ast.Date(2024, 12, 31),
          time: Some(ast.Time(17, 0)),
        ),
      )),
    ),
  ))
}

pub fn bounds_starting_no_date_error_test() {
  once("starting")
  |> parse()
  |> should.equal(Error(parser.InvalidBounds("expected date after `starting`")))
}

pub fn bounds_starting_until_no_end_date_error_test() {
  once("starting 2024-01-01 until")
  |> parse()
  |> should.equal(Error(parser.InvalidBounds("expected date after `until`")))
}

pub fn bounds_until_without_starting_error_test() {
  once("until 2024-01-01")
  |> parse()
  |> should.equal(Error(parser.InvalidBounds("expected date after `until`")))
}

// --- Exclusions
// exclusion  := "except" on_clause | "except" time_clause
// exclusions := exclusion+

pub fn exclusion_except_on_clause_group_test() {
  once("except on weekends")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(..schedule(), exclusions: Some([ast.ExceptDays(ast.Weekends)])),
  ))
}

pub fn exclusion_except_on_clause_day_test() {
  once("except on monday")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      exclusions: Some([ast.ExceptDays(ast.SpecificDays([ast.Mon]))]),
    ),
  ))
}

pub fn exclusion_except_on_clause_ordinal_test() {
  once("except on the 1st")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      exclusions: Some([ast.ExceptDays(ast.OrdinalDays([ast.DayOfMonth(1)]))]),
    ),
  ))
}

pub fn exclusion_except_from_to_test() {
  once("except from 22:00 to 06:00")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      exclusions: Some([
        ast.ExceptTime(ast.TimeRange(from: ast.Time(22, 0), to: ast.Time(6, 0))),
      ]),
    ),
  ))
}

pub fn exclusion_except_at_time_test() {
  once("except at 12:00")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      exclusions: Some([
        ast.ExceptTime(ast.At([ast.Time(12, 0)])),
      ]),
    ),
  ))
}

pub fn exclusion_except_at_time_list_test() {
  once("except at 12:00 and 13:00")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      exclusions: Some([
        ast.ExceptTime(ast.At([ast.Time(12, 0), ast.Time(13, 0)])),
      ]),
    ),
  ))
}

pub fn exclusion_except_bounds_starting_test() {
  once("except starting 2024-06-01")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      exclusions: Some([
        ast.ExceptBounds(
          ast.Starting(ast.BoundPoint(date: ast.Date(2024, 6, 1), time: None)),
        ),
      ]),
    ),
  ))
}

pub fn exclusion_except_bounds_between_test() {
  once("except starting 2024-06-01 until 2024-06-30")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      exclusions: Some([
        ast.ExceptBounds(ast.Between(
          from: ast.BoundPoint(date: ast.Date(2024, 6, 1), time: None),
          to: ast.BoundPoint(date: ast.Date(2024, 6, 30), time: None),
        )),
      ]),
    ),
  ))
}

pub fn exclusion_multiple_test() {
  once("except on weekends except from 22:00 to 06:00")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      exclusions: Some([
        ast.ExceptDays(ast.Weekends),
        ast.ExceptTime(ast.TimeRange(from: ast.Time(22, 0), to: ast.Time(6, 0))),
      ]),
    ),
  ))
}

pub fn exclusion_multiple_three_test() {
  once("except on weekends except from 22:00 to 06:00 except on the 1st")
  |> parse()
  |> should.equal(Ok(
    ast.Schedule(
      ..schedule(),
      exclusions: Some([
        ast.ExceptDays(ast.Weekends),
        ast.ExceptTime(ast.TimeRange(from: ast.Time(22, 0), to: ast.Time(6, 0))),
        ast.ExceptDays(ast.OrdinalDays([ast.DayOfMonth(1)])),
      ]),
    ),
  ))
}

pub fn exclusion_except_nothing_error_test() {
  once("except")
  |> parse()
  |> should.equal(
    Error(parser.InvalidExclusion("expected days or time range after `except`")),
  )
}

// --- Full schedule
// schedule := frequency time_clause? on_clause? bounds? exclusions?

pub fn full_schedule_freq_and_days_test() {
  parse("every 5 minutes on weekdays")
  |> should.equal(
    Ok(ast.Schedule(
      frequency: ast.Every(5, ast.Minutes),
      timing: None,
      days: Some(ast.Weekdays),
      bounds: None,
      exclusions: None,
    )),
  )
}

pub fn full_schedule_freq_timing_days_test() {
  parse("daily at 09:00 on weekdays")
  |> should.equal(
    Ok(ast.Schedule(
      frequency: ast.Daily,
      timing: Some(ast.At([ast.Time(9, 0)])),
      days: Some(ast.Weekdays),
      bounds: None,
      exclusions: None,
    )),
  )
}

pub fn full_schedule_daily_at_starting_test() {
  parse("daily at 09:00 starting 2024-01-01")
  |> should.equal(
    Ok(ast.Schedule(
      frequency: ast.Daily,
      timing: Some(ast.At([ast.Time(9, 0)])),
      days: None,
      bounds: Some(
        ast.Starting(ast.BoundPoint(date: ast.Date(2024, 1, 1), time: None)),
      ),
      exclusions: None,
    )),
  )
}

pub fn full_schedule_freq_days_exclusion_test() {
  parse("every 30 minutes on weekdays except on friday")
  |> should.equal(
    Ok(ast.Schedule(
      frequency: ast.Every(30, ast.Minutes),
      timing: None,
      days: Some(ast.Weekdays),
      bounds: None,
      exclusions: Some([ast.ExceptDays(ast.SpecificDays([ast.Fri]))]),
    )),
  )
}

pub fn full_schedule_all_clauses_test() {
  parse("daily at 09:00 on weekdays starting 2024-01-01 until 2024-12-31")
  |> should.equal(
    Ok(ast.Schedule(
      frequency: ast.Daily,
      timing: Some(ast.At([ast.Time(9, 0)])),
      days: Some(ast.Weekdays),
      bounds: Some(ast.Between(
        from: ast.BoundPoint(date: ast.Date(2024, 1, 1), time: None),
        to: ast.BoundPoint(date: ast.Date(2024, 12, 31), time: None),
      )),
      exclusions: None,
    )),
  )
}

pub fn full_schedule_hourly_from_to_on_weekdays_test() {
  parse("hourly from 09:00 to 17:00 on weekdays")
  |> should.equal(
    Ok(ast.Schedule(
      frequency: ast.Hourly,
      timing: Some(ast.TimeRange(from: ast.Time(9, 0), to: ast.Time(17, 0))),
      days: Some(ast.Weekdays),
      bounds: None,
      exclusions: None,
    )),
  )
}

pub fn trailing_tokens_error_test() {
  parse("daily daily")
  |> should.equal(
    Error(parser.InvalidSchedule("unexpected tokens after schedule: `daily`")),
  )
}
