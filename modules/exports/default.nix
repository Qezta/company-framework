## Export plumbing: every exporter adds entries to `output.files`, which
## `companyLib.materialize` turns into a directory tree.
{lib, ...}: let
  inherit (lib) mkOption types;
  isSafePath = p: !(lib.hasPrefix "/" p) && !(lib.hasInfix ".." p) && p != "";
in {
  imports = [
    ./spec-json.nix
    ./backstage.nix
    ./scim.nix
    ./codeowners.nix
    ./agents-md.nix
    ./pricing.nix
    ./opa.nix
    ./serverless-workflow.nix
    ./mermaid.nix
    ./openslo.nix
    ./documents.nix
    ./pirol.nix
  ];

  options.output.files = mkOption {
    type = types.addCheck (types.attrsOf (types.submodule {
      options = {
        format = mkOption {
          type = types.enum ["json" "yaml" "yaml-stream" "text"];
          description = "Serialization format.";
        };
        value = mkOption {
          type = types.anything;
          description = "Data to serialize: a string for `text`, a list of documents for `yaml-stream`.";
        };
      };
    })) (files: lib.all isSafePath (lib.attrNames files));
    default = {};
    internal = true;
    description = "Export files keyed by path relative to the export root.";
  };
}
