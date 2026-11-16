{
  lib,
  config,
  companyLib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (companyLib) refs;
  cfg = config.company.pricing;
in {
  options.company.pricing = {
    currency = mkOption {
      type = types.str;
      default = "INR";
      description = "ISO 4217 currency code for every price.";
    };
    plans = mkOption {
      default = {};
      description = "Price plans keyed by id.";
      type = types.attrsOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            example = "Starter";
            description = "Plan name shown to customers.";
          };
          priceMinor = mkOption {
            type = types.ints.unsigned;
            example = 49900;
            description = "Price in the currency's minor unit (paise for INR), to avoid floating point.";
          };
          interval = mkOption {
            type = types.enum ["one-time" "month" "year"];
            default = "month";
            description = "Billing interval.";
          };
          features = mkOption {
            type = types.listOf types.str;
            default = [];
            example = ["Email support"];
            description = "What the plan includes.";
          };
        };
      });
    };
  };

  config.assertions = [
    (refs.check (builtins.match "[A-Z]{3}" cfg.currency != null) "pricing currency must be an ISO 4217 code like 'INR', got '${cfg.currency}'")
  ];
}
