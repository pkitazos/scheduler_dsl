pub type Token {
  // Keywords
  Every
  At
  On
  The
  And
  Except
  Starting
  Until
  From
  To

  // Frequency shortcuts
  Once
  Hourly
  Daily
  Weekly
  Monthly
  Annually

  // Time units
  Second
  Seconds
  Minute
  Minutes
  Hour
  Hours
  Day
  Days
  Week
  Weeks
  Month
  Months
  Year
  Years

  // Day groups
  Weekdays
  Weekends

  // Days of week
  Mon
  Tue
  Wed
  Thu
  Fri
  Sat
  Sun

  // Ordinal positions
  First
  // "second" is lexed as the time-unit token `Second`; the parser
  // reuses it as an ordinal position (2nd) via context-based disambiguation
  Third
  Fourth
  Fifth
  Last

  // Literals
  Integer(Int)
  Ordinal(Int)
  // 1st, 2nd, 3rd, 15th — stores just the number
  TimeLiteral(Int, Int)
  // 09:00 — stores hour, minute
  DateLiteral(Int, Int, Int)

  // 2024-01-15 — stores year, month, day
  // Punctuation
  Comma
}
