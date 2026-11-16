## flake-parts wrapper around lib.evalCompany. Consumers write:
##
##   imports = [ inputs.company-framework.flakeModules.company ];
##   company.modules = [ ./company.nix ];
##
## and get packages.{spec,exports}, apps.update-exports, a drift check
## comparing the committed exports directory with a fresh build, and a
## validation check against each export's standard.
{
  lib,
  config,
  self,
  ...
}: let
  inherit (lib) mkOption types;
  companyLib = import ./lib {inherit lib;};
  cfg = config.company;

  isSafeDir = d: d != "" && !(lib.hasPrefix "/" d) && !(lib.hasInfix ".." d);
  eval = companyLib.evalCompany {inherit (cfg) modules specialArgs;};
  committed = cfg.root + "/${cfg.exportsDir}";
in {
  options.company = {
    modules = mkOption {
      type = types.listOf types.deferredModule;
      default = [];
      example = lib.literalExpression "[ ./company.nix ]";
      description = "Company modules to evaluate. Nothing is generated while this is empty.";
    };
    specialArgs = mkOption {
      type = types.attrsOf types.raw;
      default = {};
      description = "Extra arguments passed to every company module.";
    };
    root = mkOption {
      type = types.path;
      default = self;
      defaultText = lib.literalExpression "self";
      description = "Repository root that `exportsDir` is relative to.";
    };
    exportsDir = mkOption {
      type = types.addCheck types.str isSafeDir;
      default = "exports";
      description = "Directory, relative to `root`, where generated exports are committed.";
    };
    evaluated = mkOption {
      type = types.raw;
      readOnly = true;
      internal = true;
      description = "The evaluated company (result of `lib.evalCompany`).";
    };
  };

  config = lib.mkIf (cfg.modules != []) {
    company.evaluated = eval;

    perSystem = {pkgs, ...}: let
      exports = companyLib.materialize {
        inherit pkgs;
        files = companyLib.checkedFiles eval;
      };

      updateExports = pkgs.writeShellApplication {
        name = "update-exports";
        runtimeInputs = [pkgs.coreutils pkgs.git];
        text = ''
          root="$(git rev-parse --show-toplevel)"
          target="$root/${cfg.exportsDir}"
          rm -rf -- "$target"
          mkdir -p "$target"
          cp -R --no-preserve=mode,ownership ${exports}/. "$target/"
          echo "Exports written to ${cfg.exportsDir}/ (git add them so the flake can see them)."
        '';
      };
    in {
      packages = {
        inherit exports;
        spec = pkgs.runCommand "company-spec.json" {} "cp ${exports}/spec.json $out";
        update-exports = updateExports;
      };

      apps.update-exports = {
        type = "app";
        program = lib.getExe updateExports;
        meta.description = "Regenerate the committed exports directory";
      };

      ## Every export checked against the standard it targets, plus the
      ## framework's OPA policies.
      checks.company-exports-valid = (import ./lib/validate.nix {inherit pkgs;}).check {inherit exports;};

      checks.company-exports-drift =
        if builtins.pathExists committed
        then
          pkgs.runCommand "company-exports-drift" {} ''
            if ! diff -r ${committed} ${exports}; then
              echo "Committed exports in ${cfg.exportsDir}/ are stale." >&2
              echo "Run: nix run .#update-exports && git add ${cfg.exportsDir}" >&2
              exit 1
            fi
            touch $out
          ''
        else
          pkgs.runCommand "company-exports-drift" {} ''
            echo "No committed exports at ${cfg.exportsDir}/." >&2
            echo "Run: nix run .#update-exports && git add ${cfg.exportsDir}" >&2
            exit 1
          '';
    };
  };
}
