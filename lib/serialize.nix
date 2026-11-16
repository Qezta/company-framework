## Pure-Nix JSON and YAML writers. Exports must be byte-identical on every
## platform, so they can't depend on whichever jq/remarshal version a
## platform's nixpkgs ships (remarshal in nixpkgs 26.11 started emitting a
## `%YAML 1.1` header that 26.05's doesn't).
{lib}: let
  inherit (builtins) isAttrs isList isString isBool attrNames concatStringsSep toJSON match;

  ## Pretty JSON: 2-space indent, sorted keys (attrNames is sorted).
  toPrettyJSON = let
    go = indent: v: let
      inner = indent + "  ";
    in
      if isAttrs v
      then
        if v == {}
        then "{}"
        else "{\n${concatStringsSep ",\n" (map (k: "${inner}${toJSON k}: ${go inner v.${k}}") (attrNames v))}\n${indent}}"
      else if isList v
      then
        if v == []
        then "[]"
        else "[\n${concatStringsSep ",\n" (map (x: "${inner}${go inner x}") v)}\n${indent}]"
      else toJSON v;
  in
    v: go "" v + "\n";

  ## Block-style YAML. Strings are always double-quoted (JSON string syntax
  ## is valid YAML), so no value can be misread as a bool, number or null.
  ## Keys are plain unless quoting is needed.
  yamlKeyWords = ["y" "n" "yes" "no" "on" "off" "true" "false" "null"];
  yamlKey = k:
    if match "[A-Za-z_][A-Za-z0-9_./-]*" k != null && !(builtins.elem (lib.toLower k) yamlKeyWords)
    then k
    else toJSON k;
  isBlock = v: (isAttrs v && v != {}) || (isList v && v != []);
  inline = v:
    if isAttrs v
    then "{}"
    else if isList v
    then "[]"
    else if v == null
    then "null"
    else if isBool v || isString v
    then toJSON v
    else toJSON v;

  ## Lines of a block value, each prefixed with `indent`.
  yamlLines = indent: v:
    if isAttrs v
    then
      lib.concatMap (k: let
        x = v.${k};
      in
        if isBlock x
        then ["${indent}${yamlKey k}:"] ++ yamlLines "${indent}  " x
        else ["${indent}${yamlKey k}: ${inline x}"])
      (attrNames v)
    else
      lib.concatMap (x:
        if isAttrs x && x != {}
        then let
          ls = yamlLines "${indent}  " x;
        in
          ["${indent}- ${lib.removePrefix "${indent}  " (builtins.head ls)}"] ++ builtins.tail ls
        else if isList x && x != []
        then ["${indent}-"] ++ yamlLines "${indent}  " x
        else ["${indent}- ${inline x}"])
      v;

  toYAML = v:
    if isBlock v
    then lib.concatLines (yamlLines "" v)
    else inline v + "\n";
in {
  inherit toPrettyJSON toYAML;
  toYAMLStream = docs: concatStringsSep "---\n" (map toYAML docs);
}
