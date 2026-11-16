## Pure ISO-8601 calendar-date helpers (YYYY-MM-DD only).
## Evaluation is pure, so nothing here knows "today"; callers pass dates in.
{lib}: let
  inherit (builtins) elem elemAt match;

  isLeapYear = y: (lib.mod y 4 == 0 && lib.mod y 100 != 0) || lib.mod y 400 == 0;

  daysInMonth = y: m:
    if m == 2
    then
      (
        if isLeapYear y
        then 29
        else 28
      )
    else if elem m [4 6 9 11]
    then 30
    else 31;

  ## toIntBase10 rather than toInt: toInt rejects leading zeros ("08").
  parse = s: let
    m = match "([0-9]{4})-([0-9]{2})-([0-9]{2})" s;
  in
    if m == null
    then null
    else {
      year = lib.toIntBase10 (elemAt m 0);
      month = lib.toIntBase10 (elemAt m 1);
      day = lib.toIntBase10 (elemAt m 2);
    };

  isValid = s: let
    d = parse s;
  in
    builtins.isString s
    && d != null
    && d.month >= 1
    && d.month <= 12
    && d.day >= 1
    && d.day <= daysInMonth d.year d.month;
  ## Days since a fixed epoch (proleptic Gregorian), for date arithmetic.
  ## Shifting the year to start in March puts the leap day last.
  toDays = s: let
    d = parse s;
    y =
      if d.month <= 2
      then d.year - 1
      else d.year;
    m =
      if d.month <= 2
      then d.month + 12
      else d.month;
  in
    365 * y + y / 4 - y / 100 + y / 400 + (153 * (m - 3) + 2) / 5 + d.day;
in {
  inherit isLeapYear daysInMonth parse isValid toDays;

  daysBetween = a: b: toDays b - toDays a;

  ## Zero-padded ISO dates order correctly as strings.
  lessOrEqual = a: b: a <= b;
}
