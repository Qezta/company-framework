{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    ## Generated files are checked by the drift check, not reformatted.
    settings.global.excludes = ["examples/*/exports/*" "LICENSES/*" "LICENSE"];
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
