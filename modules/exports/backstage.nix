## Backstage software catalog (backstage.io/v1alpha1).
## Roles -> Group, current people -> User, domains -> Domain plus a System of
## the same name grouping that domain's components, infrastructure systems ->
## Resource, every other system -> Component.
{
  lib,
  config,
  companyLib,
  ...
}: let
  cfg = config.company;
  d = companyLib.derive cfg;

  entity = kind: name: metadata: spec: {
    apiVersion = "backstage.io/v1alpha1";
    inherit kind spec;
    metadata = {inherit name;} // metadata;
  };
  group = role: "group:default/${role}";
  isResource = id: cfg.systems.${id}.type == "infrastructure";
  ref = id: "${
    if isResource id
    then "resource"
    else "component"
  }:default/${id}";

  systemEntity = id: s: let
    kind =
      if isResource id
      then "Resource"
      else "Component";
    metadata =
      {inherit (s) description;}
      // lib.optionalAttrs (s.repo != null) {annotations."github.com/project-slug" = s.repo;}
      // lib.optionalAttrs (s.links != {}) {links = lib.mapAttrsToList (title: url: {inherit title url;}) s.links;};
    spec =
      {
        type =
          if isResource id
          then "infrastructure"
          else s.type;
        owner = group s.owner;
        dependsOn = map ref s.dependsOn;
      }
      // lib.optionalAttrs (!isResource id) {inherit (s) lifecycle;}
      // lib.optionalAttrs (s.domain != null) {system = "system:default/${s.domain}";};
  in
    entity kind id metadata spec;

  stream = docs: {
    format = "yaml-stream";
    value = docs;
  };
  nonEmpty = path: docs: lib.optionalAttrs (docs != []) {${path} = stream docs;};
in {
  options.company.exports.backstage.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to export a Backstage catalog under `catalog/`.";
  };

  config.output.files = lib.mkIf cfg.exports.backstage.enable (
    nonEmpty "catalog/users.yaml" (lib.mapAttrsToList (id: p:
      entity "User" id {} {
        profile = {inherit (p) displayName email;};
        memberOf = map group p.roles;
      })
    d.currentPeople)
    // nonEmpty "catalog/groups.yaml" (lib.mapAttrsToList (id: r:
      entity "Group" id {inherit (r) description;} ({
          type = "team";
          children = map group (d.childrenOf id);
        }
        // lib.optionalAttrs (r.parent != null) {parent = group r.parent;}))
    cfg.roles)
    // nonEmpty "catalog/domains.yaml" (lib.mapAttrsToList (id: dom: entity "Domain" id {inherit (dom) description;} {owner = group dom.owner;}) cfg.domains)
    // nonEmpty "catalog/systems.yaml" (lib.mapAttrsToList (id: dom:
      entity "System" id {inherit (dom) description;} {
        owner = group dom.owner;
        domain = "domain:default/${id}";
      })
    cfg.domains)
    // nonEmpty "catalog/components.yaml" (lib.mapAttrsToList systemEntity (lib.filterAttrs (id: _: !isResource id) cfg.systems))
    // nonEmpty "catalog/resources.yaml" (lib.mapAttrsToList systemEntity (lib.filterAttrs (id: _: isResource id) cfg.systems))
  );
}
