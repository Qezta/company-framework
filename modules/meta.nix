{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.company.root = mkOption {
    type = types.nullOr types.path;
    default = null;
    example = lib.literalExpression "./.";
    description = ''
      Directory that Markdown paths (policy and process docs, decisions) are
      relative to. Usually `./.` in the company module. When null, those
      files are neither checked nor read.
    '';
  };

  options.company.asOf = mkOption {
    type = types.nullOr types.str;
    default = null;
    example = "2026-11-16";
    description = ''
      Reference date (ISO 8601, `YYYY-MM-DD`) for date-relative checks.
      Evaluation is pure and cannot read the clock, so checks that need
      "today" use this value when set. Leave null to skip them.
    '';
  };
}
