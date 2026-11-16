## OpenSLO v1: a Service per system with objectives, and an SLO per objective
## with an inline ratio-metric SLI built from metricSource.spec.good/total.
{
  lib,
  config,
  ...
}: let
  cfg = config.company;
  slos = cfg.reliability.slos;
  services = lib.unique (lib.mapAttrsToList (_: s: s.system) slos);

  metric = s: query: {
    metricSource = {
      inherit (s.metricSource) type;
      spec = (builtins.removeAttrs s.metricSource.spec ["good" "total"]) // {inherit query;};
    };
  };

  slo = id: s: {
    apiVersion = "openslo/v1";
    kind = "SLO";
    metadata = {
      name = id;
      displayName = s.description;
    };
    spec = {
      inherit (s) description;
      service = s.system;
      indicator = {
        metadata.name = "${id}-${s.indicator}";
        spec.ratioMetric = {
          counter = true;
          good = metric s s.metricSource.spec.good;
          total = metric s s.metricSource.spec.total;
        };
      };
      timeWindow = [
        {
          duration = s.window;
          isRolling = true;
        }
      ];
      budgetingMethod = "Occurrences";
      objectives = [
        {
          displayName = s.description;
          inherit (s) target;
        }
      ];
    };
  };
in {
  options.company.exports.openslo.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to export OpenSLO documents under `openslo/`.";
  };

  config.output.files = lib.mkIf (cfg.exports.openslo.enable && slos != {}) {
    "openslo/services.yaml" = {
      format = "yaml-stream";
      value =
        map (name: {
          apiVersion = "openslo/v1";
          kind = "Service";
          metadata.name = name;
          spec.description = cfg.systems.${name}.description;
        })
        services;
    };
    "openslo/slos.yaml" = {
      format = "yaml-stream";
      value = lib.mapAttrsToList slo slos;
    };
  };
}
