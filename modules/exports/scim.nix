## SCIM 2.0 (RFC 7643/7644) ListResponse documents for identity providers.
## SCIM `id`s are server-assigned, so our stable ids go in `externalId`, and
## group members reference people by that externalId.
{
  lib,
  config,
  companyLib,
  ...
}: let
  cfg = config.company;
  d = companyLib.derive cfg;
  listResponse = resources: {
    schemas = ["urn:ietf:params:scim:api:messages:2.0:ListResponse"];
    totalResults = builtins.length resources;
    startIndex = 1;
    itemsPerPage = builtins.length resources;
    Resources = resources;
  };
in {
  options.company.exports.scim.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to export SCIM users and groups under `scim/`.";
  };

  config.output.files = lib.mkIf cfg.exports.scim.enable {
    "scim/users.json" = {
      format = "json";
      value = listResponse (lib.mapAttrsToList (id: p: {
          schemas = ["urn:ietf:params:scim:schemas:core:2.0:User"];
          externalId = id;
          userName = p.email;
          inherit (p) displayName;
          name.formatted = p.displayName;
          emails = [
            {
              value = p.email;
              type = "work";
              primary = true;
            }
          ];
          active = p.status != "former";
        })
        cfg.people);
    };
    "scim/groups.json" = {
      format = "json";
      value = listResponse (lib.mapAttrsToList (id: _: {
          schemas = ["urn:ietf:params:scim:schemas:core:2.0:Group"];
          externalId = id;
          displayName = id;
          members = map (pid: {
            value = pid;
            display = d.currentPeople.${pid}.displayName;
            type = "User";
          }) (d.membersOf id);
        })
        cfg.roles);
    };
  };
}
