pub type Token {
  // Keywords
  Every
  At
  On
  The
  And
  Between
  Except
  Starting
  Until
  From

  // Frequency shortcuts
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

  // Day groups
  Weekdays
  Weekend

  // Days of week
  Monday
  Tuesday
  Wednesday
  Thursday
  Friday
  Saturday
  Sunday

  // Ordinal positions
  First
  // Second covered by unit second
  Third
  Fourth
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
