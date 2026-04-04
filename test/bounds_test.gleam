import gleeunit/should
import library/ast
import library/ast/bounds
import library/overlap

fn bp(year: Int, month: Int, day: Int) -> ast.BoundPoint {
  ast.BoundPoint(ast.Date(year, month, day), ast.midnight())
}

// --- Starting / Starting

pub fn starting_starting_a_earlier_test() {
  let a = ast.Starting(bp(2026, 1, 1))
  let b = ast.Starting(bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Subset(smaller: a, bigger: b))
}

pub fn starting_starting_b_earlier_test() {
  let a = ast.Starting(bp(2026, 6, 1))
  let b = ast.Starting(bp(2026, 1, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Subset(smaller: b, bigger: a))
}

pub fn starting_starting_equal_test() {
  let a = ast.Starting(bp(2026, 1, 1))
  bounds.overlap_with(a, a)
  |> should.equal(overlap.Subset(smaller: a, bigger: a))
}

// --- Starting / Between

pub fn starting_between_before_from_test() {
  // starting before the range → between is subset of starting
  let a = ast.Starting(bp(2026, 1, 1))
  let b = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Subset(smaller: b, bigger: a))
}

pub fn starting_between_at_from_test() {
  // starting exactly at from → between is subset of starting
  let a = ast.Starting(bp(2026, 3, 1))
  let b = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Subset(smaller: b, bigger: a))
}

pub fn starting_between_within_test() {
  // starting within the range → intersection
  let a = ast.Starting(bp(2026, 4, 1))
  let b = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Intersection(
    a,
    b,
    ast.Between(bp(2026, 4, 1), bp(2026, 6, 1)),
  ))
}

pub fn starting_between_at_to_test() {
  // starting exactly at to → adjacent
  let a = ast.Starting(bp(2026, 6, 1))
  let b = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Adjacent(
    a,
    b,
    ast.Between(bp(2026, 6, 1), bp(2026, 6, 1)),
  ))
}

pub fn starting_between_after_to_test() {
  // starting after the range → disjoint
  let a = ast.Starting(bp(2026, 7, 1))
  let b = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Disjoint)
}

// --- Between / Starting (mirror)

pub fn between_starting_after_to_test() {
  // starting after the range → disjoint
  let a = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  let b = ast.Starting(bp(2026, 7, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Disjoint)
}

pub fn between_starting_within_test() {
  // starting within → intersection
  let a = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  let b = ast.Starting(bp(2026, 4, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Intersection(
    a,
    b,
    ast.Between(bp(2026, 4, 1), bp(2026, 6, 1)),
  ))
}

pub fn between_starting_at_to_test() {
  // starting exactly at to → adjacent
  let a = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  let b = ast.Starting(bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Adjacent(
    a,
    b,
    ast.Between(bp(2026, 6, 1), bp(2026, 6, 1)),
  ))
}

pub fn between_starting_before_from_test() {
  // starting before from → between is subset of starting
  let a = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  let b = ast.Starting(bp(2026, 1, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Subset(smaller: a, bigger: b))
}

// --- Between / Between

pub fn between_disjoint_test() {
  let a = ast.Between(bp(2026, 1, 1), bp(2026, 3, 1))
  let b = ast.Between(bp(2026, 6, 1), bp(2026, 9, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Disjoint)
}

pub fn between_disjoint_reversed_test() {
  let a = ast.Between(bp(2026, 6, 1), bp(2026, 9, 1))
  let b = ast.Between(bp(2026, 1, 1), bp(2026, 3, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Disjoint)
}

pub fn between_a_contains_b_test() {
  let a = ast.Between(bp(2026, 1, 1), bp(2026, 12, 1))
  let b = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Subset(smaller: b, bigger: a))
}

pub fn between_b_contains_a_test() {
  let a = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  let b = ast.Between(bp(2026, 1, 1), bp(2026, 12, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Subset(smaller: a, bigger: b))
}

pub fn between_equal_test() {
  let a = ast.Between(bp(2026, 3, 1), bp(2026, 6, 1))
  bounds.overlap_with(a, a)
  |> should.equal(overlap.Subset(smaller: a, bigger: a))
}

pub fn between_same_start_a_longer_test() {
  let a = ast.Between(bp(2026, 1, 1), bp(2026, 9, 1))
  let b = ast.Between(bp(2026, 1, 1), bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Subset(smaller: b, bigger: a))
}

pub fn between_same_end_b_starts_earlier_test() {
  let a = ast.Between(bp(2026, 3, 1), bp(2026, 9, 1))
  let b = ast.Between(bp(2026, 1, 1), bp(2026, 9, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Subset(smaller: a, bigger: b))
}

pub fn between_intersection_a_first_test() {
  let a = ast.Between(bp(2026, 1, 1), bp(2026, 6, 1))
  let b = ast.Between(bp(2026, 4, 1), bp(2026, 9, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Intersection(
    a,
    b,
    ast.Between(bp(2026, 4, 1), bp(2026, 6, 1)),
  ))
}

pub fn between_intersection_b_first_test() {
  let a = ast.Between(bp(2026, 4, 1), bp(2026, 9, 1))
  let b = ast.Between(bp(2026, 1, 1), bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Intersection(
    a,
    b,
    ast.Between(bp(2026, 4, 1), bp(2026, 6, 1)),
  ))
}

pub fn between_adjacent_a_first_test() {
  let a = ast.Between(bp(2026, 1, 1), bp(2026, 6, 1))
  let b = ast.Between(bp(2026, 6, 1), bp(2026, 9, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Adjacent(
    a,
    b,
    ast.Between(bp(2026, 6, 1), bp(2026, 6, 1)),
  ))
}

pub fn between_adjacent_b_first_test() {
  let a = ast.Between(bp(2026, 6, 1), bp(2026, 9, 1))
  let b = ast.Between(bp(2026, 1, 1), bp(2026, 6, 1))
  bounds.overlap_with(a, b)
  |> should.equal(overlap.Adjacent(
    a,
    b,
    ast.Between(bp(2026, 6, 1), bp(2026, 6, 1)),
  ))
}
