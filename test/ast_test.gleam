import gleam/order
import gleeunit/should
import library/ast

// --- check_time

pub fn check_time_valid_test() {
  ast.check_time(ast.Time(12, 30))
  |> should.be_true
}

pub fn check_time_midnight_test() {
  ast.check_time(ast.Time(0, 0))
  |> should.be_true
}

pub fn check_time_max_valid_test() {
  ast.check_time(ast.Time(23, 59))
  |> should.be_true
}

pub fn check_time_hour_too_high_test() {
  ast.check_time(ast.Time(24, 0))
  |> should.be_false
}

pub fn check_time_minute_too_high_test() {
  ast.check_time(ast.Time(12, 60))
  |> should.be_false
}

pub fn check_time_negative_hour_test() {
  ast.check_time(ast.Time(-1, 0))
  |> should.be_false
}

pub fn check_time_negative_minute_test() {
  ast.check_time(ast.Time(0, -1))
  |> should.be_false
}

// --- check_date

pub fn check_date_valid_test() {
  ast.check_date(ast.Date(2026, 4, 4))
  |> should.be_true
}

pub fn check_date_leap_year_feb29_test() {
  ast.check_date(ast.Date(2024, 2, 29))
  |> should.be_true
}

pub fn check_date_non_leap_feb29_test() {
  ast.check_date(ast.Date(2025, 2, 29))
  |> should.be_false
}

pub fn check_date_century_not_leap_test() {
  ast.check_date(ast.Date(1900, 2, 29))
  |> should.be_false
}

pub fn check_date_400_year_leap_test() {
  ast.check_date(ast.Date(2000, 2, 29))
  |> should.be_true
}

pub fn check_date_month_too_high_test() {
  ast.check_date(ast.Date(2026, 13, 1))
  |> should.be_false
}

pub fn check_date_month_zero_test() {
  ast.check_date(ast.Date(2026, 0, 1))
  |> should.be_false
}

pub fn check_date_day_zero_test() {
  ast.check_date(ast.Date(2026, 1, 0))
  |> should.be_false
}

pub fn check_date_day_31_in_30_day_month_test() {
  ast.check_date(ast.Date(2026, 4, 31))
  |> should.be_false
}

pub fn check_date_day_31_in_31_day_month_test() {
  ast.check_date(ast.Date(2026, 1, 31))
  |> should.be_true
}

// --- compare_time

pub fn compare_time_equal_test() {
  ast.compare_time(ast.Time(9, 30), ast.Time(9, 30))
  |> should.equal(order.Eq)
}

pub fn compare_time_hour_lt_test() {
  ast.compare_time(ast.Time(8, 0), ast.Time(9, 0))
  |> should.equal(order.Lt)
}

pub fn compare_time_hour_gt_test() {
  ast.compare_time(ast.Time(10, 0), ast.Time(9, 0))
  |> should.equal(order.Gt)
}

pub fn compare_time_minute_lt_test() {
  ast.compare_time(ast.Time(9, 0), ast.Time(9, 30))
  |> should.equal(order.Lt)
}

pub fn compare_time_minute_gt_test() {
  ast.compare_time(ast.Time(9, 45), ast.Time(9, 30))
  |> should.equal(order.Gt)
}

// --- compare_date

pub fn compare_date_equal_test() {
  ast.compare_date(ast.Date(2026, 4, 4), ast.Date(2026, 4, 4))
  |> should.equal(order.Eq)
}

pub fn compare_date_year_lt_test() {
  ast.compare_date(ast.Date(2025, 12, 31), ast.Date(2026, 1, 1))
  |> should.equal(order.Lt)
}

pub fn compare_date_year_gt_test() {
  ast.compare_date(ast.Date(2027, 1, 1), ast.Date(2026, 12, 31))
  |> should.equal(order.Gt)
}

pub fn compare_date_month_lt_test() {
  ast.compare_date(ast.Date(2026, 3, 15), ast.Date(2026, 4, 1))
  |> should.equal(order.Lt)
}

pub fn compare_date_day_lt_test() {
  ast.compare_date(ast.Date(2026, 4, 3), ast.Date(2026, 4, 4))
  |> should.equal(order.Lt)
}

// --- compare_days_of_week

pub fn compare_days_of_week_equal_test() {
  ast.compare_days_of_week(ast.Mon, ast.Mon)
  |> should.equal(order.Eq)
}

pub fn compare_days_of_week_lt_test() {
  ast.compare_days_of_week(ast.Mon, ast.Sun)
  |> should.equal(order.Lt)
}

pub fn compare_days_of_week_gt_test() {
  ast.compare_days_of_week(ast.Sun, ast.Mon)
  |> should.equal(order.Gt)
}

pub fn compare_days_of_week_mid_lt_test() {
  ast.compare_days_of_week(ast.Wed, ast.Thu)
  |> should.equal(order.Lt)
}

pub fn compare_days_of_week_mid_gt_test() {
  ast.compare_days_of_week(ast.Fri, ast.Wed)
  |> should.equal(order.Gt)
}

// --- compare_bare_ordinal_days

pub fn compare_bare_ordinal_days_equal_test() {
  ast.compare_bare_ordinal_days(ast.DayOfMonth(15), ast.DayOfMonth(15))
  |> should.equal(order.Eq)
}

pub fn compare_bare_ordinal_days_lt_test() {
  ast.compare_bare_ordinal_days(ast.DayOfMonth(1), ast.DayOfMonth(31))
  |> should.equal(order.Lt)
}

pub fn compare_bare_ordinal_days_gt_test() {
  ast.compare_bare_ordinal_days(ast.DayOfMonth(31), ast.DayOfMonth(1))
  |> should.equal(order.Gt)
}

pub fn compare_bare_ordinal_days_lastday_lt_test() {
  ast.compare_bare_ordinal_days(ast.LastDay, ast.DayOfMonth(1))
  |> should.equal(order.Lt)
}

pub fn compare_bare_ordinal_days_dom_gt_lastday_test() {
  ast.compare_bare_ordinal_days(ast.DayOfMonth(31), ast.LastDay)
  |> should.equal(order.Gt)
}

pub fn compare_bare_ordinal_days_lastday_eq_test() {
  ast.compare_bare_ordinal_days(ast.LastDay, ast.LastDay)
  |> should.equal(order.Eq)
}

// --- compare_qualified_ordinal_days

pub fn compare_qualified_same_position_different_day_test() {
  ast.compare_qualified_ordinal_days(
    ast.NthWeekday(ast.First, ast.Mon),
    ast.NthWeekday(ast.First, ast.Fri),
  )
  |> should.equal(order.Lt)
}

pub fn compare_qualified_different_position_test() {
  ast.compare_qualified_ordinal_days(
    ast.NthWeekday(ast.First, ast.Mon),
    ast.NthWeekday(ast.Third, ast.Mon),
  )
  |> should.equal(order.Lt)
}

pub fn compare_qualified_equal_test() {
  ast.compare_qualified_ordinal_days(
    ast.NthWeekday(ast.Second, ast.Wed),
    ast.NthWeekday(ast.Second, ast.Wed),
  )
  |> should.equal(order.Eq)
}

pub fn compare_qualified_position_takes_priority_test() {
  ast.compare_qualified_ordinal_days(
    ast.NthWeekday(ast.First, ast.Sun),
    ast.NthWeekday(ast.Second, ast.Mon),
  )
  |> should.equal(order.Lt)
}

// --- compare_bound_point

pub fn compare_bound_point_equal_test() {
  let p = ast.BoundPoint(ast.Date(2026, 1, 1), ast.Time(9, 0))
  ast.compare_bound_point(p, p)
  |> should.equal(order.Eq)
}

pub fn compare_bound_point_date_differs_test() {
  let a = ast.BoundPoint(ast.Date(2026, 1, 1), ast.Time(9, 0))
  let b = ast.BoundPoint(ast.Date(2026, 1, 2), ast.Time(9, 0))
  ast.compare_bound_point(a, b)
  |> should.equal(order.Lt)
}

pub fn compare_bound_point_time_differs_test() {
  let a = ast.BoundPoint(ast.Date(2026, 1, 1), ast.Time(8, 0))
  let b = ast.BoundPoint(ast.Date(2026, 1, 1), ast.Time(9, 0))
  ast.compare_bound_point(a, b)
  |> should.equal(order.Lt)
}

pub fn compare_bound_point_date_takes_priority_test() {
  let a = ast.BoundPoint(ast.Date(2026, 1, 1), ast.Time(23, 59))
  let b = ast.BoundPoint(ast.Date(2026, 1, 2), ast.Time(0, 0))
  ast.compare_bound_point(a, b)
  |> should.equal(order.Lt)
}

// --- eq_days

pub fn eq_days_specific_same_order_test() {
  ast.eq_days(
    ast.SpecificDays([ast.Mon, ast.Tue]),
    ast.SpecificDays([ast.Mon, ast.Tue]),
  )
  |> should.be_true
}

pub fn eq_days_specific_different_order_test() {
  ast.eq_days(
    ast.SpecificDays([ast.Tue, ast.Mon]),
    ast.SpecificDays([ast.Mon, ast.Tue]),
  )
  |> should.be_true
}

pub fn eq_days_specific_different_test() {
  ast.eq_days(
    ast.SpecificDays([ast.Mon, ast.Tue]),
    ast.SpecificDays([ast.Mon, ast.Wed]),
  )
  |> should.be_false
}

pub fn eq_days_cross_variant_test() {
  ast.eq_days(
    ast.SpecificDays([ast.Mon]),
    ast.BareOrdinalDays([ast.DayOfMonth(1)]),
  )
  |> should.be_false
}

pub fn eq_days_bare_ordinal_different_order_test() {
  ast.eq_days(
    ast.BareOrdinalDays([ast.DayOfMonth(15), ast.DayOfMonth(1)]),
    ast.BareOrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15)]),
  )
  |> should.be_true
}

pub fn eq_days_qualified_different_order_test() {
  ast.eq_days(
    ast.QualifiedOrdinalDays([
      ast.NthWeekday(ast.Third, ast.Fri),
      ast.NthWeekday(ast.First, ast.Mon),
    ]),
    ast.QualifiedOrdinalDays([
      ast.NthWeekday(ast.First, ast.Mon),
      ast.NthWeekday(ast.Third, ast.Fri),
    ]),
  )
  |> should.be_true
}

// --- eq_times

pub fn eq_times_at_same_order_test() {
  ast.eq_times(
    ast.At([ast.Time(9, 0), ast.Time(17, 0)]),
    ast.At([ast.Time(9, 0), ast.Time(17, 0)]),
  )
  |> should.be_true
}

pub fn eq_times_at_different_order_test() {
  ast.eq_times(
    ast.At([ast.Time(17, 0), ast.Time(9, 0)]),
    ast.At([ast.Time(9, 0), ast.Time(17, 0)]),
  )
  |> should.be_true
}

pub fn eq_times_at_different_test() {
  ast.eq_times(ast.At([ast.Time(9, 0)]), ast.At([ast.Time(10, 0)]))
  |> should.be_false
}

pub fn eq_times_range_equal_test() {
  ast.eq_times(
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  )
  |> should.be_true
}

pub fn eq_times_range_different_test() {
  ast.eq_times(
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    ast.TimeRange(ast.Time(9, 0), ast.Time(18, 0)),
  )
  |> should.be_false
}

pub fn eq_times_cross_variant_test() {
  ast.eq_times(
    ast.At([ast.Time(9, 0)]),
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  )
  |> should.be_false
}

// --- normalise_days

pub fn normalise_days_specific_sorts_test() {
  ast.normalise_days(ast.SpecificDays([ast.Fri, ast.Mon, ast.Wed]))
  |> should.equal(ast.SpecificDays([ast.Mon, ast.Wed, ast.Fri]))
}

pub fn normalise_days_bare_ordinal_sorts_test() {
  ast.normalise_days(
    ast.BareOrdinalDays([ast.DayOfMonth(15), ast.LastDay, ast.DayOfMonth(1)]),
  )
  |> should.equal(
    ast.BareOrdinalDays([ast.LastDay, ast.DayOfMonth(1), ast.DayOfMonth(15)]),
  )
}

pub fn normalise_days_qualified_sorts_test() {
  ast.normalise_days(
    ast.QualifiedOrdinalDays([
      ast.NthWeekday(ast.Third, ast.Mon),
      ast.NthWeekday(ast.First, ast.Fri),
    ]),
  )
  |> should.equal(
    ast.QualifiedOrdinalDays([
      ast.NthWeekday(ast.First, ast.Fri),
      ast.NthWeekday(ast.Third, ast.Mon),
    ]),
  )
}

// --- normalise_times

pub fn normalise_times_at_sorts_test() {
  ast.normalise_times(
    ast.At([ast.Time(17, 0), ast.Time(9, 0), ast.Time(12, 0)]),
  )
  |> should.equal(ast.At([ast.Time(9, 0), ast.Time(12, 0), ast.Time(17, 0)]))
}

pub fn normalise_times_range_unchanged_test() {
  let range = ast.TimeRange(ast.Time(17, 0), ast.Time(9, 0))
  ast.normalise_times(range)
  |> should.equal(range)
}

// --- normalise_exclusion

pub fn normalise_exclusion_days_test() {
  ast.normalise_exclusion(ast.ExceptDays(ast.SpecificDays([ast.Fri, ast.Mon])))
  |> should.equal(ast.ExceptDays(ast.SpecificDays([ast.Mon, ast.Fri])))
}

pub fn normalise_exclusion_time_test() {
  ast.normalise_exclusion(
    ast.ExceptTime(ast.At([ast.Time(17, 0), ast.Time(9, 0)])),
  )
  |> should.equal(ast.ExceptTime(ast.At([ast.Time(9, 0), ast.Time(17, 0)])))
}

pub fn normalise_exclusion_bounds_unchanged_test() {
  let bounds =
    ast.ExceptBounds(ast.Between(
      ast.BoundPoint(ast.Date(2026, 6, 1), ast.midnight()),
      ast.BoundPoint(ast.Date(2026, 6, 30), ast.midnight()),
    ))
  ast.normalise_exclusion(bounds)
  |> should.equal(bounds)
}
