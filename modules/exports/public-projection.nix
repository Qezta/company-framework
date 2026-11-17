## public/projection.json: the subset of the spec that is safe to publish,
## for public consumers such as an infrastructure repository that creates
## GitHub teams and repository permissions. People appear only as GitHub
## logins under the roles they currently hold: no names, emails, dates or
## status. Validated against schemas/projection.schema.json.
{
  lib,
  config,
  companyLib,
  ...
}: let
  cfg = config.company;
  d = companyLib.derive cfg;
  logins = role:
    lib.sort (a: b: a < b) (lib.concatMap (id: lib.optional (d.currentPeople.${id}.githubUser != null) d.currentPeople.${id}.githubUser) (d.membersOf role));
in {
  options.company.exports.publicProjection.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to export `public/projection.json` (roles, GitHub teams and logins, systems; no personal details).";
  };

  config.output.files = lib.mkIf cfg.exports.publicProjection.enable {
    "public/projection.json" = {
      format = "json";
      value = {
        inherit (companyLib) specVersion;
        organization = d.namespace;
        roles =
          lib.mapAttrs (id: r: {
            inherit (r) description parent githubTeam githubPermission;
            githubMembers = logins id;
          })
          cfg.roles;
        systems = lib.mapAttrs (_: s: {inherit (s) description type lifecycle domain owner repo codeowners;}) cfg.systems;
      };
    };
  };
}
