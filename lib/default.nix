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

  ## Turn an export file map ({ "<rel/path>" = { format; value; }; }) into a
  ## directory derivation. JSON goes through `jq -S` for stable, readable diffs.
  materialize = {
    pkgs,
    files,
    name ? "company-exports",
  }: let
    yaml = pkgs.formats.yaml {};
    render = path: file: let
      dest = "$out/${lib.escapeShellArg path}";
      src =
        if file.format == "json"
        then pkgs.writeText "export.json" (builtins.toJSON file.value)
        else if file.format == "yaml"
        then yaml.generate "export.yaml" file.value
        else if file.format == "yaml-stream"
        then
          pkgs.concatText "export.yaml" (lib.imap0 (i: doc:
            pkgs.runCommand "doc-${toString i}.yaml" {} ''
              ${lib.optionalString (i > 0) "echo --- > $out"}
              cat ${yaml.generate "doc.yaml" doc} >> $out
            '')
          file.value)
        else pkgs.writeText "export.txt" file.value;
      copy =
        if file.format == "json"
        then "jq -S . ${src} > ${dest}"
        else "cp ${src} ${dest}";
    in ''
      mkdir -p "$(dirname ${dest})"
      ${copy}
    '';
  in
    pkgs.runCommand name {nativeBuildInputs = [pkgs.jq];} ''
      mkdir -p $out
      ${lib.concatStrings (lib.mapAttrsToList render files)}
    '';
})
