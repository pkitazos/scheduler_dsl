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

fn recurring() -> ast.Schedule {
  ast.Recurring(
    frequency: ast.Every(1, ast.Days),
    timing: None,
    days: None,
    bounds: None,
    exclusions: None,
  )
}

fn daily(expr: String) -> String {
  "daily " <> expr
}

// --- OneOff: once on <date> at <time>

pub fn one_off_happy_path_test() {
  parse("once on 2024-01-15 at 09:30")
  |> should.equal(
    Ok(ast.OneOff(date: ast.Date(2024, 1, 15), time: ast.Time(9, 30))),
  )
}

pub fn one_off_missing_everything_test() {
  parse("once")
  |> should.equal(
    Error(parser.InvalidSchedule("expected date and time after `once`")),
  )
}

pub fn one_off_missing_on_test() {
  parse("once 2024-01-15 at 09:00")
  |> should.equal(Error(parser.InvalidSchedule("expected `on` after `once`")))
}

pub fn one_off_missing_date_test() {
  parse("once on monday")
  |> should.equal(Error(parser.InvalidSchedule("expected date after `on`")))
}

pub fn one_off_missing_at_and_time_test() {
  parse("once on 2024-01-15")
  |> should.equal(
    Error(parser.InvalidSchedule("expected `at` and time after date")),
  )
}

pub fn one_off_missing_time_test() {
  parse("once on 2024-01-15 at")
  |> should.equal(
    Error(parser.InvalidSchedule("expected time literal HH:mm after `at`")),
  )
}

pub fn one_off_trailing_tokens_test() {
  parse("once on 2024-01-15 at 09:00 daily")
  |> should.equal(
    Error(parser.InvalidSchedule("unexpected tokens after schedule: `daily`")),
  )
}

// --- Frequency
// frequency_sugar := "hourly" | "daily" | "weekly" | "monthly" | "annually"
// frequency       := "every" number unit | frequency_sugar

pub fn frequency_sugar_hourly_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("hourly")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Hours))))
}

pub fn frequency_sugar_daily_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("daily")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Days))))
}

pub fn frequency_sugar_weekly_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("weekly")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Weeks))))
}

pub fn frequency_sugar_monthly_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("monthly")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Months))))
}

pub fn frequency_sugar_annually_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("annually")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Years))))
}

pub fn frequency_every_second_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every second")
  |> should.equal(Ok(
    ast.Recurring(..base, frequency: ast.Every(1, ast.Seconds)),
  ))
}

pub fn frequency_every_minute_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every minute")
  |> should.equal(Ok(
    ast.Recurring(..base, frequency: ast.Every(1, ast.Minutes)),
  ))
}

pub fn frequency_every_hour_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every hour")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Hours))))
}

pub fn frequency_every_day_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every day")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Days))))
}

pub fn frequency_every_week_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every week")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Weeks))))
}

pub fn frequency_every_month_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every month")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Months))))
}

pub fn frequency_every_year_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every year")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Years))))
}

pub fn frequency_every_1_second_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 1 second")
  |> should.equal(Ok(
    ast.Recurring(..base, frequency: ast.Every(1, ast.Seconds)),
  ))
}

pub fn frequency_every_1_minute_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 1 minute")
  |> should.equal(Ok(
    ast.Recurring(..base, frequency: ast.Every(1, ast.Minutes)),
  ))
}

pub fn frequency_every_1_hour_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 1 hour")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Hours))))
}

pub fn frequency_every_1_day_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 1 day")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Days))))
}

pub fn frequency_every_1_week_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 1 week")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Weeks))))
}

pub fn frequency_every_1_month_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 1 month")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Months))))
}

pub fn frequency_every_1_year_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 1 year")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(1, ast.Years))))
}

pub fn frequency_every_30_seconds_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 30 seconds")
  |> should.equal(Ok(
    ast.Recurring(..base, frequency: ast.Every(30, ast.Seconds)),
  ))
}

pub fn frequency_every_5_minutes_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 5 minutes")
  |> should.equal(Ok(
    ast.Recurring(..base, frequency: ast.Every(5, ast.Minutes)),
  ))
}

pub fn frequency_every_2_hours_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 2 hours")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(2, ast.Hours))))
}

pub fn frequency_every_11_days_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 11 days")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(11, ast.Days))))
}

pub fn frequency_every_3_weeks_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 3 weeks")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(3, ast.Weeks))))
}

pub fn frequency_every_6_months_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 6 months")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(6, ast.Months))))
}

pub fn frequency_every_2_years_test() {
  let assert ast.Recurring(..) as base = recurring()

  parse("every 2 years")
  |> should.equal(Ok(ast.Recurring(..base, frequency: ast.Every(2, ast.Years))))
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

// Timing: "at" time_list | "from" time "to" time

pub fn timing_at_single_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("at 09:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(..base, timing: Some(ast.At([ast.Time(9, 0)]))),
  ))
}

pub fn timing_at_and_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("at 09:00 and 17:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      timing: Some(ast.At([ast.Time(9, 0), ast.Time(17, 0)])),
    ),
  ))
}

pub fn timing_at_comma_and_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("at 09:00, 12:00 and 17:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      timing: Some(ast.At([ast.Time(9, 0), ast.Time(12, 0), ast.Time(17, 0)])),
    ),
  ))
}

pub fn timing_from_to_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("from 09:00 to 17:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      timing: Some(ast.TimeRange(from: ast.Time(9, 0), to: ast.Time(17, 0))),
    ),
  ))
}

pub fn timing_at_no_time_error_test() {
  parse("daily at on weekdays")
  |> should.equal(
    Error(parser.InvalidTiming("expected time literal HH:mm after `at`")),
  )
}

pub fn timing_at_dangling_comma_error_test() {
  daily("at 09:00,")
  |> parse()
  |> should.equal(Error(parser.InvalidTiming("expected time after comma")))
}

pub fn timing_at_dangling_and_error_test() {
  daily("at 09:00 and")
  |> parse()
  |> should.equal(Error(parser.InvalidTiming("expected time after `and`")))
}

pub fn timing_from_no_time_error_test() {
  daily("from on weekdays")
  |> parse()
  |> should.equal(Error(parser.InvalidTimeRange("expected time after `from`")))
}

pub fn timing_from_incomplete_error_test() {
  daily("from 09:00")
  |> parse()
  |> should.equal(
    Error(parser.InvalidTimeRange("expected `to` after first time")),
  )
}

pub fn timing_from_to_no_end_time_error_test() {
  daily("from 09:00 to on")
  |> parse()
  |> should.equal(Error(parser.InvalidTimeRange("expected time after `to`")))
}

// Days: "on" day_list | "on" day_group
//       | "on" "the" bare_ordinal_list
//       | "on" "the" qualified_ordinal_list

pub fn days_weekdays_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on weekdays")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(..base, days: Some(ast.SpecificDays(ast.weekdays()))),
  ))
}

pub fn days_weekends_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on weekends")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(..base, days: Some(ast.SpecificDays(ast.weekend()))),
  ))
}

pub fn days_single_day_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on monday")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(..base, days: Some(ast.SpecificDays([ast.Mon]))),
  ))
}

pub fn days_day_and_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on monday and friday")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(..base, days: Some(ast.SpecificDays([ast.Mon, ast.Fri]))),
  ))
}

pub fn days_day_list_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on monday, wednesday and friday")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(ast.SpecificDays([ast.Mon, ast.Wed, ast.Fri])),
    ),
  ))
}

pub fn days_invalid_day_error_test() {
  daily("on 15th")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("token not a valid day")))
}

pub fn days_day_dangling_comma_error_test() {
  daily("on monday,")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected day after comma")))
}

pub fn days_day_dangling_and_error_test() {
  daily("on monday and")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected day after `and`")))
}

// --- Bare ordinals

pub fn days_bare_ordinal_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the 1st")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(..base, days: Some(ast.BareOrdinalDays([ast.DayOfMonth(1)]))),
  ))
}

pub fn days_bare_ordinal_and_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the 1st and 15th")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(ast.BareOrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15)])),
    ),
  ))
}

pub fn days_bare_ordinal_comma_and_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the 1st, 15th and last")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(
        ast.BareOrdinalDays([
          ast.DayOfMonth(1),
          ast.DayOfMonth(15),
          ast.LastDay,
        ]),
      ),
    ),
  ))
}

pub fn days_bare_ordinal_last_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the last")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(..base, days: Some(ast.BareOrdinalDays([ast.LastDay]))),
  ))
}

pub fn days_bare_ordinal_last_and_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the last and 1st")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(ast.BareOrdinalDays([ast.LastDay, ast.DayOfMonth(1)])),
    ),
  ))
}

pub fn days_bare_ordinal_and_last_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the 1st and last")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(ast.BareOrdinalDays([ast.DayOfMonth(1), ast.LastDay])),
    ),
  ))
}

pub fn days_bare_ordinal_comma_last_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the 1st, last")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(ast.BareOrdinalDays([ast.DayOfMonth(1), ast.LastDay])),
    ),
  ))
}

pub fn days_ordinal_dangling_comma_error_test() {
  daily("on the 1st,")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected ordinal after comma")))
}

pub fn days_ordinal_dangling_and_error_test() {
  daily("on the 1st and")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected ordinal after `and`")))
}

// --- Qualified ordinals

pub fn days_qualified_first_monday_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the first monday")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(ast.QualifiedOrdinalDays([ast.NthWeekday(ast.First, ast.Mon)])),
    ),
  ))
}

pub fn days_qualified_last_friday_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the last friday")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(ast.QualifiedOrdinalDays([ast.NthWeekday(ast.Last, ast.Fri)])),
    ),
  ))
}

pub fn days_qualified_second_tuesday_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the second tuesday")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(
        ast.QualifiedOrdinalDays([ast.NthWeekday(ast.Second, ast.Tue)]),
      ),
    ),
  ))
}

pub fn days_qualified_fifth_monday_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the fifth monday")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(ast.QualifiedOrdinalDays([ast.NthWeekday(ast.Fifth, ast.Mon)])),
    ),
  ))
}

pub fn days_qualified_and_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the first monday and last friday")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(
        ast.QualifiedOrdinalDays([
          ast.NthWeekday(ast.First, ast.Mon),
          ast.NthWeekday(ast.Last, ast.Fri),
        ]),
      ),
    ),
  ))
}

pub fn days_qualified_comma_list_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("on the first monday, last friday")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      days: Some(
        ast.QualifiedOrdinalDays([
          ast.NthWeekday(ast.First, ast.Mon),
          ast.NthWeekday(ast.Last, ast.Fri),
        ]),
      ),
    ),
  ))
}

pub fn days_qualified_no_weekday_error_test() {
  daily("on the first at")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("token not a valid day")))
}

pub fn days_qualified_invalid_position_error_test() {
  daily("on the at monday")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected position")))
}

pub fn days_qualified_dangling_comma_error_test() {
  daily("on the first monday,")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected ordinal after comma")))
}

pub fn days_qualified_dangling_and_error_test() {
  daily("on the first monday and")
  |> parse()
  |> should.equal(Error(parser.InvalidDays("expected ordinal after `and`")))
}

// --- Bounds
// bounds := "starting" date ("at" time)? ("until" date ("at" time)?)?

pub fn bounds_starting_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("starting 2024-01-01")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      bounds: Some(
        ast.Starting(ast.BoundPoint(
          date: ast.Date(2024, 1, 1),
          time: ast.midnight(),
        )),
      ),
    ),
  ))
}

pub fn bounds_starting_with_time_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("starting 2024-01-01 at 09:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      bounds: Some(
        ast.Starting(ast.BoundPoint(
          date: ast.Date(2024, 1, 1),
          time: ast.Time(9, 0),
        )),
      ),
    ),
  ))
}

pub fn bounds_between_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("starting 2024-01-01 until 2024-12-31")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      bounds: Some(ast.Between(
        from: ast.BoundPoint(date: ast.Date(2024, 1, 1), time: ast.midnight()),
        to: ast.BoundPoint(date: ast.Date(2024, 12, 31), time: ast.midnight()),
      )),
    ),
  ))
}

pub fn bounds_between_both_times_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("starting 2024-01-01 at 09:00 until 2024-12-31 at 17:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      bounds: Some(ast.Between(
        from: ast.BoundPoint(date: ast.Date(2024, 1, 1), time: ast.Time(9, 0)),
        to: ast.BoundPoint(date: ast.Date(2024, 12, 31), time: ast.Time(17, 0)),
      )),
    ),
  ))
}

pub fn bounds_between_from_time_only_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("starting 2024-01-01 at 09:00 until 2024-12-31")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      bounds: Some(ast.Between(
        from: ast.BoundPoint(date: ast.Date(2024, 1, 1), time: ast.Time(9, 0)),
        to: ast.BoundPoint(date: ast.Date(2024, 12, 31), time: ast.midnight()),
      )),
    ),
  ))
}

pub fn bounds_between_to_time_only_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("starting 2024-01-01 until 2024-12-31 at 17:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      bounds: Some(ast.Between(
        from: ast.BoundPoint(date: ast.Date(2024, 1, 1), time: ast.midnight()),
        to: ast.BoundPoint(date: ast.Date(2024, 12, 31), time: ast.Time(17, 0)),
      )),
    ),
  ))
}

pub fn bounds_starting_no_date_error_test() {
  daily("starting")
  |> parse()
  |> should.equal(Error(parser.InvalidBounds("expected date after `starting`")))
}

pub fn bounds_starting_until_no_end_date_error_test() {
  daily("starting 2024-01-01 until")
  |> parse()
  |> should.equal(Error(parser.InvalidBounds("expected date after `until`")))
}

pub fn bounds_starting_time_until_no_end_date_error_test() {
  daily("starting 2024-01-01 at 09:00 until")
  |> parse()
  |> should.equal(Error(parser.InvalidBounds("expected date after `until`")))
}

pub fn bounds_until_without_starting_error_test() {
  daily("until 2024-01-01")
  |> parse()
  |> should.equal(Error(parser.InvalidBounds("expected date after `until`")))
}

// --- Exclusions
// exclusion  := "except" on_clause | "except" time_clause | "except" bounds
// exclusions := exclusion+

pub fn exclusion_except_on_weekends_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except on weekends")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([ast.ExceptDays(ast.SpecificDays(ast.weekend()))]),
    ),
  ))
}

pub fn exclusion_except_on_weekdays_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except on weekdays")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([ast.ExceptDays(ast.SpecificDays(ast.weekdays()))]),
    ),
  ))
}

pub fn exclusion_except_on_day_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except on monday")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([ast.ExceptDays(ast.SpecificDays([ast.Mon]))]),
    ),
  ))
}

pub fn exclusion_except_on_ordinal_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except on the 1st")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([
        ast.ExceptDays(ast.BareOrdinalDays([ast.DayOfMonth(1)])),
      ]),
    ),
  ))
}

pub fn exclusion_except_at_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except at 12:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([ast.ExceptTime(ast.At([ast.Time(12, 0)]))]),
    ),
  ))
}

pub fn exclusion_except_at_list_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except at 12:00 and 13:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([
        ast.ExceptTime(ast.At([ast.Time(12, 0), ast.Time(13, 0)])),
      ]),
    ),
  ))
}

pub fn exclusion_except_from_to_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except from 22:00 to 06:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([
        ast.ExceptTime(ast.TimeRange(from: ast.Time(22, 0), to: ast.Time(6, 0))),
      ]),
    ),
  ))
}

pub fn exclusion_except_starting_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except starting 2024-06-01")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([
        ast.ExceptBounds(
          ast.Starting(ast.BoundPoint(
            date: ast.Date(2024, 6, 1),
            time: ast.midnight(),
          )),
        ),
      ]),
    ),
  ))
}

pub fn exclusion_except_between_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except starting 2024-06-01 until 2024-06-30")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([
        ast.ExceptBounds(ast.Between(
          from: ast.BoundPoint(date: ast.Date(2024, 6, 1), time: ast.midnight()),
          to: ast.BoundPoint(date: ast.Date(2024, 6, 30), time: ast.midnight()),
        )),
      ]),
    ),
  ))
}

pub fn exclusion_multiple_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except on weekends except from 22:00 to 06:00")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([
        ast.ExceptDays(ast.SpecificDays(ast.weekend())),
        ast.ExceptTime(ast.TimeRange(from: ast.Time(22, 0), to: ast.Time(6, 0))),
      ]),
    ),
  ))
}

pub fn exclusion_multiple_three_test() {
  let assert ast.Recurring(..) as base = recurring()

  daily("except on weekends except from 22:00 to 06:00 except on the 1st")
  |> parse()
  |> should.equal(Ok(
    ast.Recurring(
      ..base,
      exclusions: Some([
        ast.ExceptDays(ast.SpecificDays(ast.weekend())),
        ast.ExceptTime(ast.TimeRange(from: ast.Time(22, 0), to: ast.Time(6, 0))),
        ast.ExceptDays(ast.BareOrdinalDays([ast.DayOfMonth(1)])),
      ]),
    ),
  ))
}

pub fn exclusion_except_nothing_error_test() {
  daily("except")
  |> parse()
  |> should.equal(
    Error(parser.InvalidExclusion("expected days or time range after `except`")),
  )
}

// --- Full schedules
// schedule := frequency time_clause? on_clause? bounds? exclusions?

pub fn full_schedule_freq_and_days_test() {
  parse("every 5 minutes on weekdays")
  |> should.equal(
    Ok(ast.Recurring(
      frequency: ast.Every(5, ast.Minutes),
      timing: None,
      days: Some(ast.SpecificDays(ast.weekdays())),
      bounds: None,
      exclusions: None,
    )),
  )
}

pub fn full_schedule_freq_timing_days_test() {
  parse("daily at 09:00 on weekdays")
  |> should.equal(
    Ok(ast.Recurring(
      frequency: ast.Every(1, ast.Days),
      timing: Some(ast.At([ast.Time(9, 0)])),
      days: Some(ast.SpecificDays(ast.weekdays())),
      bounds: None,
      exclusions: None,
    )),
  )
}

pub fn full_schedule_daily_at_starting_test() {
  parse("daily at 09:00 starting 2024-01-01")
  |> should.equal(
    Ok(ast.Recurring(
      frequency: ast.Every(1, ast.Days),
      timing: Some(ast.At([ast.Time(9, 0)])),
      days: None,
      bounds: Some(
        ast.Starting(ast.BoundPoint(
          date: ast.Date(2024, 1, 1),
          time: ast.midnight(),
        )),
      ),
      exclusions: None,
    )),
  )
}

pub fn full_schedule_freq_days_exclusion_test() {
  parse("every 30 minutes on weekdays except on friday")
  |> should.equal(
    Ok(ast.Recurring(
      frequency: ast.Every(30, ast.Minutes),
      timing: None,
      days: Some(ast.SpecificDays(ast.weekdays())),
      bounds: None,
      exclusions: Some([ast.ExceptDays(ast.SpecificDays([ast.Fri]))]),
    )),
  )
}

pub fn full_schedule_all_clauses_test() {
  parse("daily at 09:00 on weekdays starting 2024-01-01 until 2024-12-31")
  |> should.equal(
    Ok(ast.Recurring(
      frequency: ast.Every(1, ast.Days),
      timing: Some(ast.At([ast.Time(9, 0)])),
      days: Some(ast.SpecificDays(ast.weekdays())),
      bounds: Some(ast.Between(
        from: ast.BoundPoint(date: ast.Date(2024, 1, 1), time: ast.midnight()),
        to: ast.BoundPoint(date: ast.Date(2024, 12, 31), time: ast.midnight()),
      )),
      exclusions: None,
    )),
  )
}

pub fn full_schedule_hourly_from_to_on_weekdays_test() {
  parse("hourly from 09:00 to 17:00 on weekdays")
  |> should.equal(
    Ok(ast.Recurring(
      frequency: ast.Every(1, ast.Hours),
      timing: Some(ast.TimeRange(from: ast.Time(9, 0), to: ast.Time(17, 0))),
      days: Some(ast.SpecificDays(ast.weekdays())),
      bounds: None,
      exclusions: None,
    )),
  )
}

// --- Edge cases

pub fn empty_input_error_test() {
  parse("")
  |> should.equal(Error(parser.InvalidSchedule("empty")))
}

pub fn trailing_tokens_error_test() {
  parse("daily daily")
  |> should.equal(
    Error(parser.InvalidSchedule("unexpected tokens after schedule: `daily`")),
  )
}
