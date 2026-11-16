## Data document for Open Policy Agent. Rego policies shipped in opa/policies
## read it as `data.company`. Only fields the policies need are included:
## no names or email addresses.
{
  lib,
  config,
  ...
}: let
  cfg = config.company;
in {
  options.company.exports.opa.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to export `opa/data.json`.";
  };

  config.output.files = lib.mkIf cfg.exports.opa.enable {
    "opa/data.json" = {
      format = "json";
      value.company = {
        inherit (cfg) asOf;
        people = lib.mapAttrs (_: p: {inherit (p) status roles githubUser;}) cfg.people;
        roles = lib.mapAttrs (_: r: {inherit (r) parent githubTeam githubPermission;}) cfg.roles;
        systems = lib.mapAttrs (_: s: {inherit (s) type lifecycle owner repo;}) cfg.systems;
        slos = lib.mapAttrs (_: s: {inherit (s) system target window;}) cfg.reliability.slos;
        policies = lib.mapAttrs (_: p: {inherit (p) title owner reviewEveryDays lastReviewed rules;}) cfg.policies;
      };
    };
  };
}
