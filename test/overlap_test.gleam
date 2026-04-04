import gleeunit/should
import library/overlap

// --- Intersection

pub fn intersection_test() {
  overlap.intersection([1, 2, 3], [2, 3, 4])
  |> should.equal([2, 3])
}

pub fn intersection_subset_left_test() {
  overlap.intersection([1, 2, 3], [1, 2, 3, 4])
  |> should.equal([1, 2, 3])
}

pub fn intersection_subset_right_test() {
  overlap.intersection([1, 2, 3, 4], [2, 3, 4])
  |> should.equal([2, 3, 4])
}

pub fn intersection_equivalent_test() {
  overlap.intersection([1, 2, 3], [3, 2, 1])
  |> should.equal([3, 2, 1])
}

pub fn intersection_disjoint_test() {
  overlap.intersection([1, 2, 3], [4, 5, 6])
  |> should.equal([])
}

pub fn intersection_empty_left_test() {
  overlap.intersection([], [1, 2, 3])
  |> should.equal([])
}

pub fn intersection_empty_right_test() {
  overlap.intersection([1, 2, 3], [])
  |> should.equal([])
}

pub fn intersection_both_empty_test() {
  overlap.intersection([], [])
  |> should.equal([])
}

pub fn intersection_single_element_match_test() {
  overlap.intersection([1], [1])
  |> should.equal([1])
}

pub fn intersection_single_element_no_match_test() {
  overlap.intersection([1], [2])
  |> should.equal([])
}

// --- Set Overlap

pub fn overlap_intersection_test() {
  let a = [1, 2, 3]
  let b = [2, 3, 4]
  overlap.set_overlap(a, b)
  |> should.equal(overlap.Intersection(a, b, [2, 3]))
}

pub fn overlap_intersection_single_shared_test() {
  let a = [1, 2]
  let b = [2, 3]
  overlap.set_overlap(a, b)
  |> should.equal(overlap.Intersection(a, b, [2]))
}

pub fn overlap_subset_left_test() {
  let a = [1, 2, 3]
  let b = [1, 2, 3, 4]
  overlap.set_overlap(a, b)
  |> should.equal(overlap.Subset(smaller: a, bigger: b))
}

pub fn overlap_subset_right_test() {
  let a = [1, 2, 3, 4]
  let b = [2, 3, 4]
  overlap.set_overlap(a, b)
  |> should.equal(overlap.Subset(smaller: b, bigger: a))
}

pub fn overlap_subset_single_in_many_test() {
  overlap.set_overlap([1, 2, 3], [2])
  |> should.equal(overlap.Subset(smaller: [2], bigger: [1, 2, 3]))
}

pub fn overlap_subset_many_contains_single_test() {
  overlap.set_overlap([2], [1, 2, 3])
  |> should.equal(overlap.Subset(smaller: [2], bigger: [1, 2, 3]))
}

// equal sets: xs is treated as the "smaller" by convention
pub fn overlap_equivalent_test() {
  let a = [1, 2, 3]
  let b = [3, 2, 1]
  overlap.set_overlap(a, b)
  |> should.equal(overlap.Subset(smaller: a, bigger: b))
}

pub fn overlap_disjoint_test() {
  overlap.set_overlap([1, 2, 3], [4, 5, 6])
  |> should.equal(overlap.Disjoint)
}

pub fn overlap_disjoint_single_elements_test() {
  overlap.set_overlap([1], [2])
  |> should.equal(overlap.Disjoint)
}

pub fn overlap_empty_left_test() {
  overlap.set_overlap([], [1, 2, 3])
  |> should.equal(overlap.Disjoint)
}

pub fn overlap_empty_right_test() {
  overlap.set_overlap([1, 2, 3], [])
  |> should.equal(overlap.Disjoint)
}

pub fn overlap_both_empty_test() {
  overlap.set_overlap([], [])
  |> should.equal(overlap.Disjoint)
}

// --- Overlap fmap

type Box(a) {
  Box(a)
}

pub fn fmap_subset_test() {
  overlap.set_overlap([1, 2], [1, 2, 3])
  |> overlap.overlap_fmap(Box)
  |> should.equal(overlap.Subset(smaller: Box([1, 2]), bigger: Box([1, 2, 3])))
}

pub fn fmap_intersection_test() {
  let a = [1, 2, 3]
  let b = [2, 3, 4]
  overlap.set_overlap(a, b)
  |> overlap.overlap_fmap(Box)
  |> should.equal(overlap.Intersection(Box(a), Box(b), Box([2, 3])))
}

pub fn fmap_disjoint_test() {
  overlap.set_overlap([1], [2])
  |> overlap.overlap_fmap(Box)
  |> should.equal(overlap.Disjoint)
}

pub fn fmap_adjacent_test() {
  overlap.Adjacent([1, 2], [3, 4], [1, 2, 3, 4])
  |> overlap.overlap_fmap(Box)
  |> should.equal(overlap.Adjacent(
    Box([1, 2]),
    Box([3, 4]),
    Box([1, 2, 3, 4]),
  ))
}
