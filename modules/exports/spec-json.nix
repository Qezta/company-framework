## spec.json: the whole company spec as plain JSON, validated against
## schemas/company.schema.json. The interchange format for tools that should
## not have to read Nix.
{
  lib,
  config,
  companyLib,
  ...
}: let
  cfg = config.company;
in {
  options.company.exports.specJson.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to export `spec.json`.";
  };

  config.output.files = lib.mkIf cfg.exports.specJson.enable {
    "spec.json" = {
      format = "json";
      value = {
        inherit (companyLib) specVersion;
        inherit (cfg) asOf entity people roles domains systems policies processes reliability pricing decisions documents;
      };
    };
  };
}
