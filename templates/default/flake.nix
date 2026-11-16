{
  description = "Company spec built with company-framework";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;
      imports = [inputs.company-framework.flakeModules.company];

      company.modules = [./company.nix];

      perSystem = {
        system,
        pkgs,
        ...
      }: {
        # nixpkgs-unstable dropped x86_64-darwin; 26.05 is its last release.
        _module.args.pkgs = import (
          if system == "x86_64-darwin"
          then inputs."nixpkgs-2605"
          else inputs.nixpkgs
        ) {inherit system;};
        formatter = pkgs.alejandra;
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    "nixpkgs-2605".url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Last nix-systems revision that still lists x86_64-darwin.
    systems.url = "github:nix-systems/default/da67096a3b9bf56a91d16901293e51ba5b49a27e";
    company-framework = {
      url = "github:Qezta/company-framework";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
      };
    };
  };
}
