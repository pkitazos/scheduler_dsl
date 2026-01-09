## Schedule DSL Spec

### Basic intervals

```
every 5 minutes
every 30 seconds
every 2 hours
every 1 day
hourly
daily
weekly
monthly
```

### Specific times

```
at 9:00
at 14:30
at 9:00 and 17:00
at 9:00, 12:00, and 17:00
```

### Days of the week

```
on monday
on monday and friday
on weekdays
on weekends
```

### Monthly day references

```
on the 1st
on the 15th and last
on the last friday
on the first monday
on the 1st and 15th
```

### Combined expressions

```
every 30 minutes on weekdays
at 9:00 on monday
at 9:00 and 17:00 on weekdays
every 2 hours on saturday and sunday
daily at 9:00
weekly on monday at 9:00
monthly on the 1st at 12:00
monthly on the last friday at 9:00
```

### Time ranges

```
every 15 minutes between 9:00 and 17:00
every 15 minutes between 9:00 and 17:00 on weekdays
hourly between 8:00 and 20:00
```

### Bounded schedules

```
starting 2024-01-01
until 2024-12-31
from 2024-01-01 until 2024-06-30
daily at 9:00 starting 2024-01-01
every monday at 10:00 from 2024-01-01 until 2024-03-31
```

### Exclusions

```
every 30 minutes except weekends
daily at 9:00 except on monday
hourly except between 22:00 and 6:00
every 15 minutes between 9:00 and 17:00 except on friday
```

---

## Grammar sketch (informal)

```
schedule    = frequency? timing? days? time_range? bounds? exclusion?

frequency   = "every" number unit
            | "hourly" | "daily" | "weekly" | "monthly"

timing      = "at" time_list

days        = "on" day_list
            | "on weekdays"
            | "on weekends"
            | "on the" ordinal_list

time_list   = time ("," time)* ("and" time)?

day_list    = day ("," day)* ("and" day)?

ordinal_list = ordinal ("," ordinal)* ("and" ordinal)?

ordinal     = number ("st"|"nd"|"rd"|"th")
            | "last"
            | "first" day | "second" day | ... | "last" day

time_range  = "between" time "and" time

bounds      = "starting" date
            | "until" date
            | "from" date "until" date

exclusion   = "except" (days | time_range | "on" day_list)

time        = HH:MM (24-hour)
date        = YYYY-MM-DD
unit        = "second" | "seconds" | "minute" | "minutes" 
            | "hour" | "hours" | "day" | "days"
day         = "monday" | "tuesday" | ... | "sunday"
number      = [0-9]+
```
