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

/// Compares two `Days` values and determines their set-theoretic relationship.
///
/// Returns `Ok(Subset(a, b))` when `a` is a proper subset of `b`,
/// `Ok(Intersection(a, b, shared))` when they partially overlap,
/// `Ok(Disjoint)` when they share nothing, or `Error(Nil)` when
/// the two values are of different `Days` variants (e.g. `SpecificDays`
/// vs `OrdinalDays`), since cross-variant comparison is not meaningful.
///
/// The original `ast.Days` values are preserved in the result so that
/// error messages can refer to what the user actually wrote.
///
/// Assumes all inner lists have already been de-duplicated upstream.
pub fn overlap_with(a: ast.Days, b: ast.Days) -> Result(Overlap(ast.Days), Nil) {
  case a, b {
    ast.SpecificDays(d1), ast.SpecificDays(d2) -> {
      set_overlap(d1, d2)
      |> overlap_fmap(ast.SpecificDays)
      |> Ok()
    }
    ast.OrdinalDays(d1), ast.OrdinalDays(d2) -> {
      set_overlap(d1, d2)
      |> overlap_fmap(ast.OrdinalDays)
      |> Ok()
    }
    _, _ -> Error(Nil)
  }
}

pub type Overlap(a) {
  Subset(a, a)
  Intersection(a, a, a)
  Disjoint
}

/// Transforms the inner type of an `Overlap` value while preserving
/// its structure
fn overlap_fmap(
  x: Overlap(List(a)),
  f: fn(List(a)) -> ast.Days,
) -> Overlap(ast.Days) {
  case x {
    Subset(a, b) -> Subset(f(a), f(b))
    Intersection(a, b, c) -> Intersection(f(a), f(b), f(c))
    Disjoint -> Disjoint
  }
}

/// Computes the set-theoretic relationship between two lists using
/// structural equality. Returns `Subset` when the first list is
/// entirely contained in the second, `Intersection` when they share
/// some but not all elements, or `Disjoint` when they share nothing.
///
/// Assumes both lists have been de-duplicated.
pub fn set_overlap(xs: List(a), ys: List(a)) -> Overlap(List(a)) {
  case intersection(xs, ys) {
    [] -> Disjoint
    overlap ->
      // if there is overlap
      // and the overlap is the entire length of d1,
      // then it is a strict subset
      // otherwise they just have a non-empty intersection set
      case list.length(overlap) == list.length(xs) {
        False -> Intersection(xs, ys, overlap)
        True -> Subset(xs, ys)
      }
  }
}
