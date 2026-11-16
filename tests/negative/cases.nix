## Each case overlays a deliberately broken module on examples/acme.
## `expect` is a substring of the assertion message that must be reported;
## null means evaluation itself must fail (type errors carry no assertion).
let
  person = extra:
    {
      displayName = "Test Person";
      email = "test@acme.example";
    }
    // extra;
  step = id: extra:
    {
      inherit id;
      title = id;
      role = "operations";
    }
    // extra;
  process = steps: {
    title = "Broken";
    owner = "operations";
    inherit steps;
  };
  slo = extra:
    {
      system = "website";
      description = "x";
      indicator = "custom";
      target = 0.9;
      metricSource = {
        type = "Prometheus";
        spec = {
          good = "g";
          total = "t";
        };
      };
    }
    // extra;
in [
  {
    name = "dangling-person-role";
    expect = "person 'ghost' references unknown role 'nobody'";
    module.company.people.ghost = person {roles = ["nobody"];};
  }
  {
    name = "former-without-enddate";
    expect = "person 'olden' is former but has no endDate";
    module.company.people.olden = person {status = "former";};
  }
  {
    name = "cyclic-roles";
    expect = "role parent graph has a cycle";
    module.company.roles = {
      a = {
        description = "a";
        parent = "b";
      };
      b = {
        description = "b";
        parent = "a";
      };
    };
  }
  {
    name = "self-parent-role";
    expect = "role parent graph has a cycle involving: narcissus";
    module.company.roles.narcissus = {
      description = "own parent";
      parent = "narcissus";
    };
  }
  {
    name = "dangling-role-parent";
    expect = "role 'orphan' parent references unknown role 'missing'";
    module.company.roles.orphan = {
      description = "orphan";
      parent = "missing";
    };
  }
  {
    name = "system-missing-owner";
    expect = "system 'nobodys' has no owner";
    module.company.systems.nobodys = {
      description = "x";
      type = "tool";
      owner = "";
    };
  }
  {
    name = "domain-unknown-owner";
    expect = "domain 'sales' owner references unknown role 'sales-team'";
    module.company.domains.sales = {
      description = "x";
      owner = "sales-team";
    };
  }
  {
    name = "system-unknown-domain";
    expect = "system 'lost' domain references unknown domain 'nowhere'";
    module.company.systems.lost = {
      description = "x";
      type = "tool";
      owner = "engineering";
      domain = "nowhere";
    };
  }
  {
    name = "system-unknown-dependency";
    expect = "system 'needy' dependsOn references unknown system 'ghost-api'";
    module.company.systems.needy = {
      description = "x";
      type = "service";
      owner = "engineering";
      dependsOn = ["ghost-api"];
    };
  }
  {
    name = "codeowners-unknown-role";
    expect = "system 'owned' codeowners 'docs/' references unknown role 'writers'";
    module.company.systems.owned = {
      description = "x";
      type = "tool";
      owner = "engineering";
      codeowners = [
        {
          pattern = "docs/";
          owners = ["writers"];
        }
      ];
    };
  }
  {
    name = "bad-date";
    expect = "person 'feb' startDate is not a valid ISO 8601 date: '2026-02-30'";
    module.company.people.feb = person {startDate = "2026-02-30";};
  }
  {
    name = "start-after-end";
    expect = "person 'backwards' has startDate 2026-05-01 after endDate 2026-04-01";
    module.company.people.backwards = person {
      startDate = "2026-05-01";
      endDate = "2026-04-01";
    };
  }
  {
    name = "duplicate-team-slug";
    expect = "GitHub team slug 'engineering' is used by multiple roles: eng2, engineering";
    module.company.roles.eng2 = {
      description = "duplicate";
      githubTeam = "engineering";
    };
  }
  {
    name = "github-role-without-user";
    expect = "person 'nogh' holds a GitHub-mapped role but has no githubUser";
    module.company.people.nogh = person {roles = ["engineering"];};
  }
  {
    name = "bad-email";
    expect = "person 'mailless' has an invalid email address: 'not-an-email'";
    module.company.people.mailless = person {email = "not-an-email";};
  }
  {
    name = "bad-hex-color";
    expect = "brand color 'accent' is not a hex color: 'red'";
    module.company.entity.brand.colors.accent = "red";
  }
  {
    name = "bad-repo-format";
    expect = "system 'norepo' repo must look like 'Org/name'";
    module.company.systems.norepo = {
      description = "x";
      type = "tool";
      owner = "engineering";
      repo = "just-a-name";
    };
  }
  {
    name = "invalid-enum";
    expect = null;
    module.company.people.weird = person {status = "on-sabbatical";};
  }
  {
    name = "process-cycle";
    expect = "process 'loop' steps are not a DAG";
    module.company.processes.loop = process [
      (step "a" {next = ["b"];})
      (step "b" {next = ["a"];})
    ];
  }
  {
    name = "process-unreachable-step";
    expect = "process 'island' has steps unreachable from 'start': stranded";
    module.company.processes.island = process [
      (step "start" {})
      (step "stranded" {})
    ];
  }
  {
    name = "process-unknown-next";
    expect = "process 'lost' step 'a' next references unknown step 'nowhere'";
    module.company.processes.lost = process [(step "a" {next = ["nowhere"];})];
  }
  {
    name = "process-duplicate-steps";
    expect = "process 'twice' has duplicate step ids: a";
    module.company.processes.twice = process [
      (step "a" {next = ["a"];})
      (step "a" {})
    ];
  }
  {
    name = "approval-without-approvers";
    expect = "process 'nod' step 'ok' is an approval with no approvers";
    module.company.processes.nod = process [(step "ok" {kind = "approval";})];
  }
  {
    name = "branching-non-decision";
    expect = "process 'fork' step 'a' has several next steps but is not a decision";
    module.company.processes.fork = process [
      (step "a" {next = ["b" "c"];})
      (step "b" {})
      (step "c" {})
    ];
  }
  {
    name = "decision-with-one-branch";
    expect = "process 'choice' step 'pick' is a decision with fewer than two next steps";
    module.company.processes.choice = process [
      (step "pick" {
        kind = "decision";
        next = ["b"];
      })
      (step "b" {})
    ];
  }
  {
    name = "process-bad-id";
    expect = "process 'Bad_Id' id must be lowercase letters, digits and single dashes";
    module.company.processes.Bad_Id = process [(step "a" {})];
  }
  {
    name = "process-unknown-role";
    expect = "process 'who' step 'a' role references unknown role 'ghosts'";
    module.company.processes.who = process [(step "a" {role = "ghosts";})];
  }
  {
    name = "slo-unknown-system";
    expect = "slo 'phantom' system references unknown system 'nope'";
    module.company.reliability.slos.phantom = slo {system = "nope";};
  }
  {
    name = "slo-target-out-of-range";
    expect = "slo 'greedy' target must be between 0 and 1";
    module.company.reliability.slos.greedy = slo {target = 1.0;};
  }
  {
    name = "slo-bad-window";
    expect = "slo 'when' window is not a duration like '28d': 'monthly'";
    module.company.reliability.slos.when = slo {window = "monthly";};
  }
  {
    name = "slo-missing-queries";
    expect = "slo 'blind' metricSource.spec needs 'good' and 'total' queries";
    module.company.reliability.slos.blind = slo {
      metricSource = {
        type = "Prometheus";
        spec = {};
      };
    };
  }
  {
    name = "bad-currency";
    expect = "pricing currency must be an ISO 4217 code like 'INR', got 'rupees'";
    module = {lib, ...}: {company.pricing.currency = lib.mkForce "rupees";};
  }
  {
    name = "policy-unknown-owner";
    expect = "policy 'orphaned' owner references unknown role 'legal'";
    module.company.policies.orphaned = {
      title = "x";
      owner = "legal";
    };
  }
  {
    name = "policy-missing-doc";
    expect = "policy 'paper' doc does not exist: 'policies/missing.md'";
    module.company.policies.paper = {
      title = "x";
      owner = "founder";
      doc = "policies/missing.md";
    };
  }
  {
    name = "policy-bad-review-date";
    expect = "policy 'stale' lastReviewed is not a valid ISO 8601 date: 'last year'";
    module.company.policies.stale = {
      title = "x";
      owner = "founder";
      lastReviewed = "last year";
    };
  }
  {
    name = "missing-decisions-dir";
    expect = "decisionsDir 'adr' does not exist under company.root";
    module = {lib, ...}: {company.decisionsDir = lib.mkForce "adr";};
  }
  {
    name = "pirol-enabled";
    expect = "the Pirol exporter is not implemented yet";
    module.company.exports.pirol.enable = true;
  }
  {
    name = "document-missing-source";
    expect = "document 'ghost' source does not exist under company.root: 'legal/ghost.md'";
    module.company.documents.ghost = {
      title = "x";
      source = "legal/ghost.md";
    };
  }
  {
    name = "document-unknown-placeholder";
    expect = "document 'typo' has an unknown placeholder '{{ entity.legalname }}'";
    module.company.documents.typo = {
      title = "x";
      source = "legal/typo.md";
    };
  }
]
