## Cross-reference and consistency checks. Failures are collected rather than
## thrown so `companyLib.failedAssertions` can report all of them at once (and
## negative tests can match their messages).
{
  lib,
  config,
  companyLib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (builtins) attrNames concatLists elem length match;
  inherit (companyLib) dates graph refs;
  inherit (refs) check;

  cfg = config.company;
  roleIds = attrNames cfg.roles;
  domainIds = attrNames cfg.domains;
  systemIds = attrNames cfg.systems;

  forEach = attrs: f: concatLists (lib.mapAttrsToList f attrs);

  inherit (refs) refersTo;

  isEmail = s: match "[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+" s != null;
  isHexColor = s: match "#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})" s != null;
  isRepo = s: match "[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9._-]+" s != null;

  currentPeople = lib.filterAttrs (_: p: p.status != "former") cfg.people;

  ## Roles that grant GitHub access through a team.
  githubRoles = attrNames (lib.filterAttrs (_: r: r.githubTeam != null) cfg.roles);

  dateChecks = what: d: lib.optional (d != null) (check (dates.isValid d) "${what} is not a valid ISO 8601 date: '${d}'");

  peopleChecks = forEach cfg.people (id: p: let
    what = "person '${id}'";
    current = currentPeople ? ${id};
  in
    lib.optionals current (map (refersTo roleIds what "role") p.roles)
    ++ [(check (isEmail p.email) "${what} has an invalid email address: '${p.email}'")]
    ++ dateChecks "${what} startDate" p.startDate
    ++ dateChecks "${what} endDate" p.endDate
    ++ lib.optional (p.status == "former") (check (p.endDate != null) "${what} is former but has no endDate")
    ++ lib.optional (p.startDate != null && p.endDate != null && dates.isValid p.startDate && dates.isValid p.endDate)
    (check (dates.lessOrEqual p.startDate p.endDate) "${what} has startDate ${p.startDate} after endDate ${p.endDate}")
    ++ lib.optional (current && lib.any (r: elem r githubRoles) p.roles)
    (check (p.githubUser != null) "${what} holds a GitHub-mapped role but has no githubUser"));

  roleCycle = graph.cyclicNodes (lib.mapAttrs (_: r: lib.optional (r.parent != null) r.parent) cfg.roles);

  teamSlugs = lib.groupBy (x: x.team) (lib.mapAttrsToList (id: r: {
    inherit id;
    team = r.githubTeam;
  }) (lib.filterAttrs (_: r: r.githubTeam != null) cfg.roles));

  roleChecks =
    forEach cfg.roles (id: r: lib.optional (r.parent != null) (refersTo roleIds "role '${id}' parent" "role" r.parent))
    ++ [(check (roleCycle == []) "role parent graph has a cycle involving: ${lib.concatStringsSep ", " roleCycle}")]
    ++ lib.mapAttrsToList (team: rs:
      check (length rs == 1) "GitHub team slug '${team}' is used by multiple roles: ${lib.concatMapStringsSep ", " (x: x.id) rs}")
    teamSlugs;

  ownerChecks = refs.owner roleIds;

  domainChecks = forEach cfg.domains (id: d: ownerChecks "domain '${id}'" d.owner);

  systemChecks = forEach cfg.systems (id: s: let
    what = "system '${id}'";
  in
    ownerChecks what s.owner
    ++ lib.optional (s.domain != null) (refersTo domainIds "${what} domain" "domain" s.domain)
    ++ map (refersTo systemIds "${what} dependsOn" "system") s.dependsOn
    ++ concatLists (map (rule: map (refersTo roleIds "${what} codeowners '${rule.pattern}'" "role") rule.owners) s.codeowners)
    ++ lib.optional (s.repo != null) (check (isRepo s.repo) "${what} repo must look like 'Org/name', got '${s.repo}'"));

  entityChecks =
    lib.mapAttrsToList (name: e: check (isEmail e) "entity contact '${name}' has an invalid email address: '${e}'")
    (lib.filterAttrs (_: e: e != null) cfg.entity.contacts)
    ++ lib.mapAttrsToList (name: c: check (isHexColor c) "brand color '${name}' is not a hex color: '${c}'") cfg.entity.brand.colors;
in {
  options = {
    assertions = mkOption {
      type = types.listOf (types.submodule {
        options = {
          assertion = mkOption {
            type = types.bool;
            description = "Condition that must hold.";
          };
          message = mkOption {
            type = types.str;
            description = "Explanation shown when the condition does not hold.";
          };
        };
      });
      default = [];
      internal = true;
      description = "Checks that must all hold before anything is exported.";
    };
    warnings = mkOption {
      type = types.listOf types.str;
      default = [];
      internal = true;
      description = "Messages printed during export without failing it.";
    };
  };

  config.assertions =
    dateChecks "company.asOf" cfg.asOf
    ++ entityChecks
    ++ peopleChecks
    ++ roleChecks
    ++ domainChecks
    ++ systemChecks;
}
