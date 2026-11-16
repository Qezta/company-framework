## Core entry point. Depends only on nixpkgs `lib` (no flake-parts, no pkgs),
## so it works from plain flakes, NixOS configs, or non-flake Nix.
{lib}:
lib.fix (self: {
  ## Version of the spec.json format this framework emits.
  specVersion = "0.1.0";

  dates = import ./dates.nix {inherit lib;};
  graph = import ./graph.nix {inherit lib;};
  refs = import ./refs.nix {inherit lib;};
  derive = import ./derive.nix {inherit lib;};

  ## Evaluate company modules against the framework's option tree.
  evalCompany = {
    modules,
    specialArgs ? {},
  }:
    lib.evalModules {
      modules = [../modules] ++ modules;
      specialArgs = {companyLib = self;} // specialArgs;
    };

  ## Messages of every assertion that does not hold. Never throws for
  ## assertion failures, which is what lets negative tests match messages.
  failedAssertions = config: map (a: a.message) (lib.filter (a: !a.assertion) config.assertions);

  ## The export file map, once all assertions hold. Warnings are printed.
  checkedFiles = eval: let
    failed = self.failedAssertions eval.config;
  in
    if failed != []
    then throw "\nFailed company assertions:\n${lib.concatMapStrings (m: "- ${m}\n") failed}"
    else lib.foldr lib.warn eval.config.output.files eval.config.warnings;

  serialize = import ./serialize.nix {inherit lib;};

  ## Turn an export file map ({ "<rel/path>" = { format; value; }; }) into a
  ## directory derivation. Serialization is pure Nix (see serialize.nix), so
  ## the bytes don't depend on the platform's tool versions.
  materialize = {
    pkgs,
    files,
    name ? "company-exports",
  }: let
    text = file:
      if file.format == "json"
      then self.serialize.toPrettyJSON file.value
      else if file.format == "yaml"
      then self.serialize.toYAML file.value
      else if file.format == "yaml-stream"
      then self.serialize.toYAMLStream file.value
      else file.value;
    render = path: file: ''
      mkdir -p "$(dirname "$out/"${lib.escapeShellArg path})"
      cp ${pkgs.writeText "export" (text file)} "$out/"${lib.escapeShellArg path}
    '';
  in
    pkgs.runCommand name {} ''
      mkdir -p $out
      ${lib.concatStrings (lib.mapAttrsToList render files)}
    '';
})
