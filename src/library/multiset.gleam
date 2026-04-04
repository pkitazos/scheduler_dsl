import gleam/dict
import gleam/list
import gleam/option
import gleam/result

/// A bag/multiset: tracks elements with their occurrence counts.
pub opaque type Multiset(a) {
  Multiset(dict.Dict(a, Int))
}

/// Creates an empty multiset.
pub fn new() -> Multiset(a) {
  Multiset(dict.new())
}

/// Creates a multiset from a list, counting occurrences of each element.
pub fn from_list(list: List(a)) -> Multiset(a) {
  list
  |> list.fold(dict.new(), fn(d, x) { dict.upsert(d, x, increment) })
  |> Multiset()
}

/// Returns elements that appear more than once in the multiset.
pub fn find_duplicates(xs: Multiset(a)) -> List(a) {
  let Multiset(dict) = xs
  dict
  |> dict.filter(fn(_, value) { value > 1 })
  |> dict.keys
}

/// Returns elements present in both multisets.
pub fn intersection(xs: Multiset(a), ys: Multiset(a)) -> List(a) {
  let set = {
    use acc, key, _ <- fold(xs, [])

    case has(ys, key) {
      True -> [key, ..acc]
      False -> acc
    }
  }

  set |> list.reverse
}

/// Folds over each distinct element and its count.
pub fn fold(xs: Multiset(a), init: b, f: fn(b, a, Int) -> b) -> b {
  let Multiset(xs) = xs
  dict.fold(xs, init, f)
}

/// Checks whether the multiset contains the given element.
pub fn has(xs: Multiset(a), item: a) -> Bool {
  let Multiset(xs) = xs
  dict.has_key(xs, item)
}

/// Returns the total number of elements (counting duplicates).
pub fn size(xs: Multiset(a)) -> Int {
  let Multiset(xs) = xs
  xs |> dict.values() |> list.reduce(fn(a, b) { a + b }) |> result.unwrap(0)
}

/// Compares two lists as multisets (order-insensitive, count-sensitive).
pub fn eq(xs: List(a), ys: List(a)) -> Bool {
  from_list(xs) == from_list(ys)
}

// ----

fn increment(opt: option.Option(Int)) -> Int {
  option.unwrap(opt, 0) + 1
}
