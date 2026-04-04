import gleam/dict
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// Wraps a clause in a Result if it satisfies a predicate.
pub fn ensure(clause: a, f: fn(a) -> Bool, b) -> Result(a, b) {
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

pub fn no_duplicates(
  xs: List(a),
  key: fn(a) -> a,
  err_f: fn(List(a)) -> b,
) -> Result(List(a), b) {
  case find_duplicates(xs, key) {
    [] -> Ok(xs)
    dups -> Error(err_f(dups))
  }
}

/// Returns elements that appear multiple times in a list
pub fn find_duplicates(xs: List(a), key: fn(a) -> a) -> List(a) {
  xs
  |> list.fold(dict.new(), fn(acc, x) {
    dict.upsert(acc, key(x), fn(count) { option.unwrap(count, 0) + 1 })
  })
  |> dict.filter(fn(_, value) { value > 1 })
  |> dict.keys
}

pub fn debug(thing: a) {
  io.println("\n" <> string.inspect(thing))
}
