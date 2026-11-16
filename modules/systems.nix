{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.company.systems = mkOption {
    default = {};
    description = "Software and infrastructure the company runs, keyed by a stable id.";
    type = types.attrsOf (types.submodule ({config, ...}: {
      options = {
        description = mkOption {
          type = types.str;
          example = "Marketing website.";
          description = "What the system is.";
        };
        type = mkOption {
          type = types.enum ["website" "service" "library" "infrastructure" "documentation" "tool"];
          example = "website";
          description = "Kind of system.";
        };
        lifecycle = mkOption {
          type = types.enum ["experimental" "production" "deprecated"];
          default = "experimental";
          description = "Lifecycle stage.";
        };
        domain = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "web";
          description = "Domain id from `company.domains`.";
        };
        owner = mkOption {
          type = types.str;
          example = "engineering";
          description = "Role id that owns the system.";
        };
        repo = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "example-org/website";
          description = "Source repository as `Org/name`.";
        };
        codeowners = mkOption {
          type = types.listOf (types.submodule {
            options = {
              pattern = mkOption {
                type = types.str;
                example = "docs/";
                description = "CODEOWNERS path pattern.";
              };
              owners = mkOption {
                type = types.listOf types.str;
                example = ["engineering"];
                description = "Role ids that own matching paths.";
              };
            };
          });
          default = [
            {
              pattern = "*";
              owners = [config.owner];
            }
          ];
          defaultText = lib.literalExpression ''[ { pattern = "*"; owners = [ owner ]; } ]'';
          description = "Ownership rules for paths in `repo`. Defaults to the system owner for everything.";
        };
        dependsOn = mkOption {
          type = types.listOf types.str;
          default = [];
          example = ["api"];
          description = "Ids of systems this one depends on.";
        };
        links = mkOption {
          type = types.attrsOf types.str;
          default = {};
          example = {docs = "https://example.com/docs";};
          description = "Related links keyed by title.";
        };
      };
    }));
  };
}
