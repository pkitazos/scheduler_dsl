# Validator Rules

## frequency
- [x] `Every.amount` must be > 0

## timing
- [x] validate all times (hour 0–23, minute 0–59)
- [x] `At`: reject duplicate times
- [x] `TimeRange`: reject `from == to`

## days
- [ ] `SpecificDays`: reject duplicate days
- [ ] `OrdinalDays`: `DayOfMonth(n)` must be 1–31
- [ ] `OrdinalDays`: reject duplicate entries (structural equality)
- [ ] `OrdinalDays`: informational message when mixing bare and qualified ordinals
- [ ] `OrdinalDays`: informational message when bare and qualified ordinals might overlap

## bounds
- [x] validate dates
- [x] validate times
- [x] `Between`: start must be before end

## exclusions
- [ ] reject duplicate exclusions (structural equality)
- [ ] reject exclusion that is a strict subset of another exclusion
- [ ] `ExceptTime`: all timing rules carry forward
- [ ] `ExceptDays`: all days rules carry forward
- [ ] `ExceptBounds`: all bounds rules carry forward

## cross-clause (incomplete)
- [ ] bounds too narrow for frequency/days
- [ ] exclusions that totally cancel the schedule
- [ ] `DayOfMonth(31)` with monthly context (only fires some months)
