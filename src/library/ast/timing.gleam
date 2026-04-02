import gleam/order
import library/ast
import library/overlap.{overlap_fmap, set_overlap}

/// Computes the overlap between two `Timing` values of the same variant.
///
/// For `At` lists, delegates to `set_overlap` for element-wise comparison.
///
/// For `TimeRange` pairs, compares the `from` and `to` endpoints:
///
///     [a] ----------         Subset(b, a)  - a starts earlier, ends later/same
///     [b]    ----
///
///     [a] ------             Intersection  - a starts earlier, ends earlier
///     [b]      ------        (overlap region: from2..to1)
///
///     [a]      ------        Intersection  - a starts later, ends later
///     [b] ------             (overlap region: from1..to2)
///
///     [a]    ----            Subset(a, b)  - b starts earlier, ends later/same
///     [b] ----------
///
///     [a] ------             Subset(a, b)  - equal ranges (a treated as smaller)
///     [b] ------
///
/// When ranges don't touch (e.g. 09:00-10:00 vs 11:00-12:00), returns `Disjoint`.
///
/// Returns `Error(Nil)` for mismatched variants (At vs TimeRange).
pub fn overlap_with(
  a: ast.Timing,
  b: ast.Timing,
) -> Result(overlap.Overlap(ast.Timing), Nil) {
  case a, b {
    ast.At(t1), ast.At(t2) -> {
      set_overlap(t1, t2)
      |> overlap_fmap(ast.At)
      |> Ok()
    }
    ast.TimeRange(from1, to1), ast.TimeRange(from2, to2) -> {
      case ast.compare_time(from1, from2), ast.compare_time(to1, to2) {
        order.Lt, order.Gt -> Ok(overlap.Subset(smaller: b, bigger: a))
        order.Lt, order.Eq -> Ok(overlap.Subset(smaller: b, bigger: a))
        order.Eq, order.Gt -> Ok(overlap.Subset(smaller: b, bigger: a))

        order.Lt, order.Lt ->
          case ast.compare_time(from2, to1) {
            order.Lt ->
              Ok(overlap.Intersection(a, b, ast.TimeRange(from2, to1)))
            _ -> Ok(overlap.Disjoint)
          }

        order.Gt, order.Gt ->
          case ast.compare_time(from1, to2) {
            order.Lt ->
              Ok(overlap.Intersection(a, b, ast.TimeRange(from1, to2)))
            _ -> Ok(overlap.Disjoint)
          }
        order.Gt, order.Lt -> Ok(overlap.Subset(smaller: a, bigger: b))
        order.Gt, order.Eq -> Ok(overlap.Subset(smaller: a, bigger: b))
        order.Eq, order.Eq -> Ok(overlap.Subset(smaller: a, bigger: b))
        order.Eq, order.Lt -> Ok(overlap.Subset(smaller: a, bigger: b))
      }
    }
    _, _ -> Error(Nil)
  }
}
