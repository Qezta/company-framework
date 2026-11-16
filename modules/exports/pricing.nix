## pricing.json: plans and prices, for websites and billing tools.
## Validated against schemas/pricing.schema.json.
{
  lib,
  config,
  ...
}: let
  cfg = config.company;
in {
  options.company.exports.pricing.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to export `pricing.json`.";
  };

  config.output.files = lib.mkIf cfg.exports.pricing.enable {
    "pricing.json" = {
      format = "json";
      value = {inherit (cfg.pricing) currency plans;};
    };
  };
}
