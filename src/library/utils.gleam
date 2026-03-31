import gleam/dict
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// Wraps a clause in a Result if it satisfies a predicate.
pub fn guard(clause: a, f: fn(a) -> Bool, b) -> Result(a, b) {
  case f(clause) {
    True -> Ok(clause)
    False -> Error(b)
  }
}

/// Apply a fallible function to an Option's inner value.
/// None passes through as Ok(None).
/// Some(a) becomes Ok(Some(a)) if f succeeds, or Error(e) if it fails.
pub fn option_try(
  opt: Option(a),
  f: fn(a) -> Result(b, e),
) -> Result(Option(b), e) {
  case opt {
    None -> Ok(None)
    Some(value) -> result.map(f(value), Some)
  }
}

/// Checks that two Options are both Some or both None.
pub fn options_symmetric(a: Option(a), b: Option(b), err: e) -> Result(Nil, e) {
  case a, b {
    Some(_), Some(_) | None, None -> Ok(Nil)
    _, _ -> Error(err)
  }
}

/// Returns elements that appear multiple times in a list
pub fn find_duplicates(xs: List(a)) -> List(a) {
  xs
  |> list.fold(dict.new(), fn(acc, x) {
    dict.upsert(acc, x, fn(count) { option.unwrap(count, 0) + 1 })
  })
  |> dict.filter(fn(_, value) { value > 1 })
  |> dict.keys
}

/// Returns the intersection of two lists
pub fn intersection(xs: List(a), ys: List(a)) -> List(a) {
  list.filter(ys, fn(y) { list.contains(xs, y) })
}

pub fn debug(thing: a) {
  io.println("\n" <> string.inspect(thing))
}
