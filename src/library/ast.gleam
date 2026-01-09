import gleam/option.{type Option}

/// complete schedule expression
pub type Schedule {
  Schedule(
    frequency: Option(Frequency),
    timing: Option(Timing),
    days: Option(Days),
    time_range: Option(TimeRange),
    bounds: Option(Bounds),
    exclusion: Option(Exclusion),
  )
}

/// "every 5 minutes" or "hourly"
pub type Frequency {
  Every(amount: Int, unit: TimeUnit)
  Hourly
  Daily
  Weekly
  Monthly
  Annually
}

pub type TimeUnit {
  Seconds
  Minutes
  Hours
  Days
}

/// "at 9:00" or "at 9:00, 12:00, and 17:00"
pub type Timing {
  At(times: List(Time))
}

/// 24-hour time
pub type Time {
  Time(hour: Int, minute: Int)
}

/// "on monday", "on weekdays", "on the 1st", etc.
pub type Days {
  Weekdays
  Weekends
  SpecificDays(List(DayOfWeek))
  OrdinalDays(List(Ordinal))
}

pub type DayOfWeek {
  Mon
  Tue
  Wed
  Thu
  Fri
  Sat
  Sun
}

pub type Ordinal {
  DayOfMonth(Int)
  Last
  NthWeekday(Position, DayOfWeek)
}

pub type Position {
  First
  Second
  Third
  Fourth
  LastPos
}

/// "between 9:00 and 17:00"
pub type TimeRange {
  TimeRange(from: Time, to: Time)
}

/// Date and optional time "2024-01-01 at 09:00" or "2024-01-01"
pub type BoundPoint {
  BoundPoint(date: Date, time: Option(Time))
}

/// 2026-01-10
pub type Date {
  Date(year: Int, month: Int, day: Int)
}

/// "starting ...", "until ...", "from ... until ..."
pub type Bounds {
  Starting(BoundPoint)
  Until(BoundPoint)
  Between(from: BoundPoint, to: BoundPoint)
}

/// "except weekends", "except between 22:00 and 6:00"
pub type Exclusion {
  ExceptDays(Days)
  ExceptTimeRange(TimeRange)
}
