## Facts derived from an evaluated `company` config, shared by exporters.
{lib}: cfg: rec {
  ## Everyone except `former` people still holds their roles.
  currentPeople = lib.filterAttrs (_: p: p.status != "former") cfg.people;

  membersOf = role: lib.attrNames (lib.filterAttrs (_: p: builtins.elem role p.roles) currentPeople);

  childrenOf = role: lib.attrNames (lib.filterAttrs (_: r: r.parent == role) cfg.roles);

  orgOf = repo: builtins.head (lib.splitString "/" repo);

  ## GitHub handles that stand for a role in `org`: its team when it has one,
  ## otherwise the GitHub logins of its current members.
  githubOwners = org: role: let
    r = cfg.roles.${role} or null;
  in
    if r == null
    then []
    else if r.githubTeam != null
    then ["@${org}/${r.githubTeam}"]
    else map (id: "@${currentPeople.${id}.githubUser}") (lib.filter (id: currentPeople.${id}.githubUser != null) (membersOf role));

  ## Systems grouped by repository ("Org/name" -> [ system ids ]).
  systemsByRepo = lib.groupBy (id: cfg.systems.${id}.repo) (lib.filter (id: cfg.systems.${id}.repo != null) (lib.attrNames cfg.systems));

  ## Lowercase slug usable as a DNS-label-style name.
  slug = s: let
    lowered = lib.toLower s;
    chars = lib.stringToCharacters lowered;
    mapped = lib.concatMapStrings (c:
      if builtins.match "[a-z0-9]" c != null
      then c
      else "-")
    chars;
  in
    lib.concatStringsSep "-" (lib.filter (x: x != "" && builtins.isString x) (builtins.split "-+" mapped));

  namespace = slug (
    if cfg.entity.shortName != null
    then cfg.entity.shortName
    else cfg.entity.name
  );
}
