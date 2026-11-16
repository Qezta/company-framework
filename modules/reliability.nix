{
  lib,
  config,
  companyLib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (companyLib) refs;
  cfg = config.company;
in {
  options.company.reliability.slos = mkOption {
    default = {};
    description = "Service level objectives, exported as OpenSLO.";
    type = types.attrsOf (types.submodule {
      options = {
        system = mkOption {
          type = types.str;
          example = "website";
          description = "System id the objective applies to.";
        };
        description = mkOption {
          type = types.str;
          example = "Homepage is up.";
          description = "What the objective promises.";
        };
        indicator = mkOption {
          type = types.enum ["http-availability" "latency" "custom"];
          example = "http-availability";
          description = "Kind of indicator; becomes the OpenSLO ratio metric's good/total queries' names.";
        };
        target = mkOption {
          type = types.float;
          example = 0.999;
          description = "Objective as a fraction strictly between 0 and 1.";
        };
        window = mkOption {
          type = types.str;
          default = "28d";
          description = "Rolling window as an OpenSLO duration (`<n>m`, `<n>h`, `<n>d` or `<n>w`).";
        };
        metricSource = {
          type = mkOption {
            type = types.str;
            example = "Prometheus";
            description = "Metric backend (OpenSLO `metricSource.type`).";
          };
          spec = mkOption {
            type = types.attrsOf types.anything;
            default = {};
            example = {
              good = "sum(rate(http_requests_total{code!~\"5..\"}[5m]))";
              total = "sum(rate(http_requests_total[5m]))";
            };
            description = "Backend-specific settings; `good` and `total` become the ratio metric queries.";
          };
        };
      };
    });
  };

  config.assertions = lib.concatLists (lib.mapAttrsToList (id: s: let
      what = "slo '${id}'";
    in [
      (refs.refersTo (builtins.attrNames cfg.systems) "${what} system" "system" s.system)
      (refs.check (s.target > 0.0 && s.target < 1.0) "${what} target must be between 0 and 1, got ${toString s.target}")
      (refs.check (builtins.match "[0-9]+[mhdw]" s.window != null) "${what} window is not a duration like '28d': '${s.window}'")
      (refs.check (s.metricSource.spec ? good && s.metricSource.spec ? total) "${what} metricSource.spec needs 'good' and 'total' queries")
    ])
    cfg.reliability.slos);
}
