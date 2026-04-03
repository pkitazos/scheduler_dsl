import gleam/list
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
pub fn overlap_with(a: ast.Timing, b: ast.Timing) -> overlap.Overlap(ast.Timing) {
  // todo: assumes ranges are from < to, since we support wrap-around time ranges this isn't true
  case a, b {
    ast.At(t1), ast.At(t2) -> {
      set_overlap(t1, t2)
      |> overlap_fmap(ast.At)
    }

    ast.TimeRange(from1, to1), ast.TimeRange(from2, to2) -> {
      case ast.compare_time(from1, from2), ast.compare_time(to1, to2) {
        order.Lt, order.Gt -> overlap.Subset(smaller: b, bigger: a)
        order.Lt, order.Eq -> overlap.Subset(smaller: b, bigger: a)
        order.Eq, order.Gt -> overlap.Subset(smaller: b, bigger: a)

        order.Lt, order.Lt ->
          case ast.compare_time(from2, to1) {
            order.Lt -> overlap.Intersection(a, b, ast.TimeRange(from2, to1))
            _ -> overlap.Disjoint
          }

        order.Gt, order.Gt ->
          case ast.compare_time(from1, to2) {
            order.Lt -> overlap.Intersection(a, b, ast.TimeRange(from1, to2))
            _ -> overlap.Disjoint
          }
        order.Gt, order.Lt -> overlap.Subset(smaller: a, bigger: b)
        order.Gt, order.Eq -> overlap.Subset(smaller: a, bigger: b)
        order.Eq, order.Eq -> overlap.Subset(smaller: a, bigger: b)
        order.Eq, order.Lt -> overlap.Subset(smaller: a, bigger: b)
      }
    }

    ast.At(times), ast.TimeRange(from, to) -> {
      let inside =
        list.filter(times, fn(time) {
          case ast.compare_time(time, from), ast.compare_time(time, to) {
            order.Lt, _ | _, order.Gt -> False
            _, _ -> True
          }
        })

      case inside, list.length(inside) == list.length(times) {
        [], _ -> overlap.Disjoint
        _, True -> overlap.Subset(smaller: a, bigger: b)
        xs, False -> overlap.Intersection(a, b, ast.At(xs))
      }
    }

    ast.TimeRange(from, to), ast.At(times:) -> {
      let inside =
        list.filter(times, fn(time) {
          case ast.compare_time(time, from), ast.compare_time(time, to) {
            order.Lt, _ | _, order.Gt -> False
            _, _ -> True
          }
        })

      case inside, list.length(inside) == list.length(times) {
        [], _ -> overlap.Disjoint
        _, True -> overlap.Subset(smaller: b, bigger: a)
        xs, False -> overlap.Intersection(a, b, ast.At(xs))
      }
    }
  }
}
