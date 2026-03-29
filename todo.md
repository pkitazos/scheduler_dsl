# todo

- [ ] frequency
- [ ] timing
- [ ] days
- [ ] time_range
- [/] bounds
  - [x] date validation
  - [x] time validation
  - [ ] between.start < between.end
  - [ ] len(between) >= len(schedule) e.g:
    - [ ] `on weekdays <between>` where `between` only cover a weekend
    - [ ] `monthly <between>` where `between` is less than a month / does not span into another month
    - [ ] `weekly <between>`  where `between` is less than a week / does not span into another week
- [ ] exclusion
