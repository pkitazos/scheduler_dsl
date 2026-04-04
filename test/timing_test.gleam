import gleeunit/should
import library/ast
import library/ast/timing
import library/overlap

// --- At / At

pub fn at_disjoint_test() {
  timing.overlap_with(ast.At([ast.Time(9, 0)]), ast.At([ast.Time(17, 0)]))
  |> should.equal(overlap.Disjoint)
}

pub fn at_subset_test() {
  timing.overlap_with(
    ast.At([ast.Time(9, 0)]),
    ast.At([ast.Time(9, 0), ast.Time(12, 0)]),
  )
  |> should.equal(overlap.Subset(
    smaller: ast.At([ast.Time(9, 0)]),
    bigger: ast.At([ast.Time(9, 0), ast.Time(12, 0)]),
  ))
}

pub fn at_intersection_test() {
  timing.overlap_with(
    ast.At([ast.Time(9, 0), ast.Time(12, 0)]),
    ast.At([ast.Time(12, 0), ast.Time(17, 0)]),
  )
  |> should.equal(overlap.Intersection(
    ast.At([ast.Time(9, 0), ast.Time(12, 0)]),
    ast.At([ast.Time(12, 0), ast.Time(17, 0)]),
    ast.At([ast.Time(12, 0)]),
  ))
}

// --- TimeRange / TimeRange

pub fn range_disjoint_test() {
  timing.overlap_with(
    ast.TimeRange(ast.Time(9, 0), ast.Time(10, 0)),
    ast.TimeRange(ast.Time(11, 0), ast.Time(12, 0)),
  )
  |> should.equal(overlap.Disjoint)
}

pub fn range_disjoint_reversed_test() {
  timing.overlap_with(
    ast.TimeRange(ast.Time(11, 0), ast.Time(12, 0)),
    ast.TimeRange(ast.Time(9, 0), ast.Time(10, 0)),
  )
  |> should.equal(overlap.Disjoint)
}

pub fn range_subset_a_contains_b_test() {
  // a starts earlier, ends later
  timing.overlap_with(
    ast.TimeRange(ast.Time(8, 0), ast.Time(18, 0)),
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  )
  |> should.equal(overlap.Subset(
    smaller: ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    bigger: ast.TimeRange(ast.Time(8, 0), ast.Time(18, 0)),
  ))
}

pub fn range_subset_b_contains_a_test() {
  // b starts earlier, ends later
  timing.overlap_with(
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    ast.TimeRange(ast.Time(8, 0), ast.Time(18, 0)),
  )
  |> should.equal(overlap.Subset(
    smaller: ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    bigger: ast.TimeRange(ast.Time(8, 0), ast.Time(18, 0)),
  ))
}

pub fn range_subset_same_start_test() {
  // same start, a ends later
  timing.overlap_with(
    ast.TimeRange(ast.Time(9, 0), ast.Time(18, 0)),
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  )
  |> should.equal(overlap.Subset(
    smaller: ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    bigger: ast.TimeRange(ast.Time(9, 0), ast.Time(18, 0)),
  ))
}

pub fn range_subset_same_end_test() {
  // same end, a starts earlier
  timing.overlap_with(
    ast.TimeRange(ast.Time(8, 0), ast.Time(17, 0)),
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  )
  |> should.equal(overlap.Subset(
    smaller: ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    bigger: ast.TimeRange(ast.Time(8, 0), ast.Time(17, 0)),
  ))
}

pub fn range_equal_test() {
  // equal ranges: a treated as smaller by convention
  let r = ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0))
  timing.overlap_with(r, r)
  |> should.equal(overlap.Subset(smaller: r, bigger: r))
}

pub fn range_intersection_a_starts_earlier_test() {
  timing.overlap_with(
    ast.TimeRange(ast.Time(9, 0), ast.Time(14, 0)),
    ast.TimeRange(ast.Time(12, 0), ast.Time(17, 0)),
  )
  |> should.equal(overlap.Intersection(
    ast.TimeRange(ast.Time(9, 0), ast.Time(14, 0)),
    ast.TimeRange(ast.Time(12, 0), ast.Time(17, 0)),
    ast.TimeRange(ast.Time(12, 0), ast.Time(14, 0)),
  ))
}

pub fn range_intersection_b_starts_earlier_test() {
  timing.overlap_with(
    ast.TimeRange(ast.Time(12, 0), ast.Time(17, 0)),
    ast.TimeRange(ast.Time(9, 0), ast.Time(14, 0)),
  )
  |> should.equal(overlap.Intersection(
    ast.TimeRange(ast.Time(12, 0), ast.Time(17, 0)),
    ast.TimeRange(ast.Time(9, 0), ast.Time(14, 0)),
    ast.TimeRange(ast.Time(12, 0), ast.Time(14, 0)),
  ))
}

pub fn range_adjacent_a_first_test() {
  // a ends exactly where b starts
  timing.overlap_with(
    ast.TimeRange(ast.Time(9, 0), ast.Time(12, 0)),
    ast.TimeRange(ast.Time(12, 0), ast.Time(17, 0)),
  )
  |> should.equal(overlap.Adjacent(
    ast.TimeRange(ast.Time(9, 0), ast.Time(12, 0)),
    ast.TimeRange(ast.Time(12, 0), ast.Time(17, 0)),
    ast.TimeRange(ast.Time(12, 0), ast.Time(12, 0)),
  ))
}

pub fn range_adjacent_b_first_test() {
  // b ends exactly where a starts
  timing.overlap_with(
    ast.TimeRange(ast.Time(12, 0), ast.Time(17, 0)),
    ast.TimeRange(ast.Time(9, 0), ast.Time(12, 0)),
  )
  |> should.equal(overlap.Adjacent(
    ast.TimeRange(ast.Time(12, 0), ast.Time(17, 0)),
    ast.TimeRange(ast.Time(9, 0), ast.Time(12, 0)),
    ast.TimeRange(ast.Time(12, 0), ast.Time(12, 0)),
  ))
}

// --- At / TimeRange (cross-variant)

pub fn at_range_all_inside_test() {
  timing.overlap_with(
    ast.At([ast.Time(10, 0), ast.Time(12, 0)]),
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  )
  |> should.equal(overlap.Subset(
    smaller: ast.At([ast.Time(10, 0), ast.Time(12, 0)]),
    bigger: ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  ))
}

pub fn at_range_none_inside_test() {
  timing.overlap_with(
    ast.At([ast.Time(8, 0)]),
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  )
  |> should.equal(overlap.Disjoint)
}

pub fn at_range_partial_test() {
  timing.overlap_with(
    ast.At([ast.Time(8, 0), ast.Time(10, 0)]),
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  )
  |> should.equal(overlap.Intersection(
    ast.At([ast.Time(8, 0), ast.Time(10, 0)]),
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    ast.At([ast.Time(10, 0)]),
  ))
}

pub fn at_range_on_boundary_test() {
  // time exactly on range boundary is inside
  timing.overlap_with(
    ast.At([ast.Time(9, 0)]),
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  )
  |> should.equal(overlap.Subset(
    smaller: ast.At([ast.Time(9, 0)]),
    bigger: ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  ))
}

// --- TimeRange / At (mirror)

pub fn range_at_all_inside_test() {
  timing.overlap_with(
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    ast.At([ast.Time(10, 0), ast.Time(12, 0)]),
  )
  |> should.equal(overlap.Subset(
    smaller: ast.At([ast.Time(10, 0), ast.Time(12, 0)]),
    bigger: ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
  ))
}

pub fn range_at_none_inside_test() {
  timing.overlap_with(
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    ast.At([ast.Time(8, 0)]),
  )
  |> should.equal(overlap.Disjoint)
}

pub fn range_at_partial_test() {
  timing.overlap_with(
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    ast.At([ast.Time(8, 0), ast.Time(10, 0)]),
  )
  |> should.equal(overlap.Intersection(
    ast.TimeRange(ast.Time(9, 0), ast.Time(17, 0)),
    ast.At([ast.Time(8, 0), ast.Time(10, 0)]),
    ast.At([ast.Time(10, 0)]),
  ))
}
