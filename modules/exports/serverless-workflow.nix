## CNCF Serverless Workflow DSL 1.0.3, one document per process.
## Human steps have no native task type, so:
##   task/approval -> `listen` for a "<step>.completed"/"<step>.approved" event
##   automated     -> `emit` a "<step>.requested" event for automation to act on
##   decision      -> `switch` on `.decision` naming the next step
## Role, kind and approvers ride along in task `metadata`; slaHours -> timeout.
{
  lib,
  config,
  companyLib,
  ...
}: let
  cfg = config.company;
  d = companyLib.derive cfg;

  eventType = pid: step: suffix: "${d.namespace}.${pid}.${step.id}.${suffix}";

  task = pid: step: let
    base =
      {
        metadata =
          {
            inherit (step) role kind;
          }
          // lib.optionalAttrs (step.approvers != []) {inherit (step) approvers;};
      }
      // lib.optionalAttrs (step.slaHours != null) {timeout.after.hours = step.slaHours;}
      // lib.optionalAttrs (step.kind != "decision") {
        "then" =
          if step.next == []
          then "end"
          else builtins.head step.next;
      };
    listen = suffix: {listen.to.one."with".type = eventType pid step suffix;};
    body =
      if step.kind == "task"
      then listen "completed"
      else if step.kind == "approval"
      then listen "approved"
      else if step.kind == "automated"
      then {
        emit.event."with" = {
          ## The DSL requires a scheme://-style URI here.
          source = "${d.namespace}://processes/${pid}";
          type = eventType pid step "requested";
        };
      }
      else {
        switch =
          map (n: {
            ${n} = {
              when = "\${ .decision == \"${n}\" }";
              "then" = n;
            };
          })
          step.next;
      };
  in {${step.id} = base // body;};

  workflow = pid: p:
    {
      document = {
        dsl = "1.0.3";
        inherit (d) namespace;
        name = pid;
        version = "0.1.0";
        inherit (p) title;
        metadata = {inherit (p) owner trigger;};
      };
      "do" = map (task pid) p.steps;
    }
    // lib.optionalAttrs (p.inputs != {}) {
      input.schema = {
        format = "json";
        document = {
          type = "object";
          properties = lib.mapAttrs (_: i: {inherit (i) type description;}) p.inputs;
          required = lib.attrNames (lib.filterAttrs (_: i: i.required) p.inputs);
        };
      };
    };
in {
  options.company.exports.serverlessWorkflow.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to export Serverless Workflow documents under `workflows/`.";
  };

  config.output.files = lib.mkIf cfg.exports.serverlessWorkflow.enable (lib.mapAttrs' (pid: p:
    lib.nameValuePair "workflows/${pid}.sw.yaml" {
      format = "yaml";
      value = workflow pid p;
    })
  cfg.processes);
}
