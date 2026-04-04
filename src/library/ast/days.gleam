import library/ast
import library/overlap.{overlap_fmap, set_overlap}

/// Compares two `Days` values and determines their set-theoretic relationship.
///
/// Returns `Ok(Subset(a, b))` when `a` is a proper subset of `b`,
/// `Ok(Intersection(a, b, shared))` when they partially overlap,
/// `Ok(Disjoint)` when they share nothing, or `Error(Nil)` when
/// the two values are of different `Days` variants (e.g. `SpecificDays`
/// vs `BareOrdinalDays`), since cross-variant comparison is not meaningful.
///
/// The original `ast.Days` values are preserved in the result so that
/// error messages can refer to what the user actually wrote.
///
/// Assumes all inner lists have already been de-duplicated upstream.
pub fn overlap_with(
  a: ast.Days,
  b: ast.Days,
) -> Result(overlap.Overlap(ast.Days), Nil) {
  case a, b {
    ast.SpecificDays(d1), ast.SpecificDays(d2) -> {
      set_overlap(d1, d2)
      |> overlap_fmap(ast.SpecificDays)
      |> Ok()
    }
    ast.BareOrdinalDays(d1), ast.BareOrdinalDays(d2) -> {
      set_overlap(d1, d2)
      |> overlap_fmap(ast.BareOrdinalDays)
      |> Ok()
    }
    ast.QualifiedOrdinalDays(d1), ast.QualifiedOrdinalDays(d2) -> {
      set_overlap(d1, d2)
      |> overlap_fmap(ast.QualifiedOrdinalDays)
      |> Ok()
    }
    _, _ -> Error(Nil)
  }
}
