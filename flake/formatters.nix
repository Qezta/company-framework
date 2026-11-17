{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    ## Generated files are checked by the drift check, not reformatted.
    ## CHANGELOG.md is written by release-please.
    settings.global.excludes = ["CHANGELOG.md" "examples/*/exports/*" "templates/*/exports/*" "vendor/*" "docs/options.md" "LICENSES/*" "LICENSE"];
    flakeCheck = true;
    programs = {
      alejandra.enable = true;
      deadnix.enable = true;
      statix.enable = true;
      mdformat.enable = true;
      actionlint.enable = true;
      typos.enable = true;
    };
  };
}
