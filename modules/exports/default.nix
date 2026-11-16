## Export plumbing: every exporter adds entries to `output.files`, which
## `companyLib.materialize` turns into a directory tree.
{lib, ...}: let
  inherit (lib) mkOption types;
  isSafePath = p: !(lib.hasPrefix "/" p) && !(lib.hasInfix ".." p) && p != "";
in {
  imports = [
    ./spec-json.nix
  ];

  options.output.files = mkOption {
    type = types.addCheck (types.attrsOf (types.submodule {
      options = {
        format = mkOption {
          type = types.enum ["json" "yaml" "text"];
          description = "Serialization format.";
        };
        value = mkOption {
          type = types.anything;
          description = "Data to serialize (a string for `text`).";
        };
      };
    })) (files: lib.all isSafePath (lib.attrNames files));
    default = {};
    internal = true;
    description = "Export files keyed by path relative to the export root.";
  };
}
