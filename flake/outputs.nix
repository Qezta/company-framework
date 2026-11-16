## Public outputs: the pure library and the flake-parts module.
{inputs, ...}: {
  flake = {
    lib = import ../lib {inherit (inputs.nixpkgs) lib;};
    flakeModules = rec {
      company = ../flake-module.nix;
      default = company;
    };
  };
}
