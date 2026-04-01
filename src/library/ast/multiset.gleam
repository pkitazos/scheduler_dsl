import gleam/dict
import gleam/list
import gleam/option
import gleam/result

pub opaque type Multiset(a) {
  Multiset(dict.Dict(a, Int))
}

pub fn new() -> Multiset(a) {
  Multiset(dict.new())
}

pub fn from_list(list: List(a)) -> Multiset(a) {
  list
  |> list.fold(dict.new(), fn(d, x) { dict.upsert(d, x, increment) })
  |> Multiset()
}

/// Returns elements that appear multiple times in a list
pub fn find_duplicates(xs: Multiset(a)) -> List(a) {
  let Multiset(dict) = xs
  dict
  |> dict.filter(fn(_, value) { value > 1 })
  |> dict.keys
}

/// Returns the intersection of two lists
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

pub fn fold(xs: Multiset(a), init: b, f: fn(b, a, Int) -> b) -> b {
  let Multiset(xs) = xs
  dict.fold(xs, init, f)
}

pub fn has(xs: Multiset(a), item: a) -> Bool {
  let Multiset(xs) = xs
  dict.has_key(xs, item)
}

pub fn size(xs: Multiset(a)) -> Int {
  let Multiset(xs) = xs
  xs |> dict.values() |> list.reduce(fn(a, b) { a + b }) |> result.unwrap(0)
}

pub fn eq(xs: List(a), ys: List(a)) -> Bool {
  from_list(xs) == from_list(ys)
}

// ----

fn increment(opt: option.Option(Int)) -> Int {
  option.unwrap(opt, 0) + 1
}
