## Architecture/business decision records discovered from Markdown files.
## Read with builtins.readFile on source paths: pure, no import-from-derivation.
{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (builtins) elemAt match;
  cfg = config.company;

  ## Minimal MADR reader: `key: value` lines of a leading `---` frontmatter
  ## block, plus the first `# ` heading as the title. Not a YAML parser.
  parse = file: text: let
    lines = lib.splitString "\n" text;
    hasFrontmatter = lines != [] && builtins.head lines == "---";
    endIdx = lib.lists.findFirstIndex (l: l == "---") null (builtins.tail lines);
    fmLines =
      if hasFrontmatter && endIdx != null
      then lib.sublist 1 endIdx lines
      else [];
    unquote = v: let
      m = match "[\"'](.*)[\"']" v;
    in
      if m == null
      then v
      else elemAt m 0;
    fields = lib.listToAttrs (lib.concatMap (l: let
      m = match "([A-Za-z_-]+):[[:space:]]*(.*[^[:space:]])[[:space:]]*" l;
    in
      lib.optional (m != null) (lib.nameValuePair (elemAt m 0) (unquote (elemAt m 1))))
    fmLines);
    heading = lib.findFirst (l: match "# .*" l != null) null lines;
  in {
    inherit file;
    title =
      if heading == null
      then file
      else lib.removePrefix "# " heading;
    status = fields.status or null;
    date = fields.date or null;
  };

  dir = cfg.decisionsDir;
  files =
    if cfg.root == null || dir == null || !builtins.pathExists (cfg.root + "/${dir}")
    then []
    else lib.sort (a: b: a < b) (builtins.attrNames (lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".md" n) (builtins.readDir (cfg.root + "/${dir}"))));
in {
  options.company = {
    decisionsDir = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "decisions";
      description = "Directory of MADR decision records, relative to `company.root`.";
    };
    decisions = mkOption {
      type = types.listOf (types.attrsOf (types.nullOr types.str));
      readOnly = true;
      description = "Decision records found in `decisionsDir` (file, title, status, date). Read-only.";
    };
  };

  config = {
    company.decisions = map (f: parse "${dir}/${f}" (builtins.readFile (cfg.root + "/${dir}/${f}"))) files;
    assertions = [
      {
        assertion = dir == null || (cfg.root != null && builtins.pathExists (cfg.root + "/${dir}"));
        message = "decisionsDir '${toString dir}' does not exist under company.root (is company.root set?)";
      }
    ];
  };
}
