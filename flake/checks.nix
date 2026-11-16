{
  inputs,
  lib,
  ...
}: let
  companyLib = import ../lib {inherit lib;};
  base = ../examples/acme/acme.nix;
in {
  imports = [inputs.git-hooks.flakeModule];

  perSystem = {
    pkgs,
    self',
    ...
  }: {
    checks = {
      negative-tests = import ../tests/negative {inherit pkgs companyLib base;};

      lib-tests = let
        failures = import ../tests/lib.nix {inherit lib companyLib base;};
      in
        pkgs.runCommand "company-lib-tests" {} (
          if failures == []
          then "touch $out"
          else ''
            echo ${lib.escapeShellArg (builtins.toJSON failures)} >&2
            exit 1
          ''
        );

      spec-schema = pkgs.runCommand "company-spec-schema" {nativeBuildInputs = [pkgs.check-jsonschema];} ''
        check-jsonschema --check-metaschema ${../schemas/company.schema.json}
        check-jsonschema --schemafile ${../schemas/company.schema.json} ${self'.packages.spec}
        touch $out
      '';

      gitleaks = pkgs.runCommand "company-gitleaks" {nativeBuildInputs = [pkgs.gitleaks];} ''
        gitleaks dir --no-banner --redact ${../.}
        touch $out
      '';

      reuse = pkgs.runCommand "company-reuse" {nativeBuildInputs = [pkgs.reuse];} ''
        cp -r ${../.} src && chmod -R u+w src && cd src
        reuse lint
        touch $out
      '';
    };

    pre-commit = {
      check.enable = true;
      settings = {
        enable = true;
        package = pkgs.prek;
        gitPackage = pkgs.gitFull;
        src = ../.;
        excludes = ["flake.lock" "/exports/"];
        default_stages = ["pre-commit"];
        hooks = {
          treefmt.enable = false; # runs as the treefmt flake check instead
          trim-trailing-whitespace.enable = true;
          check-added-large-files.enable = true;
          check-case-conflicts.enable = true;
          check-executables-have-shebangs.enable = true;
          check-shebang-scripts-are-executable.enable = true;
          fix-byte-order-marker.enable = true;
          check-merge-conflicts.enable = true;
          detect-private-keys.enable = true;
        };
      };
    };
  };
}
