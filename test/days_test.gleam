import gleeunit/should
import library/ast
import library/ast/days
import library/overlap

// --- SpecificDays

pub fn specific_days_disjoint_test() {
  days.overlap_with(
    ast.SpecificDays([ast.Mon, ast.Tue]),
    ast.SpecificDays([ast.Sat, ast.Sun]),
  )
  |> should.equal(Ok(overlap.Disjoint))
}

pub fn specific_days_subset_test() {
  days.overlap_with(
    ast.SpecificDays([ast.Mon]),
    ast.SpecificDays([ast.Mon, ast.Tue, ast.Wed]),
  )
  |> should.equal(
    Ok(overlap.Subset(
      smaller: ast.SpecificDays([ast.Mon]),
      bigger: ast.SpecificDays([ast.Mon, ast.Tue, ast.Wed]),
    )),
  )
}

pub fn specific_days_intersection_test() {
  days.overlap_with(
    ast.SpecificDays([ast.Mon, ast.Tue, ast.Wed]),
    ast.SpecificDays([ast.Wed, ast.Thu, ast.Fri]),
  )
  |> should.equal(
    Ok(overlap.Intersection(
      ast.SpecificDays([ast.Mon, ast.Tue, ast.Wed]),
      ast.SpecificDays([ast.Wed, ast.Thu, ast.Fri]),
      ast.SpecificDays([ast.Wed]),
    )),
  )
}

// --- BareOrdinalDays

pub fn bare_ordinal_disjoint_test() {
  days.overlap_with(
    ast.BareOrdinalDays([ast.DayOfMonth(1)]),
    ast.BareOrdinalDays([ast.DayOfMonth(15)]),
  )
  |> should.equal(Ok(overlap.Disjoint))
}

pub fn bare_ordinal_subset_test() {
  days.overlap_with(
    ast.BareOrdinalDays([ast.DayOfMonth(1)]),
    ast.BareOrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15)]),
  )
  |> should.equal(
    Ok(overlap.Subset(
      smaller: ast.BareOrdinalDays([ast.DayOfMonth(1)]),
      bigger: ast.BareOrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15)]),
    )),
  )
}

pub fn bare_ordinal_intersection_test() {
  days.overlap_with(
    ast.BareOrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15)]),
    ast.BareOrdinalDays([ast.DayOfMonth(15), ast.DayOfMonth(28)]),
  )
  |> should.equal(
    Ok(overlap.Intersection(
      ast.BareOrdinalDays([ast.DayOfMonth(1), ast.DayOfMonth(15)]),
      ast.BareOrdinalDays([ast.DayOfMonth(15), ast.DayOfMonth(28)]),
      ast.BareOrdinalDays([ast.DayOfMonth(15)]),
    )),
  )
}

// --- QualifiedOrdinalDays

pub fn qualified_disjoint_test() {
  days.overlap_with(
    ast.QualifiedOrdinalDays([ast.NthWeekday(ast.First, ast.Mon)]),
    ast.QualifiedOrdinalDays([ast.NthWeekday(ast.Third, ast.Fri)]),
  )
  |> should.equal(Ok(overlap.Disjoint))
}

pub fn qualified_subset_test() {
  days.overlap_with(
    ast.QualifiedOrdinalDays([ast.NthWeekday(ast.First, ast.Mon)]),
    ast.QualifiedOrdinalDays([
      ast.NthWeekday(ast.First, ast.Mon),
      ast.NthWeekday(ast.Third, ast.Fri),
    ]),
  )
  |> should.equal(
    Ok(overlap.Subset(
      smaller: ast.QualifiedOrdinalDays([ast.NthWeekday(ast.First, ast.Mon)]),
      bigger: ast.QualifiedOrdinalDays([
        ast.NthWeekday(ast.First, ast.Mon),
        ast.NthWeekday(ast.Third, ast.Fri),
      ]),
    )),
  )
}

// --- Cross-variant

pub fn cross_variant_specific_bare_test() {
  days.overlap_with(
    ast.SpecificDays([ast.Mon]),
    ast.BareOrdinalDays([ast.DayOfMonth(1)]),
  )
  |> should.equal(Error(Nil))
}

// pin: might actually be overlap?
pub fn cross_variant_specific_qualified_test() {
  days.overlap_with(
    ast.SpecificDays([ast.Mon]),
    ast.QualifiedOrdinalDays([ast.NthWeekday(ast.First, ast.Mon)]),
  )
  |> should.equal(Error(Nil))
}

pub fn cross_variant_bare_qualified_test() {
  days.overlap_with(
    ast.BareOrdinalDays([ast.DayOfMonth(1)]),
    ast.QualifiedOrdinalDays([ast.NthWeekday(ast.First, ast.Mon)]),
  )
  |> should.equal(Error(Nil))
}
