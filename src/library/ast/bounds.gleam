import gleam/order
import library/ast
import library/overlap

/// Computes the overlap between two `Bounds` values.
///
/// `Starting/Starting` - two open-ended ranges always overlap:
///
///     [a] s1 --------->         Subset(a, b) - a starts earlier/same
///     [b]    s2 ------>         (the earlier start is the "bigger" range)
///
/// `Starting/Between` (and mirror) - open-ended vs bounded:
///
///     [a] s ---------->         Subset(b, a)   - starting before/at from
///     [b]   [from, to]
///
///     [a]      s ----->         Intersection   - starting within range
///     [b]   [from, to]
///
///     [a]            s->        Disjoint       - starting after to
///     [b]   [from, to]
///
/// `Between/Between` - same logic as `TimeRange` overlap in `timing.gleam`:
///
///     [a] [-----------]         Subset(b, a)  - a starts earlier, ends later/same
///     [b]    [-----]
///
///     [a] [------]              Intersection  - a starts earlier, ends earlier
///     [b]      [------]         (overlap region: b.from..a.to)
///
///     [a]    [-----]            Subset(a, b)  - b starts earlier, ends later/same
///     [b] [-----------]
///
///     [a] [------]              Subset(a, b)  - equal ranges
///     [b] [------]
///
/// Adjacent bounds (endpoints touch with Eq) return `Adjacent(a, b, shared)`
/// where `shared` is a zero-width `Between` at the meeting point. Four paths:
///   1. Starting/Between:  starting == to
///   2. Between/Starting:  to == starting
///   3. Between/Between:   b.from == a.to
///   4. Between/Between:   a.from == b.to
pub fn overlap_with(a: ast.Bounds, b: ast.Bounds) -> overlap.Overlap(ast.Bounds) {
  case a, b {
    ast.Starting(s1), ast.Starting(s2) -> {
      case ast.compare_bound_point(s1, s2) {
        order.Gt -> overlap.Subset(smaller: b, bigger: a)
        _ -> overlap.Subset(smaller: a, bigger: b)
      }
    }

    ast.Starting(starting), ast.Between(from, to) -> {
      case
        ast.compare_bound_point(starting, from),
        ast.compare_bound_point(starting, to)
      {
        order.Gt, order.Lt ->
          overlap.Intersection(a, b, ast.Between(from: starting, to: to))
        order.Gt, order.Eq ->
          overlap.Adjacent(a, b, ast.Between(from: starting, to: to))
        order.Gt, order.Gt -> overlap.Disjoint
        _, _ -> overlap.Subset(smaller: b, bigger: a)
      }
    }

    ast.Between(from, to), ast.Starting(starting) -> {
      case
        ast.compare_bound_point(from, starting),
        ast.compare_bound_point(to, starting)
      {
        order.Lt, order.Gt ->
          overlap.Intersection(a, b, ast.Between(from: starting, to: to))
        order.Lt, order.Eq ->
          overlap.Adjacent(a, b, ast.Between(from: starting, to: to))
        order.Lt, order.Lt -> overlap.Disjoint
        _, _ -> overlap.Subset(smaller: a, bigger: b)
      }
    }

    ast.Between(_, _), ast.Between(_, _) -> {
      case
        ast.compare_bound_point(a.from, b.from),
        ast.compare_bound_point(a.to, b.to)
      {
        order.Lt, order.Lt ->
          case ast.compare_bound_point(b.from, a.to) {
            order.Lt ->
              overlap.Intersection(a, b, ast.Between(from: b.from, to: a.to))
            order.Eq ->
              overlap.Adjacent(a, b, ast.Between(from: b.from, to: a.to))
            order.Gt -> overlap.Disjoint
          }
        order.Lt, _ -> overlap.Subset(smaller: b, bigger: a)

        order.Gt, order.Gt ->
          case ast.compare_bound_point(a.from, b.to) {
            order.Lt ->
              overlap.Intersection(a, b, ast.Between(from: a.from, to: b.to))
            order.Eq ->
              overlap.Adjacent(a, b, ast.Between(from: a.from, to: b.to))
            order.Gt -> overlap.Disjoint
          }
        order.Gt, _ -> overlap.Subset(smaller: a, bigger: b)

        order.Eq, order.Gt -> overlap.Subset(smaller: b, bigger: a)
        order.Eq, _ -> overlap.Subset(smaller: a, bigger: b)
      }
    }
  }
}
