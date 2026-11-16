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
      validate-mutations = import ../tests/validate-mutations.nix {
        inherit pkgs;
        inherit (self'.packages) exports;
      };

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

      schemas-valid = pkgs.runCommand "schemas-valid" {nativeBuildInputs = [pkgs.check-jsonschema];} ''
        check-jsonschema --check-metaschema ${../schemas}/*.schema.json
        touch $out
      '';

      opa-policies = pkgs.runCommand "opa-policies" {nativeBuildInputs = [(pkgs.callPackage ../pkgs/opa.nix {}) pkgs.regal];} ''
        opa check --strict ${../opa/policies}
        opa test ${../opa/policies} -v
        ${lib.optionalString (pkgs.stdenv.hostPlatform.system != "x86_64-darwin") ''
          ## Regal matches package paths to directory names, and the store copy
          ## is named "<hash>-policies", so lint a copy under its real name.
          ## Skipped on x86_64-darwin: frozen on nixpkgs 26.05, its older Regal
          ## rejects the config's newer rule names. CI lints on Linux.
          cp -r ${../opa/policies} policies && chmod -R u+w policies
          regal lint --config-file ${../.regal/config.yaml} policies
        ''}
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
        ## vendor/ stays byte-identical to upstream.
        excludes = ["flake.lock" "/exports/" "^vendor/"];
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
