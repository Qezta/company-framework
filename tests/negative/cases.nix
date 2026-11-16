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
]
