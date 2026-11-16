## Pirol "Company as Code" export: deliberately not implemented; see
## docs/adr/0005-defer-pirol-company-as-code.md.
{
  lib,
  config,
  ...
}: {
  options.company.exports.pirol.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Reserved for a Pirol \"Company as Code\" export. Not implemented; enabling it fails evaluation.";
  };

  config.assertions = [
    {
      assertion = !config.company.exports.pirol.enable;
      message = "the Pirol exporter is not implemented yet (see docs/adr/0005-defer-pirol-company-as-code.md)";
    }
  ];
}
