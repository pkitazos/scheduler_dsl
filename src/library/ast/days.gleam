import gleam/int
import gleam/list
import gleam/order
import library/ast
import library/utils.{intersection}

pub fn weekdays() {
  [ast.Mon, ast.Tue, ast.Wed, ast.Thu, ast.Fri]
}

pub fn weekend() {
  [ast.Sat, ast.Sun]
}

/// Comparator for sorting day variants by specificity (Weekdays > Weekends > SpecificDays > OrdinalDays).
pub fn sort_days(a: ast.Days, b: ast.Days) -> order.Order {
  case a, b {
    ast.Weekdays, ast.Weekdays -> order.Eq
    ast.Weekdays, _ -> order.Gt

    ast.Weekends, ast.Weekdays -> order.Lt
    ast.Weekends, ast.Weekends -> order.Eq
    ast.Weekends, _ -> order.Gt

    ast.SpecificDays(_), ast.OrdinalDays(_) -> order.Gt
    ast.SpecificDays(d1), ast.SpecificDays(d2) ->
      int.compare(list.length(d1), list.length(d2))
    ast.SpecificDays(_), _ -> order.Lt

    ast.OrdinalDays(d1), ast.OrdinalDays(d2) ->
      int.compare(list.length(d1), list.length(d2))
    ast.OrdinalDays(_), _ -> order.Lt
  }
}

/// Comparator for sorting days of the week in calendar order (Mon > Tue > ... > Sun).
pub fn sort_days_of_week(a: ast.DayOfWeek, b: ast.DayOfWeek) -> order.Order {
  case a, b {
    ast.Mon, ast.Mon -> order.Eq
    ast.Mon, _ -> order.Gt

    ast.Tue, ast.Mon -> order.Lt
    ast.Tue, ast.Tue -> order.Eq
    ast.Tue, _ -> order.Gt

    ast.Wed, ast.Mon | ast.Wed, ast.Tue -> order.Lt
    ast.Wed, ast.Wed -> order.Eq
    ast.Wed, _ -> order.Gt

    ast.Thu, ast.Mon | ast.Thu, ast.Tue | ast.Thu, ast.Wed -> order.Lt
    ast.Thu, ast.Thu -> order.Eq
    ast.Thu, _ -> order.Gt

    ast.Fri, ast.Mon | ast.Fri, ast.Tue | ast.Fri, ast.Wed | ast.Fri, ast.Thu ->
      order.Lt
    ast.Fri, ast.Fri -> order.Eq
    ast.Fri, _ -> order.Gt

    ast.Sat, ast.Sun -> order.Gt
    ast.Sat, ast.Sat -> order.Eq
    ast.Sat, _ -> order.Lt

    ast.Sun, ast.Sun -> order.Eq
    ast.Sun, _ -> order.Lt
  }
}

pub type Containment {
  FullyContained
  PartiallyContained
  NoOverlap
  NeedContext
}

pub fn overlap_with(d1: List(ast.DayOfWeek), d2: List(ast.DayOfWeek)) {
  // io.println("d1:\n" <> string.inspect(d1))
  // io.println("\nd2:\n" <> string.inspect(d2))
  case intersection(d1, d2) {
    [] -> NoOverlap
    overlap -> {
      // io.println("overlappin:\n" <> string.inspect(overlap))

      // if there is overlap
      // and the overlap is the entire length of d1,
      // then it is fully contained
      // otherwise it is partially contained
      case list.length(overlap) == list.length(d1) {
        False -> PartiallyContained
        True -> FullyContained
      }
    }
  }
}
