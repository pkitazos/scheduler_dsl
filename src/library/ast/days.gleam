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

pub type Overlap(a) {
  Subset(List(a), List(a))
  Intersection(List(a), List(a), List(a))
  Disjoint
  Indeterminate
}

pub fn overlap_with(
  d1: List(ast.DayOfWeek),
  d2: List(ast.DayOfWeek),
) -> Overlap(ast.DayOfWeek) {
  // io.println("d1:\n" <> string.inspect(d1))
  // io.println("\nd2:\n" <> string.inspect(d2))
  case intersection(d1, d2) {
    [] -> Disjoint
    overlap -> {
      // io.println("overlappin:\n" <> string.inspect(overlap))

      // if there is overlap
      // and the overlap is the entire length of d1,
      // then it is fully contained
      // otherwise it is partially contained
      case list.length(overlap) == list.length(d1) {
        False -> Intersection(d1, d2, overlap)
        True -> Subset(d1, d2)
      }
    }
  }
}
