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
in {
  inherit isLeapYear daysInMonth parse isValid;

  ## Zero-padded ISO dates order correctly as strings.
  lessOrEqual = a: b: a <= b;
}
