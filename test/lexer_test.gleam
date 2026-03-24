import gleeunit/should
import library/lexer
import library/token.{
  And, Annually, At, Comma, Daily, Day, Days, Every, Fri, From, Hour, Hourly,
  Hours, Integer, Last, Minute, Minutes, Mon, Month, Monthly, Months, On,
  Ordinal, Sat, Second, Seconds, Starting, Sun, The, Thu, TimeLiteral, To, Tue,
  Wed, Week, Weekdays, Weekends, Weekly, Weeks, Year, Years,
}

// ── Base Types ──────────────────────────────────────────────────────
// number := [0-9]+
// time   := HH:MM
// date   := YYYY-MM-DD

pub fn number_test() {
  lexer.lex("42")
  |> should.equal(Ok([Integer(42)]))
}

pub fn time_test() {
  lexer.lex("09:00")
  |> should.equal(Ok([TimeLiteral(9, 0)]))
}

pub fn time_afternoon_test() {
  lexer.lex("23:59")
  |> should.equal(Ok([TimeLiteral(23, 59)]))
}

pub fn date_test() {
  lexer.lex("2024-01-15")
  |> should.equal(Ok([token.DateLiteral(2024, 1, 15)]))
}

// ── Units ───────────────────────────────────────────────────────────
// unit := "second" | "seconds"
//        | "minute" | "minutes"
//        | "hour" | "hours"
//        | "day" | "days"
//        | "week" | "weeks"
//        | "month" | "months"
//        | "year" | "years"

pub fn unit_second_test() {
  lexer.lex("second")
  |> should.equal(Ok([Second]))
}

pub fn unit_seconds_test() {
  lexer.lex("seconds")
  |> should.equal(Ok([Seconds]))
}

pub fn unit_minute_test() {
  lexer.lex("minute")
  |> should.equal(Ok([Minute]))
}

pub fn unit_minutes_test() {
  lexer.lex("minutes")
  |> should.equal(Ok([Minutes]))
}

pub fn unit_hour_test() {
  lexer.lex("hour")
  |> should.equal(Ok([Hour]))
}

pub fn unit_hours_test() {
  lexer.lex("hours")
  |> should.equal(Ok([Hours]))
}

pub fn unit_day_test() {
  lexer.lex("day")
  |> should.equal(Ok([Day]))
}

pub fn unit_days_test() {
  lexer.lex("days")
  |> should.equal(Ok([Days]))
}

pub fn unit_week_test() {
  lexer.lex("week")
  |> should.equal(Ok([Week]))
}

pub fn unit_weeks_test() {
  lexer.lex("weeks")
  |> should.equal(Ok([Weeks]))
}

pub fn unit_month_test() {
  lexer.lex("month")
  |> should.equal(Ok([Month]))
}

pub fn unit_months_test() {
  lexer.lex("months")
  |> should.equal(Ok([Months]))
}

pub fn unit_year_test() {
  lexer.lex("year")
  |> should.equal(Ok([Year]))
}

pub fn unit_years_test() {
  lexer.lex("years")
  |> should.equal(Ok([Years]))
}

// ── Days ────────────────────────────────────────────────────────────
// day := "monday" | "tuesday" | "wednesday" | "thursday"
//      | "friday" | "saturday" | "sunday"

pub fn day_monday_test() {
  lexer.lex("monday")
  |> should.equal(Ok([Mon]))
}

pub fn day_tuesday_test() {
  lexer.lex("tuesday")
  |> should.equal(Ok([Tue]))
}

pub fn day_wednesday_test() {
  lexer.lex("wednesday")
  |> should.equal(Ok([Wed]))
}

pub fn day_thursday_test() {
  lexer.lex("thursday")
  |> should.equal(Ok([Thu]))
}

pub fn day_friday_test() {
  lexer.lex("friday")
  |> should.equal(Ok([Fri]))
}

pub fn day_saturday_test() {
  lexer.lex("saturday")
  |> should.equal(Ok([Sat]))
}

pub fn day_sunday_test() {
  lexer.lex("sunday")
  |> should.equal(Ok([Sun]))
}

// ── Day Groups ──────────────────────────────────────────────────────
// day_group := "weekdays" | "weekends"

pub fn day_group_weekdays_test() {
  lexer.lex("weekdays")
  |> should.equal(Ok([Weekdays]))
}

pub fn day_group_weekends_test() {
  lexer.lex("weekends")
  |> should.equal(Ok([Weekends]))
}

// ── Frequency ───────────────────────────────────────────────────────
// frequency_sugar := "hourly" | "daily" | "weekly" | "monthly" | "annually"
// frequency       := "every" number unit | frequency_sugar

pub fn frequency_sugar_hourly_test() {
  lexer.lex("hourly")
  |> should.equal(Ok([Hourly]))
}

pub fn frequency_sugar_daily_test() {
  lexer.lex("daily")
  |> should.equal(Ok([Daily]))
}

pub fn frequency_sugar_weekly_test() {
  lexer.lex("weekly")
  |> should.equal(Ok([Weekly]))
}

pub fn frequency_sugar_monthly_test() {
  lexer.lex("monthly")
  |> should.equal(Ok([Monthly]))
}

pub fn frequency_sugar_annually_test() {
  lexer.lex("annually")
  |> should.equal(Ok([Annually]))
}

// ------

pub fn frequency_every_n_unit_test() {
  lexer.lex("every 5 minutes")
  |> should.equal(Ok([Every, Integer(5), Minutes]))
}

pub fn frequency_every_2_hours_test() {
  lexer.lex("every 2 hours")
  |> should.equal(Ok([Every, Integer(2), Hours]))
}

pub fn frequency_every_3_weeks_test() {
  lexer.lex("every 3 weeks")
  |> should.equal(Ok([Every, Integer(3), Weeks]))
}

pub fn frequency_every_6_months_test() {
  lexer.lex("every 6 months")
  |> should.equal(Ok([Every, Integer(6), Months]))
}

pub fn frequency_every_1_year_test() {
  lexer.lex("every 1 year")
  |> should.equal(Ok([Every, Integer(1), Year]))
}

// ── Ordinals ────────────────────────────────────────────────────────
// ordinal_suffix  := "st" | "nd" | "rd" | "th"
// bare_ordinal    := number ordinal_suffix | "last" | "last" "day"
// word_ordinal    := "first" | "second" | "third" | "fourth" | "fifth" | "last"

pub fn ordinal_suffix_1st_test() {
  lexer.lex("1st")
  |> should.equal(Ok([Ordinal(1)]))
}

pub fn ordinal_suffix_22nd_test() {
  lexer.lex("22nd")
  |> should.equal(Ok([Ordinal(22)]))
}

pub fn ordinal_suffix_3rd_test() {
  lexer.lex("3rd")
  |> should.equal(Ok([Ordinal(3)]))
}

pub fn ordinal_suffix_15th_test() {
  lexer.lex("15th")
  |> should.equal(Ok([Ordinal(15)]))
}

pub fn ordinal_suffix_31st_test() {
  lexer.lex("31st")
  |> should.equal(Ok([Ordinal(31)]))
}

// ------

pub fn word_ordinal_first_test() {
  lexer.lex("first")
  |> should.equal(Ok([token.First]))
}

pub fn word_ordinal_second_test() {
  lexer.lex("second")
  |> should.equal(Ok([token.Second]))
}

pub fn word_ordinal_third_test() {
  lexer.lex("third")
  |> should.equal(Ok([token.Third]))
}

pub fn word_ordinal_fourth_test() {
  lexer.lex("fourth")
  |> should.equal(Ok([token.Fourth]))
}

pub fn word_ordinal_fifth_test() {
  lexer.lex("fifth")
  |> should.equal(Ok([token.Fifth]))
}

pub fn word_ordinal_last_test() {
  lexer.lex("last")
  |> should.equal(Ok([Last]))
}

// ── Lists ───────────────────────────────────────────────────────────
// day_list  := day | day "and" day | day ("," day)* "," "and" day
// time_list := time | time "and" time | time ("," time)* "," "and" time

pub fn day_list_single_test() {
  lexer.lex("monday")
  |> should.equal(Ok([Mon]))
}

pub fn day_list_two_test() {
  lexer.lex("monday and friday")
  |> should.equal(Ok([Mon, And, Fri]))
}

pub fn day_list_oxford_comma_test() {
  lexer.lex("monday, wednesday, and friday")
  |> should.equal(Ok([Mon, Comma, Wed, Comma, And, Fri]))
}

// ------

pub fn time_list_three_test() {
  lexer.lex("09:00, 12:00, and 17:00")
  |> should.equal(
    Ok([
      TimeLiteral(9, 0),
      Comma,
      TimeLiteral(12, 0),
      Comma,
      And,
      TimeLiteral(17, 0),
    ]),
  )
}

// ── Clauses (token sequences) ───────────────────────────────────────
// on_clause   := "on" day_list | "on" day_group
//              | "on" "the" bare_ordinal_list
//              | "on" "the" qualified_ordinal_list
// time_clause := "from" time "to" time | "at" time_list
// bounds      := "starting" date | "starting" date "until" date
// exclusion   := "except" on_clause | "except" time_clause

pub fn on_clause_day_group_test() {
  lexer.lex("on weekdays")
  |> should.equal(Ok([On, Weekdays]))
}

pub fn on_clause_ordinal_test() {
  lexer.lex("on the 1st and 15th")
  |> should.equal(Ok([On, The, Ordinal(1), And, Ordinal(15)]))
}

pub fn on_clause_qualified_test() {
  lexer.lex("on the last friday")
  |> should.equal(Ok([On, The, Last, Fri]))
}

// ------

pub fn time_clause_at_test() {
  lexer.lex("at 09:00 and 17:00")
  |> should.equal(Ok([At, TimeLiteral(9, 0), And, TimeLiteral(17, 0)]))
}

pub fn time_clause_from_to_test() {
  lexer.lex("from 09:00 to 17:00")
  |> should.equal(Ok([From, TimeLiteral(9, 0), To, TimeLiteral(17, 0)]))
}

pub fn bounds_starting_test() {
  lexer.lex("starting 2024-01-01")
  |> should.equal(Ok([Starting, token.DateLiteral(2024, 1, 1)]))
}

pub fn bounds_starting_until_test() {
  lexer.lex("starting 2024-01-01 until 2024-12-31")
  |> should.equal(
    Ok([
      Starting,
      token.DateLiteral(2024, 1, 1),
      token.Until,
      token.DateLiteral(2024, 12, 31),
    ]),
  )
}

pub fn exclusion_except_on_test() {
  lexer.lex("except on monday")
  |> should.equal(Ok([token.Except, On, Mon]))
}

pub fn exclusion_except_from_to_test() {
  lexer.lex("except from 22:00 to 06:00")
  |> should.equal(
    Ok([token.Except, From, TimeLiteral(22, 0), To, TimeLiteral(6, 0)]),
  )
}

pub fn exclusion_except_time_list_test() {
  lexer.lex("except at 12:00 and 13:00")
  |> should.equal(
    Ok([token.Except, At, TimeLiteral(12, 0), And, TimeLiteral(13, 0)]),
  )
}

// ── Full schedule sequences ─────────────────────────────────────────
// schedule := frequency time_clause? on_clause? bounds? exclusions?

pub fn full_schedule_simple_test() {
  lexer.lex("every 30 minutes on weekdays")
  |> should.equal(Ok([Every, Integer(30), Minutes, On, Weekdays]))
}

pub fn full_schedule_with_bounds_test() {
  lexer.lex("daily at 09:00 starting 2024-01-01")
  |> should.equal(
    Ok([
      Daily,
      At,
      TimeLiteral(9, 0),
      Starting,
      token.DateLiteral(2024, 1, 1),
    ]),
  )
}

pub fn full_schedule_with_exclusion_test() {
  lexer.lex("every 30 minutes except on saturday and sunday")
  |> should.equal(
    Ok([
      Every,
      Integer(30),
      Minutes,
      token.Except,
      On,
      Sat,
      And,
      Sun,
    ]),
  )
}

// ── Case insensitivity ──────────────────────────────────────────────

pub fn case_insensitive_test() {
  lexer.lex("Every 5 Minutes On WEEKDAYS")
  |> should.equal(Ok([Every, Integer(5), Minutes, On, Weekdays]))
}

pub fn leading_trailing_whitespace_test() {
  lexer.lex("  daily  ")
  |> should.equal(Ok([Daily]))
}
