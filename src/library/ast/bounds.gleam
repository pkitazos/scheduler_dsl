import gleam/order
import library/ast
import library/overlap

pub fn overlap_with(
  a: ast.Bounds,
  b: ast.Bounds,
) -> Result(overlap.Overlap(ast.Bounds), Nil) {
  case a, b {
    ast.Starting(s1), ast.Starting(s2) -> {
      case
        ast.compare_date(s1.date, s2.date),
        ast.compare_time(s1.time, s2.time)
      {
        order.Lt, _ -> Ok(overlap.Subset(smaller: a, bigger: b))
        order.Gt, _ -> Ok(overlap.Subset(smaller: b, bigger: a))
        order.Eq, order.Lt -> Ok(overlap.Subset(smaller: a, bigger: b))
        order.Eq, _ -> Ok(overlap.Subset(smaller: b, bigger: a))
      }
    }

    ast.Starting(starting), ast.Between(from, to) -> {
      case
        ast.compare_date(starting.date, from.date),
        ast.compare_date(starting.date, to.date)
      {
        order.Lt, _ -> Ok(overlap.Subset(smaller: b, bigger: a))

        order.Eq, _ -> {
          case ast.compare_time(from.time, starting.time) {
            order.Lt -> Ok(overlap.Subset(smaller: b, bigger: a))
            order.Eq -> Ok(overlap.Subset(smaller: b, bigger: a))
            order.Gt ->
              Ok(overlap.Intersection(a, b, ast.Between(from: starting, to: to)))
          }
        }

        order.Gt, order.Gt -> Ok(overlap.Disjoint)
        order.Gt, order.Lt ->
          Ok(overlap.Intersection(a, b, ast.Between(from: starting, to: to)))
        order.Gt, order.Eq -> {
          case ast.compare_time(starting.time, to.time) {
            order.Gt -> Ok(overlap.Disjoint)
            order.Lt ->
              Ok(overlap.Intersection(a, b, ast.Between(from: starting, to: to)))
            order.Eq ->
              // todo: not entirely true, they can be merged into one earlier starting date
              Ok(overlap.Disjoint)
          }
        }
      }
    }

    ast.Between(from, to), ast.Starting(starting) -> {
      case
        ast.compare_date(from.date, starting.date),
        ast.compare_date(to.date, starting.date)
      {
        order.Lt, order.Lt -> Ok(overlap.Disjoint)
        order.Lt, order.Eq ->
          // todo: not entirely true, they can be merged into one earlier starting date
          Ok(overlap.Disjoint)
        order.Lt, order.Gt ->
          Ok(overlap.Intersection(a, b, ast.Between(from: starting, to: to)))

        order.Gt, _ -> Ok(overlap.Subset(smaller: a, bigger: b))

        order.Eq, _ -> {
          case ast.compare_time(from.time, starting.time) {
            order.Lt ->
              Ok(overlap.Intersection(a, b, ast.Between(from: starting, to: to)))
            _ -> Ok(overlap.Subset(smaller: a, bigger: b))
          }
        }
      }
    }
    ast.Between(_, _), ast.Between(_, _) -> {
      case
        ast.compare_date(a.from.date, b.from.date),
        ast.compare_date(a.to.date, b.to.date)
      {
        order.Lt, order.Lt -> {
          case ast.compare_date(a.to.date, b.from.date) {
            order.Lt -> Ok(overlap.Disjoint)
            order.Eq ->
              // todo: not entirely true, they can be merged into one continuous range
              Ok(overlap.Disjoint)
            order.Gt ->
              Ok(overlap.Intersection(a, b, ast.Between(from: b.from, to: a.to)))
          }
        }
        order.Lt, _ -> Ok(overlap.Subset(smaller: b, bigger: a))

        order.Eq, order.Gt -> {
          case ast.compare_time(a.from.time, b.from.time) {
            order.Gt ->
              Ok(overlap.Intersection(a, b, ast.Between(from: a.from, to: b.to)))
            _ -> Ok(overlap.Subset(smaller: b, bigger: a))
          }
        }
        order.Eq, order.Lt -> {
          case ast.compare_time(a.from.time, b.from.time) {
            order.Gt ->
              Ok(overlap.Intersection(a, b, ast.Between(from: b.from, to: a.to)))
            _ -> Ok(overlap.Subset(smaller: a, bigger: b))
          }
        }
        order.Eq, order.Eq -> {
          // copied as-is from `timing.gleam`
          case
            ast.compare_time(a.from.time, b.from.time),
            ast.compare_time(a.to.time, b.to.time)
          {
            order.Lt, order.Gt -> Ok(overlap.Subset(smaller: b, bigger: a))
            order.Lt, order.Eq -> Ok(overlap.Subset(smaller: b, bigger: a))
            order.Eq, order.Gt -> Ok(overlap.Subset(smaller: b, bigger: a))

            order.Lt, order.Lt ->
              case ast.compare_time(b.from.time, a.to.time) {
                order.Lt ->
                  Ok(overlap.Intersection(
                    a,
                    b,
                    ast.Between(from: b.from, to: a.to),
                  ))
                _ -> Ok(overlap.Disjoint)
              }

            order.Gt, order.Gt ->
              case ast.compare_time(a.from.time, b.to.time) {
                order.Lt ->
                  Ok(overlap.Intersection(
                    a,
                    b,
                    ast.Between(from: a.from, to: b.to),
                  ))
                _ -> Ok(overlap.Disjoint)
              }
            order.Gt, order.Lt -> Ok(overlap.Subset(smaller: a, bigger: b))
            order.Gt, order.Eq -> Ok(overlap.Subset(smaller: a, bigger: b))
            order.Eq, order.Eq -> Ok(overlap.Subset(smaller: a, bigger: b))
            order.Eq, order.Lt -> Ok(overlap.Subset(smaller: a, bigger: b))
          }
        }
        order.Gt, order.Gt -> {
          case ast.compare_date(a.from.date, b.to.date) {
            order.Lt ->
              Ok(overlap.Intersection(a, b, ast.Between(from: a.from, to: b.to)))
            order.Gt -> Ok(overlap.Disjoint)
            order.Eq ->
              case ast.compare_time(a.from.time, b.to.time) {
                order.Lt ->
                  Ok(overlap.Intersection(
                    a,
                    b,
                    ast.Between(from: a.from, to: b.to),
                  ))
                order.Eq ->
                  // todo: not entirely true, they can be merged into one continuous range
                  Ok(overlap.Disjoint)
                order.Gt -> Ok(overlap.Disjoint)
              }
          }
        }
        order.Gt, order.Lt -> Ok(overlap.Subset(smaller: a, bigger: b))
        order.Gt, order.Eq -> {
          case ast.compare_time(a.from.time, b.to.time) {
            order.Gt ->
              Ok(overlap.Intersection(a, b, ast.Between(from: a.from, to: b.to)))
            _ -> Ok(overlap.Subset(smaller: a, bigger: b))
          }
        }
      }
    }
  }
}
