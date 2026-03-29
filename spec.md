## DSL Grammar

### Base Types
```
number           := [0-9]+
time             := HH:MM
date             := YYYY-MM-DD

unit             := "second" | "seconds"
                  | "minute" | "minutes"
                  | "hour" | "hours"
                  | "day" | "days"
                  | "week" | "weeks"
                  | "month" | "months"
                  | "year" | "years"

day              := "monday" | "tuesday" | "wednesday" | "thursday"
                  | "friday" | "saturday" | "sunday"

day_group        := "weekdays" | "weekends"
```

### Frequency
```
frequency_sugar  := "hourly" | "daily" | "weekly" | "monthly" | "annually"
frequency        := "once" | "every" number unit | frequency_sugar
```

### Lists
```
day_list         := day
                  | day "and" day
                  | day ("," day)* "and" day

time_list        := time
                  | time "and" time
                  | time ("," time)* "and" time
```

### Ordinals
```
ordinal_suffix   := "st" | "nd" | "rd" | "th"

bare_ordinal     := number ordinal_suffix
                  | "last"

word_ordinal     := "first" | "second" | "third" | "fourth" | "fifth" | "last"
qualified_ordinal := word_ordinal day

bare_ordinal_list      := bare_ordinal
                        | bare_ordinal "and" bare_ordinal
                        | bare_ordinal ("," bare_ordinal)* "and" bare_ordinal

qualified_ordinal_list := qualified_ordinal
                        | qualified_ordinal "and" qualified_ordinal
                        | qualified_ordinal ("," qualified_ordinal)* "and" qualified_ordinal

ordinal_list     := bare_ordinal_list | qualified_ordinal_list
```

### Clauses
```
on_clause        := "on" day_list
                  | "on" day_group
                  | "on" "the" bare_ordinal_list
                  | "on" "the" qualified_ordinal_list

time_clause      := "from" time "to" time
                  | "at" time_list

bounds           := "starting" date
                  | "starting" date "until" date

exclusion        := "except" on_clause
                  | "except" time_clause
                  | "except" bounds

exclusions       := exclusion+
```

### Schedule
```
schedule         := frequency time_clause? on_clause? bounds? exclusions?
```
