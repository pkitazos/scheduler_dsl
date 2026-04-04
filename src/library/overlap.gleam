import gleam/list

pub type Overlap(a) {
  Subset(smaller: a, bigger: a)
  Intersection(a, a, a)
  Disjoint
  Adjacent(a, a, a)
}

/// Transforms the inner type of an `Overlap` value while preserving
/// its structure
pub fn overlap_fmap(x: Overlap(List(a)), f: fn(List(a)) -> b) -> Overlap(b) {
  case x {
    Subset(a, b) -> Subset(f(a), f(b))
    Intersection(a, b, c) -> Intersection(f(a), f(b), f(c))
    Disjoint -> Disjoint
    Adjacent(a, b, c) -> Adjacent(f(a), f(b), f(c))
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
      case
        list.length(overlap) == list.length(xs),
        list.length(overlap) == list.length(ys)
      {
        False, False -> Intersection(xs, ys, overlap)
        False, True -> Subset(ys, xs)
        True, _ -> Subset(xs, ys)
      }
  }
}

/// Returns the intersection of two lists
pub fn intersection(xs: List(a), ys: List(a)) -> List(a) {
  list.filter(ys, fn(y) { list.contains(xs, y) })
}
