{
  lib,
  config,
  companyLib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (companyLib) graph refs;
  cfg = config.company;
  roleIds = builtins.attrNames cfg.roles;

  stepType = types.submodule {
    options = {
      id = mkOption {
        type = types.strMatching "[a-z][a-z0-9-]*";
        example = "approve-access";
        description = "Step id, unique within the process (lowercase, digits, dashes).";
      };
      title = mkOption {
        type = types.str;
        example = "Approve access";
        description = "What happens in this step.";
      };
      role = mkOption {
        type = types.str;
        example = "platform";
        description = "Role id that performs the step.";
      };
      kind = mkOption {
        type = types.enum ["task" "approval" "automated" "decision"];
        default = "task";
        description = ''
          `task`: a person does something. `approval`: `approvers` sign off.
          `automated`: a system does it. `decision`: branches to one of `next`.
        '';
      };
      approvers = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["founder"];
        description = "Role ids that must approve (required for `approval` steps).";
      };
      slaHours = mkOption {
        type = types.nullOr types.ints.positive;
        default = null;
        example = 24;
        description = "Time limit for the step, in hours.";
      };
      next = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["provision"];
        description = "Following step ids. Only `decision` steps may have more than one; empty ends the process.";
      };
    };
  };
in {
  options.company.processes = mkOption {
    default = {};
    description = "Repeatable business processes as directed acyclic graphs of steps.";
    type = types.attrsOf (types.submodule {
      options = {
        title = mkOption {
          type = types.str;
          example = "Employee onboarding";
          description = "Process title.";
        };
        owner = mkOption {
          type = types.str;
          example = "operations";
          description = "Role id accountable for the process.";
        };
        doc = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "processes/docs/onboarding.md";
          description = "Markdown runbook, relative to `company.root`.";
        };
        trigger = mkOption {
          type = types.enum ["manual" "schedule" "event"];
          default = "manual";
          description = "What starts the process.";
        };
        inputs = mkOption {
          default = {};
          description = "Data the process starts with, keyed by name.";
          type = types.attrsOf (types.submodule {
            options = {
              type = mkOption {
                type = types.enum ["string" "number" "integer" "boolean" "object" "array"];
                default = "string";
                description = "JSON Schema type of the input.";
              };
              description = mkOption {
                type = types.str;
                example = "New hire's person id.";
                description = "What the input is.";
              };
              required = mkOption {
                type = types.bool;
                default = true;
                description = "Whether the process cannot start without it.";
              };
            };
          });
        };
        steps = mkOption {
          type = types.nonEmptyListOf stepType;
          description = "Steps in order; the first step is the entry point.";
        };
      };
    });
  };

  config.assertions = lib.concatLists (lib.mapAttrsToList (pid: p: let
    what = "process '${pid}'";
    stepIds = map (s: s.id) p.steps;
    edges = lib.listToAttrs (map (s: lib.nameValuePair s.id s.next) p.steps);
    cycle = graph.cyclicNodes edges;
    unreachable = lib.subtractLists (graph.reachable edges (builtins.head stepIds)) stepIds;
    dupes = lib.unique (lib.filter (id: lib.count (x: x == id) stepIds > 1) stepIds);
    stepChecks = lib.concatMap (s: let
      sw = "${what} step '${s.id}'";
    in
      [(refs.refersTo roleIds "${sw} role" "role" s.role)]
      ++ map (refs.refersTo roleIds "${sw} approvers" "role") s.approvers
      ++ map (refs.refersTo stepIds "${sw} next" "step") s.next
      ++ lib.optional (s.kind == "approval") (refs.check (s.approvers != []) "${sw} is an approval with no approvers")
      ++ lib.optional (s.kind != "decision") (refs.check (builtins.length s.next <= 1) "${sw} has several next steps but is not a decision")
      ++ lib.optional (s.kind == "decision") (refs.check (builtins.length s.next >= 2) "${sw} is a decision with fewer than two next steps"))
    p.steps;
  in
    ## Serverless Workflow requires DNS-label-style document names.
    [(refs.check (builtins.match "[a-z0-9](-?[a-z0-9])*" pid != null) "${what} id must be lowercase letters, digits and single dashes")]
    ++ refs.owner roleIds what p.owner
    ++ refs.docExists cfg.root what p.doc
    ++ [
      (refs.check (dupes == []) "${what} has duplicate step ids: ${lib.concatStringsSep ", " dupes}")
      (refs.check (cycle == []) "${what} steps are not a DAG; cycle involving: ${lib.concatStringsSep ", " cycle}")
      (refs.check (unreachable == []) "${what} has steps unreachable from '${builtins.head stepIds}': ${lib.concatStringsSep ", " unreachable}")
    ]
    ++ stepChecks)
  cfg.processes);
}
