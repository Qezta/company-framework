{
  lib,
  config,
  companyLib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (companyLib) dates refs;
  cfg = config.company;
  roleIds = builtins.attrNames cfg.roles;
in {
  options.company.policies = mkOption {
    default = {};
    description = ''
      Company policies. The prose lives in Markdown (`doc`); machine-checkable
      parts go in `rules` and are exported to OPA as data.
    '';
    type = types.attrsOf (types.submodule {
      options = {
        title = mkOption {
          type = types.str;
          example = "Access control";
          description = "Policy title.";
        };
        owner = mkOption {
          type = types.str;
          example = "founder";
          description = "Role id accountable for the policy.";
        };
        doc = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "policies/access-control.md";
          description = "Markdown file with the policy text, relative to `company.root`.";
        };
        reviewEveryDays = mkOption {
          type = types.ints.positive;
          default = 365;
          description = "How often the policy must be reviewed.";
        };
        lastReviewed = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "2026-06-01";
          description = "Date of the last review (ISO 8601). Overdue reviews produce a warning.";
        };
        rules = mkOption {
          type = types.attrsOf types.anything;
          default = {};
          example = {adminAllowed = ["founder"];};
          description = "Machine-readable rules exported to `opa/data.json`; must be JSON-compatible.";
        };
      };
    });
  };

  config = {
    assertions = lib.concatLists (lib.mapAttrsToList (id: p: let
      what = "policy '${id}'";
    in
      refs.owner roleIds what p.owner
      ++ refs.docExists cfg.root what p.doc
      ++ lib.optional (p.lastReviewed != null)
      (refs.check (dates.isValid p.lastReviewed) "${what} lastReviewed is not a valid ISO 8601 date: '${p.lastReviewed}'"))
    cfg.policies);

    ## Needs a reference date: evaluation is pure and cannot read the clock.
    warnings = lib.concatLists (lib.mapAttrsToList (id: p:
      lib.optional (
        cfg.asOf
        != null
        && p.lastReviewed != null
        && dates.isValid cfg.asOf
        && dates.isValid p.lastReviewed
        && dates.daysBetween p.lastReviewed cfg.asOf > p.reviewEveryDays
      ) "policy '${id}' review is overdue: last reviewed ${p.lastReviewed}, due every ${toString p.reviewEveryDays} days")
    cfg.policies);
  };
}
