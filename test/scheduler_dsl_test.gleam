import gleeunit
import gleeunit/should
import library/lexer
import library/token.{
  And, At, Between, Comma, Daily, DateLiteral, Day, Every, Except, First, Fourth,
  Fri, From, Hourly, Hours, Integer, Last, Minutes, Mon, Monthly, On, Ordinal,
  Sat, Second, Seconds, Starting, Sun, The, Third, Thu, TimeLiteral, Tue, Until,
  Wed, Weekdays, Weekends, Weekly,
}

pub fn main() {
  gleeunit.main()
}

// Basic intervals

pub fn lex_every_minutes_test() {
  lexer.lex("every 5 minutes")
  |> should.equal(Ok([Every, Integer(5), Minutes]))
}

pub fn lex_every_seconds_test() {
  lexer.lex("every 30 seconds")
  |> should.equal(Ok([Every, Integer(30), Seconds]))
}

pub fn lex_every_hours_test() {
  lexer.lex("every 2 hours")
  |> should.equal(Ok([Every, Integer(2), Hours]))
}

pub fn lex_every_day_test() {
  lexer.lex("every 1 day")
  |> should.equal(Ok([Every, Integer(1), Day]))
}

pub fn lex_hourly_test() {
  lexer.lex("hourly")
  |> should.equal(Ok([Hourly]))
}

pub fn lex_daily_test() {
  lexer.lex("daily")
  |> should.equal(Ok([Daily]))
}

pub fn lex_weekly_test() {
  lexer.lex("weekly")
  |> should.equal(Ok([Weekly]))
}

pub fn lex_monthly_test() {
  lexer.lex("monthly")
  |> should.equal(Ok([Monthly]))
}

// Specific times

pub fn lex_at_time_test() {
  lexer.lex("at 09:00")
  |> should.equal(Ok([At, TimeLiteral(9, 0)]))
}

pub fn lex_at_time_afternoon_test() {
  lexer.lex("at 14:30")
  |> should.equal(Ok([At, TimeLiteral(14, 30)]))
}

pub fn lex_at_two_times_test() {
  lexer.lex("at 09:00 and 17:00")
  |> should.equal(Ok([At, TimeLiteral(9, 0), And, TimeLiteral(17, 0)]))
}

pub fn lex_at_three_times_test() {
  lexer.lex("at 09:00, 12:00, and 17:00")
  |> should.equal(
    Ok([
      At,
      TimeLiteral(9, 0),
      Comma,
      TimeLiteral(12, 0),
      Comma,
      And,
      TimeLiteral(17, 0),
    ]),
  )
}

// Days of the week

pub fn lex_on_monday_test() {
  lexer.lex("on monday")
  |> should.equal(Ok([On, Mon]))
}

pub fn lex_on_monday_and_friday_test() {
  lexer.lex("on monday and friday")
  |> should.equal(Ok([On, Mon, And, Fri]))
}

pub fn lex_on_weekdays_test() {
  lexer.lex("on weekdays")
  |> should.equal(Ok([On, Weekdays]))
}

pub fn lex_on_weekends_test() {
  lexer.lex("on weekends")
  |> should.equal(Ok([On, Weekends]))
}

// Monthly day references

pub fn lex_on_the_1st_test() {
  lexer.lex("on the 1st")
  |> should.equal(Ok([On, The, Ordinal(1)]))
}

pub fn lex_on_the_15th_and_last_test() {
  lexer.lex("on the 15th and last")
  |> should.equal(Ok([On, The, Ordinal(15), And, Last]))
}

pub fn lex_on_the_last_friday_test() {
  lexer.lex("on the last friday")
  |> should.equal(Ok([On, The, Last, Fri]))
}

pub fn lex_on_the_first_monday_test() {
  lexer.lex("on the first monday")
  |> should.equal(Ok([On, The, First, Mon]))
}

pub fn lex_on_the_1st_and_15th_test() {
  lexer.lex("on the 1st and 15th")
  |> should.equal(Ok([On, The, Ordinal(1), And, Ordinal(15)]))
}

pub fn lex_on_the_second_tuesday_test() {
  lexer.lex("on the second tuesday")
  |> should.equal(Ok([On, The, Second, Tue]))
}

pub fn lex_on_the_third_wednesday_test() {
  lexer.lex("on the third wednesday")
  |> should.equal(Ok([On, The, Third, Wed]))
}

pub fn lex_on_the_fourth_thursday_test() {
  lexer.lex("on the fourth thursday")
  |> should.equal(Ok([On, The, Fourth, Thu]))
}

// Combined expressions

pub fn lex_every_minutes_on_weekdays_test() {
  lexer.lex("every 30 minutes on weekdays")
  |> should.equal(Ok([Every, Integer(30), Minutes, On, Weekdays]))
}

pub fn lex_at_time_on_monday_test() {
  lexer.lex("at 09:00 on monday")
  |> should.equal(Ok([At, TimeLiteral(9, 0), On, Mon]))
}

pub fn lex_at_times_on_weekdays_test() {
  lexer.lex("at 09:00 and 17:00 on weekdays")
  |> should.equal(
    Ok([
      At,
      TimeLiteral(9, 0),
      And,
      TimeLiteral(17, 0),
      On,
      Weekdays,
    ]),
  )
}

pub fn lex_every_hours_on_weekend_days_test() {
  lexer.lex("every 2 hours on saturday and sunday")
  |> should.equal(Ok([Every, Integer(2), Hours, On, Sat, And, Sun]))
}

pub fn lex_daily_at_time_test() {
  lexer.lex("daily at 09:00")
  |> should.equal(Ok([Daily, At, TimeLiteral(9, 0)]))
}

pub fn lex_weekly_on_day_at_time_test() {
  lexer.lex("weekly on monday at 09:00")
  |> should.equal(Ok([Weekly, On, Mon, At, TimeLiteral(9, 0)]))
}

pub fn lex_monthly_on_ordinal_at_time_test() {
  lexer.lex("monthly on the 1st at 12:00")
  |> should.equal(Ok([Monthly, On, The, Ordinal(1), At, TimeLiteral(12, 0)]))
}

pub fn lex_monthly_on_last_friday_at_time_test() {
  lexer.lex("monthly on the last friday at 09:00")
  |> should.equal(Ok([Monthly, On, The, Last, Fri, At, TimeLiteral(9, 0)]))
}

// Time ranges

pub fn lex_every_minutes_between_times_test() {
  lexer.lex("every 15 minutes between 09:00 and 17:00")
  |> should.equal(
    Ok([
      Every,
      Integer(15),
      Minutes,
      Between,
      TimeLiteral(9, 0),
      And,
      TimeLiteral(17, 0),
    ]),
  )
}

pub fn lex_every_minutes_between_times_on_weekdays_test() {
  lexer.lex("every 15 minutes between 09:00 and 17:00 on weekdays")
  |> should.equal(
    Ok([
      Every,
      Integer(15),
      Minutes,
      Between,
      TimeLiteral(9, 0),
      And,
      TimeLiteral(17, 0),
      On,
      Weekdays,
    ]),
  )
}

pub fn lex_hourly_between_times_test() {
  lexer.lex("hourly between 08:00 and 20:00")
  |> should.equal(
    Ok([Hourly, Between, TimeLiteral(8, 0), And, TimeLiteral(20, 0)]),
  )
}

// Bounded schedules

pub fn lex_starting_date_test() {
  lexer.lex("starting 2024-01-01")
  |> should.equal(Ok([Starting, DateLiteral(2024, 1, 1)]))
}

pub fn lex_until_date_test() {
  lexer.lex("until 2024-12-31")
  |> should.equal(Ok([Until, DateLiteral(2024, 12, 31)]))
}

pub fn lex_from_until_dates_test() {
  lexer.lex("from 2024-01-01 until 2024-06-30")
  |> should.equal(
    Ok([
      From,
      DateLiteral(2024, 1, 1),
      Until,
      DateLiteral(2024, 6, 30),
    ]),
  )
}

pub fn lex_daily_at_time_starting_date_test() {
  lexer.lex("daily at 09:00 starting 2024-01-01")
  |> should.equal(
    Ok([
      Daily,
      At,
      TimeLiteral(9, 0),
      Starting,
      DateLiteral(2024, 1, 1),
    ]),
  )
}

pub fn lex_every_monday_at_time_from_until_test() {
  lexer.lex("every monday at 10:00 from 2024-01-01 until 2024-03-31")
  |> should.equal(
    Ok([
      Every,
      Mon,
      At,
      TimeLiteral(10, 0),
      From,
      DateLiteral(2024, 1, 1),
      Until,
      DateLiteral(2024, 3, 31),
    ]),
  )
}

// Exclusions

pub fn lex_every_minutes_except_weekends_test() {
  lexer.lex("every 30 minutes except weekends")
  |> should.equal(Ok([Every, Integer(30), Minutes, Except, Weekends]))
}

pub fn lex_daily_at_time_except_on_monday_test() {
  lexer.lex("daily at 09:00 except on monday")
  |> should.equal(Ok([Daily, At, TimeLiteral(9, 0), Except, On, Mon]))
}

pub fn lex_hourly_except_between_times_test() {
  lexer.lex("hourly except between 22:00 and 06:00")
  |> should.equal(
    Ok([
      Hourly,
      Except,
      Between,
      TimeLiteral(22, 0),
      And,
      TimeLiteral(6, 0),
    ]),
  )
}

pub fn lex_every_minutes_between_times_except_friday_test() {
  lexer.lex("every 15 minutes between 09:00 and 17:00 except on friday")
  |> should.equal(
    Ok([
      Every,
      Integer(15),
      Minutes,
      Between,
      TimeLiteral(9, 0),
      And,
      TimeLiteral(17, 0),
      Except,
      On,
      Fri,
    ]),
  )
}

// All days of the week

pub fn lex_all_days_test() {
  lexer.lex("monday tuesday wednesday thursday friday saturday sunday")
  |> should.equal(Ok([Mon, Tue, Wed, Thu, Fri, Sat, Sun]))
}

// Various ordinals

pub fn lex_ordinal_2nd_test() {
  lexer.lex("on the 2nd")
  |> should.equal(Ok([On, The, Ordinal(2)]))
}

pub fn lex_ordinal_3rd_test() {
  lexer.lex("on the 3rd")
  |> should.equal(Ok([On, The, Ordinal(3)]))
}

pub fn lex_ordinal_21st_test() {
  lexer.lex("on the 21st")
  |> should.equal(Ok([On, The, Ordinal(21)]))
}

pub fn lex_ordinal_22nd_test() {
  lexer.lex("on the 22nd")
  |> should.equal(Ok([On, The, Ordinal(22)]))
}

pub fn lex_ordinal_23rd_test() {
  lexer.lex("on the 23rd")
  |> should.equal(Ok([On, The, Ordinal(23)]))
}

pub fn lex_ordinal_31st_test() {
  lexer.lex("on the 31st")
  |> should.equal(Ok([On, The, Ordinal(31)]))
}
