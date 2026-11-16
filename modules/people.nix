{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.company.people = mkOption {
    default = {};
    description = "People who work, or have worked, at the company, keyed by a stable id.";
    type = types.attrsOf (types.submodule {
      options = {
        displayName = mkOption {
          type = types.str;
          example = "Ada Lovelace";
          description = "Name shown in generated catalogs.";
        };
        email = mkOption {
          type = types.str;
          example = "ada@example.com";
          description = "Work email address.";
        };
        githubUser = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "ada-example";
          description = "GitHub login. Required while the person holds a role mapped to a GitHub team.";
        };
        roles = mkOption {
          type = types.listOf types.str;
          default = [];
          example = ["engineering"];
          description = "Role ids from `company.roles`.";
        };
        status = mkOption {
          type = types.enum ["active" "onboarding" "offboarding" "former"];
          default = "active";
          description = ''
            Employment status. Everyone except `former` counts as current:
            their role references must resolve and they keep their access.
          '';
        };
        startDate = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "2026-01-15";
          description = "First day (ISO 8601).";
        };
        endDate = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "2026-12-31";
          description = "Last day (ISO 8601). Required when `status` is `former`.";
        };
      };
    });
  };
}
