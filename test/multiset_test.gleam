import gleam/list
import gleeunit/should
import library/ast/multiset

// --- from_list / size

pub fn from_list_empty_test() {
  multiset.from_list([])
  |> multiset.size
  |> should.equal(0)
}

pub fn from_list_counts_duplicates_test() {
  multiset.from_list([1, 2, 2, 3, 3, 3])
  |> multiset.size
  |> should.equal(6)
}

pub fn from_list_no_duplicates_test() {
  multiset.from_list([1, 2, 3])
  |> multiset.size
  |> should.equal(3)
}

// --- has

pub fn has_present_test() {
  multiset.from_list([1, 2, 3])
  |> multiset.has(2)
  |> should.be_true
}

pub fn has_absent_test() {
  multiset.from_list([1, 2, 3])
  |> multiset.has(4)
  |> should.be_false
}

pub fn has_empty_test() {
  multiset.new()
  |> multiset.has(1)
  |> should.be_false
}

// --- find_duplicates

pub fn find_duplicates_none_test() {
  multiset.from_list([1, 2, 3])
  |> multiset.find_duplicates
  |> should.equal([])
}

pub fn find_duplicates_some_test() {
  let result =
    multiset.from_list([1, 1, 2, 3, 3])
    |> multiset.find_duplicates
  // dict key order is not guaranteed
  should.be_true(list.length(result) == 2)
  should.be_true(list.contains(result, 1))
  should.be_true(list.contains(result, 3))
}

pub fn find_duplicates_empty_test() {
  multiset.new()
  |> multiset.find_duplicates
  |> should.equal([])
}

// --- intersection

pub fn intersection_overlap_test() {
  let a = multiset.from_list([1, 2, 3])
  let b = multiset.from_list([2, 3, 4])
  let result = multiset.intersection(a, b)
  should.be_true(list.length(result) == 2)
  should.be_true(list.contains(result, 2))
  should.be_true(list.contains(result, 3))
}

pub fn intersection_disjoint_test() {
  let a = multiset.from_list([1, 2])
  let b = multiset.from_list([3, 4])
  multiset.intersection(a, b)
  |> should.equal([])
}

pub fn intersection_subset_test() {
  let a = multiset.from_list([1, 2, 3])
  let b = multiset.from_list([2])
  let result = multiset.intersection(a, b)
  should.equal(result, [2])
}

pub fn intersection_empty_left_test() {
  let a = multiset.new()
  let b = multiset.from_list([1, 2])
  multiset.intersection(a, b)
  |> should.equal([])
}

pub fn intersection_empty_right_test() {
  let a = multiset.from_list([1, 2])
  let b = multiset.new()
  multiset.intersection(a, b)
  |> should.equal([])
}

// --- eq

pub fn eq_same_order_test() {
  multiset.eq([1, 2, 3], [1, 2, 3])
  |> should.be_true
}

pub fn eq_different_order_test() {
  multiset.eq([3, 1, 2], [1, 2, 3])
  |> should.be_true
}

pub fn eq_different_elements_test() {
  multiset.eq([1, 2, 3], [1, 2, 4])
  |> should.be_false
}

pub fn eq_different_lengths_test() {
  multiset.eq([1, 2], [1, 2, 3])
  |> should.be_false
}

pub fn eq_both_empty_test() {
  multiset.eq([], [])
  |> should.be_true
}

pub fn eq_with_duplicates_test() {
  multiset.eq([1, 1, 2], [1, 2, 2])
  |> should.be_false
}

pub fn eq_same_duplicates_test() {
  multiset.eq([1, 1, 2], [2, 1, 1])
  |> should.be_true
}

// --- fold

pub fn fold_sum_counts_test() {
  multiset.from_list([1, 1, 2, 3, 3, 3])
  |> multiset.fold(0, fn(acc, _key, count) { acc + count })
  |> should.equal(6)
}

pub fn fold_collect_keys_test() {
  let result =
    multiset.from_list([1, 2, 3])
    |> multiset.fold([], fn(acc, key, _count) { [key, ..acc] })
  should.be_true(list.length(result) == 3)
  should.be_true(list.contains(result, 1))
  should.be_true(list.contains(result, 2))
  should.be_true(list.contains(result, 3))
}

pub fn fold_empty_test() {
  multiset.new()
  |> multiset.fold(0, fn(acc, _key, count) { acc + count })
  |> should.equal(0)
}
