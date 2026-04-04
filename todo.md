# todo

## Validator checks

### frequency
- [x] `Every.amount` must be > 0

### timing
- [x] validate all times (hour 0–23, minute 0–59)
- [x] `At`: reject duplicate times
- [x] `TimeRange`: reject `from == to`

### days
- [x] `SpecificDays`: reject duplicate days
- [x] `OrdinalDays`: `DayOfMonth(n)` must be 1–31
- [x] `OrdinalDays`: reject duplicate entries (see notes)

### bounds
- [x] validate dates
- [x] validate times
- [x] `Between`: start must be before end

### exclusions

#### general (across all exclusions)
- [x] reject duplicate exclusions (see notes)

#### ExceptDays
- [x] all individual days rules carry forward
- [x] reject day exclusion that is a strict subset of another day exclusion
- [/] informational: partial overlap between day exclusions
- [x] ordinal days subset/overlap detection (same-kind only)

#### ExceptTime
- [x] all individual timing rules carry forward
      (validate hours/minutes, At: no duplicate times,
       TimeRange: from != to)
- [x] reject time exclusion that is a strict subset of another time exclusion
      (e.g. "except at 09:00" is redundant alongside "except from 08:00 to 10:00")

#### ExceptBounds
- [x] all individual bounds rules carry forward
      (validate dates, validate times, Between: start before end)
- [x] reject bounds exclusion that is a strict subset of another bounds exclusion
      (e.g. a date range fully inside another date range)

### cross-clause (incomplete)
- [ ] bounds too narrow for frequency/days
- [ ] exclusions that totally cancel the schedule
- [ ] `DayOfMonth(31)` with monthly context (only fires some months)


## General Thoughts

A lot of our AST nodes currently carry lists of data, but in the sense of a schedule, lists like "monday, tuesday and wednesday" should be treated like a set, not a list. The order is irrelevant. "monday, tuesday and wednesday" is the same as "tuesday, monday and wednesday"

So our `no_duplicates` check doesn't quite work.

## Unit tests

Besides obviously needing to test the compiler phases, we also ought to test other parts of the project

- [x] all the utils
- [x] the overlap module
- [ ] the ast modules
- [ ] the ast comparison functions
- [ ] the ast check functions
- [ ] the ast normalise functions
