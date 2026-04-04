import gleam/function.{identity as id}
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should
import library/utils

// --- ensure

pub fn ensure_predicate_passes_test() {
  utils.ensure(5, fn(n) { n > 0 }, "must be positive")
  |> should.equal(Ok(5))
}

pub fn ensure_predicate_fails_test() {
  utils.ensure(-1, fn(n) { n > 0 }, "must be positive")
  |> should.equal(Error("must be positive"))
}

// --- option_try

pub fn option_try_none_test() {
  utils.option_try(None, fn(_) { Ok(1) })
  |> should.equal(Ok(None))
}

pub fn option_try_some_ok_test() {
  utils.option_try(Some(5), fn(n) { Ok(n * 2) })
  |> should.equal(Ok(Some(10)))
}

pub fn option_try_some_error_test() {
  utils.option_try(Some(5), fn(_) { Error("fail") })
  |> should.equal(Error("fail"))
}

// --- options_symmetric

pub fn options_symmetric_both_some_test() {
  utils.options_symmetric(Some(1), Some("a"), "mismatch")
  |> should.equal(Ok(Nil))
}

pub fn options_symmetric_both_none_test() {
  utils.options_symmetric(None, None, "mismatch")
  |> should.equal(Ok(Nil))
}

pub fn options_symmetric_some_none_test() {
  utils.options_symmetric(Some(1), None, "mismatch")
  |> should.equal(Error("mismatch"))
}

pub fn options_symmetric_none_some_test() {
  utils.options_symmetric(None, Some(1), "mismatch")
  |> should.equal(Error("mismatch"))
}

// --- find_duplicates

pub fn find_duplicates_none_test() {
  utils.find_duplicates([1, 2, 3], id)
  |> should.equal([])
}

pub fn find_duplicates_one_test() {
  utils.find_duplicates([1, 2, 2], id)
  |> should.equal([2])
}

pub fn find_duplicates_multiple_test() {
  let result = utils.find_duplicates([1, 1, 2, 2, 3], id)
  should.be_true(result == [1, 2] || result == [2, 1])
}

pub fn find_duplicates_empty_test() {
  utils.find_duplicates([], id)
  |> should.equal([])
}

pub fn find_duplicates_with_key_fn_test() {
  utils.find_duplicates(["Hello", "HELLO"], string.lowercase)
  |> should.equal(["hello"])
}

// --- no_duplicates

pub fn no_duplicates_ok_test() {
  utils.no_duplicates([1, 2, 3], id, id)
  |> should.equal(Ok([1, 2, 3]))
}

pub fn no_duplicates_error_test() {
  utils.no_duplicates([1, 2, 2], id, id)
  |> should.equal(Error([2]))
}

pub fn no_duplicates_empty_test() {
  utils.no_duplicates([], id, id)
  |> should.equal(Ok([]))
}
