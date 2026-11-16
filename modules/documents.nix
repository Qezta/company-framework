## Prose documents (legal drafts, notices) written in Markdown with
## `{{ entity.<path> }}` placeholders, rendered by the documents exporter.
## Only `entity` is exposed, plus `entity.primaryDomain` (first domain).
{
  lib,
  config,
  companyLib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (companyLib) refs;
  cfg = config.company;

  placeholder = "\\{\\{[[:space:]]*([A-Za-z0-9_.]+)[[:space:]]*\\}\\}";
  context.entity =
    cfg.entity
    // {
      primaryDomain =
        if cfg.entity.domains == []
        then null
        else builtins.head cfg.entity.domains;
    };
  ## Distinguish "known path, unset" (null) from "no such path" (missing).
  missing = {__missing = true;};
  lookup = path: lib.attrByPath (lib.splitString "." path) missing context;
  render = text:
    lib.concatMapStrings (part:
      if builtins.isList part
      then let
        path = builtins.head part;
        v = lookup path;
      in
        if builtins.isString v || builtins.isInt v
        then toString v
        else "[TODO: ${path}]"
      else part)
    (builtins.split placeholder text);
  placeholders = text: map builtins.head (lib.filter builtins.isList (builtins.split placeholder text));
  source = d: cfg.root + "/${d.source}";
  readable = d: cfg.root != null && builtins.pathExists (source d);
in {
  options.company.documents = mkOption {
    default = {};
    description = ''
      Markdown documents rendered with company facts. In the source file,
      `{{ entity.legalName }}`-style placeholders are replaced with values
      from `company.entity` (plus `entity.primaryDomain`). Unset values render
      as a visible `[TODO: …]` marker and produce a warning.
    '';
    type = types.attrsOf (types.submodule {
      options = {
        title = mkOption {
          type = types.str;
          example = "Privacy policy";
          description = "Document title.";
        };
        source = mkOption {
          type = types.str;
          example = "legal/privacy-policy.md";
          description = "Markdown source with placeholders, relative to `company.root`.";
        };
      };
    });
  };

  options.company.renderedDocuments = mkOption {
    type = types.attrsOf types.str;
    readOnly = true;
    internal = true;
    description = "Rendered text of each document, keyed by id.";
  };

  config = {
    company.renderedDocuments = lib.mapAttrs (_: d:
      if readable d
      then render (builtins.readFile (source d))
      else "")
    cfg.documents;

    assertions = lib.concatLists (lib.mapAttrsToList (id: d: let
      what = "document '${id}'";
    in
      [(refs.check (readable d) "${what} source does not exist under company.root: '${d.source}'")]
      ++ lib.optionals (readable d) (map (path:
        refs.check (lookup path != missing) "${what} has an unknown placeholder '{{ ${path} }}'")
      (placeholders (builtins.readFile (source d)))))
    cfg.documents);

    warnings = lib.concatLists (lib.mapAttrsToList (id: d: let
      unset = lib.unique (lib.filter (path: lookup path == null) (placeholders (builtins.readFile (source d))));
    in
      lib.optional (readable d && unset != []) "document '${id}' has unset placeholders: ${lib.concatStringsSep ", " unset}")
    cfg.documents);
  };
}
