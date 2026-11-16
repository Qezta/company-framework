## The `nix flake init` template, kept honest: its company must evaluate,
## validate, and match its committed exports. A CI job also instantiates it
## for real against this checkout.
{lib, ...}: let
  companyLib = import ../lib {inherit lib;};
  dir = ../templates/default;
  eval = companyLib.evalCompany {modules = [(dir + "/company.nix")];};
in {
  flake.templates.default = {
    path = dir;
    description = "A company spec with company-framework";
    welcomeText = ''
      Replace the TODOs in company.nix, then run:
        nix run .#update-exports && git add -A && nix flake check
    '';
  };

  perSystem = {pkgs, ...}: let
    exports = companyLib.materialize {
      inherit pkgs;
      name = "template-exports";
      files = companyLib.checkedFiles eval;
    };
  in {
    packages.template-exports = exports;

    apps.update-template-exports = {
      type = "app";
      program = lib.getExe (pkgs.writeShellApplication {
        name = "update-template-exports";
        runtimeInputs = [pkgs.coreutils pkgs.git];
        text = ''
          target="$(git rev-parse --show-toplevel)/templates/default/exports"
          rm -rf -- "$target"
          mkdir -p "$target"
          cp -R --no-preserve=mode,ownership ${exports}/. "$target/"
        '';
      });
      meta.description = "Regenerate templates/default/exports";
    };

    checks = {
      template-exports-valid = (import ../lib/validate.nix {inherit pkgs;}).check {
        inherit exports;
        name = "template-exports-valid";
      };
      template-exports-drift = pkgs.runCommand "template-exports-drift" {} ''
        diff -r ${dir + "/exports"} ${exports} || {
          echo "Run: nix run .#update-template-exports && git add templates" >&2
          exit 1
        }
        touch $out
      '';
    };
  };
}
