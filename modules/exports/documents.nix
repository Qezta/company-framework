## Rendered documents under documents/<id>.md.
{
  lib,
  config,
  ...
}: let
  cfg = config.company;
in {
  options.company.exports.documents.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to export rendered documents under `documents/`.";
  };

  config.output.files = lib.mkIf cfg.exports.documents.enable (lib.mapAttrs' (id: text:
    lib.nameValuePair "documents/${id}.md" {
      format = "text";
      value = text;
    })
  cfg.renderedDocuments);
}
