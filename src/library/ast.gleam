import gleam/option.{type Option}
import library/ast/multiset

/// complete schedule expression
pub type Schedule {
  OneOff(date: Date, time: Time)
  Recurring(
    frequency: Frequency,
    timing: Option(Timing),
    days: Option(Days),
    bounds: Option(Bounds),
    exclusions: Option(List(Exclusion)),
  )
}

/// "every 5 minutes" or "hourly"
pub type Frequency {
  Every(amount: Int, unit: TimeUnit)
}

pub type TimeUnit {
  Seconds
  Minutes
  Hours
  Days
  Weeks
  Months
  Years
}

/// 24-hour time
pub type Time {
  Time(hour: Int, minute: Int)
}

/// "on monday", "on weekdays", "on the 1st", etc.
pub type Days {
  SpecificDays(List(DayOfWeek))
  BareOrdinalDays(List(Ordinal))
  QualifiedOrdinalDays(List(NthWeekday))
}

pub fn eq_days(a: Days, b: Days) -> Bool {
  case a, b {
    SpecificDays(xs), SpecificDays(ys) -> multiset.eq(xs, ys)
    SpecificDays(_), _ -> False

    BareOrdinalDays(xs), BareOrdinalDays(ys) -> multiset.eq(xs, ys)
    BareOrdinalDays(_), _ -> False

    QualifiedOrdinalDays(xs), QualifiedOrdinalDays(ys) -> multiset.eq(xs, ys)
    QualifiedOrdinalDays(_), _ -> False
  }
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
  LastDay
}

pub type NthWeekday {
  NthWeekday(Position, DayOfWeek)
}

pub type Position {
  First
  Second
  Third
  Fourth
  Fifth
  Last
}

pub type Timing {
  /// "at 9:00" or "at 9:00, 12:00, and 17:00"
  At(times: List(Time))
  /// "from 9:00 to 17:00"
  TimeRange(from: Time, to: Time)
}

pub fn eq_times(a: Timing, b: Timing) -> Bool {
  case a, b {
    At(xs), At(ys) -> multiset.eq(xs, ys)
    At(_), TimeRange(_, _) -> False
    a, b -> a == b
  }
}

/// Date and optional time "2024-01-01 at 09:00" or "2024-01-01"
pub type BoundPoint {
  BoundPoint(date: Date, time: Option(Time))
}

/// 2026-01-10
pub type Date {
  Date(year: Int, month: Int, day: Int)
}

/// "starting ...", "starting ... until ..."
pub type Bounds {
  Starting(BoundPoint)
  Between(from: BoundPoint, to: BoundPoint)
}

/// "except weekends", "except from 22:00 to 6:00"
pub type Exclusion {
  ExceptDays(Days)
  ExceptTime(Timing)
  ExceptBounds(Bounds)
}
