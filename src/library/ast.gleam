import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/order
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

pub fn compare_time(a: Time, b: Time) -> order.Order {
  case int.compare(a.hour, b.hour) {
    order.Eq -> int.compare(a.minute, b.minute)
    order -> order
  }
}

pub fn midnight() -> Time {
  Time(0, 0)
}

/// "on monday", "on weekdays", "on the 1st", etc.
pub type Days {
  SpecificDays(List(DayOfWeek))
  BareOrdinalDays(List(Ordinal))
  QualifiedOrdinalDays(List(NthWeekday))
}

pub fn weekdays() {
  [Mon, Tue, Wed, Thu, Fri]
}

pub fn weekend() {
  [Sat, Sun]
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

pub fn normalise_days(a: Days) -> Days {
  case a {
    SpecificDays(xs) -> xs |> list.sort(sort_days_of_week) |> SpecificDays()

    BareOrdinalDays(xs) ->
      xs |> list.sort(sort_bare_ordinal_days) |> BareOrdinalDays()

    QualifiedOrdinalDays(xs) ->
      xs |> list.sort(sort_qualified_ordinal_days) |> QualifiedOrdinalDays()
  }
}

/// Comparator for sorting days of the week in calendar order (Mon > Tue > ... > Sun).
pub fn sort_days_of_week(a: DayOfWeek, b: DayOfWeek) -> order.Order {
  case a, b {
    Mon, Mon -> order.Eq
    Mon, _ -> order.Gt

    Tue, Mon -> order.Lt
    Tue, Tue -> order.Eq
    Tue, _ -> order.Gt

    Wed, Mon | Wed, Tue -> order.Lt
    Wed, Wed -> order.Eq
    Wed, _ -> order.Gt

    Thu, Mon | Thu, Tue | Thu, Wed -> order.Lt
    Thu, Thu -> order.Eq
    Thu, _ -> order.Gt

    Fri, Mon | Fri, Tue | Fri, Wed | Fri, Thu -> order.Lt
    Fri, Fri -> order.Eq
    Fri, _ -> order.Gt

    Sat, Sun -> order.Gt
    Sat, Sat -> order.Eq
    Sat, _ -> order.Lt

    Sun, Sun -> order.Eq
    Sun, _ -> order.Lt
  }
}

pub fn sort_bare_ordinal_days(a: Ordinal, b: Ordinal) -> order.Order {
  case a, b {
    DayOfMonth(x), DayOfMonth(y) -> int.compare(x, y)
    DayOfMonth(_), LastDay -> order.Gt
    LastDay, _ -> order.Lt
  }
}

pub fn sort_qualified_ordinal_days(a: NthWeekday, b: NthWeekday) -> order.Order {
  let NthWeekday(pos1, week_day1) = a
  let NthWeekday(pos2, week_day2) = b

  case sort_position(pos1, pos2) {
    order.Eq -> sort_days_of_week(week_day1, week_day2)
    order -> order
  }
}

fn sort_position(a: Position, b: Position) -> order.Order {
  case a, b {
    First, First -> order.Eq
    First, _ -> order.Lt

    Second, First -> order.Gt
    Second, Second -> order.Eq
    Second, _ -> order.Lt

    Third, First | Third, Second -> order.Gt
    Third, Third -> order.Eq
    Third, _ -> order.Lt

    Fourth, Fifth | Fourth, Last -> order.Lt
    Fourth, Fourth -> order.Eq
    Fourth, _ -> order.Gt

    Fifth, Last -> order.Lt
    Fifth, Fifth -> order.Eq
    Fifth, _ -> order.Gt

    Last, Last -> order.Eq
    Last, _ -> order.Gt
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

pub fn normalise_times(a: Timing) -> Timing {
  case a {
    At(times) -> At(list.sort(times, compare_time))
    time_range -> time_range
  }
}

/// Date and optional time "2024-01-01 at 09:00" or "2024-01-01"
pub type BoundPoint {
  BoundPoint(date: Date, time: Time)
}

pub fn compare_bound_point(a: BoundPoint, b: BoundPoint) -> order.Order {
  case compare_date(a.date, b.date) {
    order.Eq -> compare_time(a.time, b.time)
    order -> order
  }
}

/// 2026-01-10
pub type Date {
  Date(year: Int, month: Int, day: Int)
}

pub fn compare_date(a: Date, b: Date) -> order.Order {
  case int.compare(a.year, b.year), int.compare(a.month, b.month) {
    order.Eq, order.Eq -> int.compare(a.day, b.day)
    order.Eq, order -> order
    order, _ -> order
  }
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

pub fn normalise_exclusion(a: Exclusion) -> Exclusion {
  case a {
    ExceptDays(days) -> ExceptDays(normalise_days(days))
    ExceptTime(timing) -> ExceptTime(normalise_times(timing))
    _ -> a
  }
}
