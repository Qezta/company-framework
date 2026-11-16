{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.company.roles = mkOption {
    default = {};
    description = "Roles people hold. Roles form a tree through `parent` and map onto groups and teams.";
    type = types.attrsOf (types.submodule {
      options = {
        description = mkOption {
          type = types.str;
          example = "Builds and runs the product.";
          description = "What this role is for.";
        };
        parent = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "founder";
          description = "Parent role id, giving the group hierarchy. Must not form a cycle.";
        };
        githubTeam = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "engineering";
          description = "Slug of the GitHub team this role maps to. Slugs must be unique.";
        };
        githubPermission = mkOption {
          type = types.enum ["pull" "triage" "push" "maintain" "admin"];
          default = "pull";
          description = "Repository permission the role's GitHub team receives on repositories it owns.";
        };
        responsibilities = mkOption {
          type = types.listOf types.str;
          default = [];
          example = ["Review pull requests"];
          description = "What people in this role are accountable for.";
        };
      };
    });
  };
}
