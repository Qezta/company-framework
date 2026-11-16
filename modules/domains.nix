{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.company.domains = mkOption {
    default = {};
    description = "Business domains that group related systems.";
    type = types.attrsOf (types.submodule {
      options = {
        description = mkOption {
          type = types.str;
          example = "Everything customers see.";
          description = "What the domain covers.";
        };
        owner = mkOption {
          type = types.str;
          example = "engineering";
          description = "Role id that owns the domain.";
        };
      };
    });
  };
}
