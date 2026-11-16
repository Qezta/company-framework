## A FICTIONAL company that exercises every option. All names, addresses and
## identifiers are invented; domains use the reserved example.* TLDs (RFC 2606).
{
  company = {
    root = ./.;
    asOf = "2026-11-16";
    decisionsDir = "decisions";

    entity = {
      name = "Acme";
      legalName = "Acme Widgets Private Limited";
      shortName = "acme";
      description = "Acme makes configurable widgets for small workshops.";
      jurisdiction = "IN-KA";
      registration.cin = "EXAMPLE-CIN-0000";
      domains = ["acme.example" "acme-widgets.example"];
      contacts = {
        general = "hello@acme.example";
        security = "security@acme.example";
        legal = "legal@acme.example";
        privacy = "privacy@acme.example";
      };
      links = {
        website = "https://acme.example";
        github = "https://github.com/acme-example";
      };
      brand = {
        colors = {
          primary = "#ff0052";
          background = "#060606";
          text = "#ccc";
        };
        fonts = {
          heading = "Roboto Flex";
          body = "Roboto";
        };
        logo = "assets/logo.svg";
      };
    };

    roles = {
      founder = {
        description = "Sets direction and is ultimately accountable for everything.";
        githubTeam = "founders";
        githubPermission = "admin";
        responsibilities = ["Company strategy" "Final approval on hires and spend"];
      };
      engineering = {
        description = "Builds and runs the product.";
        parent = "founder";
        githubTeam = "engineering";
        githubPermission = "maintain";
        responsibilities = ["Ship and operate the product" "Review pull requests"];
      };
      platform = {
        description = "Owns infrastructure, CI and developer tooling.";
        parent = "engineering";
        githubTeam = "platform";
        githubPermission = "push";
        responsibilities = ["Keep infrastructure declarative" "Run incident response"];
      };
      operations = {
        description = "Keeps the business running day to day.";
        parent = "founder";
        responsibilities = ["Vendor management" "Customer support"];
      };
      finance = {
        description = "Books, invoicing and tax.";
        parent = "operations";
        responsibilities = ["Monthly close" "GST filings"];
      };
    };

    people = {
      asha = {
        displayName = "Asha Rao";
        email = "asha@acme.example";
        githubUser = "asha-acme-example";
        roles = ["founder" "engineering"];
        startDate = "2026-01-05";
      };
      bilal = {
        displayName = "Bilal Khan";
        email = "bilal@acme.example";
        githubUser = "bilal-acme-example";
        roles = ["platform"];
        status = "onboarding";
        startDate = "2026-11-10";
      };
      chen = {
        displayName = "Chen Li";
        email = "chen@acme.example";
        roles = ["finance"];
        startDate = "2026-03-01";
      };
      dana = {
        displayName = "Dana Iyer";
        email = "dana@acme.example";
        githubUser = "dana-acme-example";
        roles = ["engineering"];
        status = "former";
        startDate = "2026-02-01";
        endDate = "2026-08-31";
      };
    };

    domains = {
      web = {
        description = "Everything customers see in a browser.";
        owner = "engineering";
      };
      platform = {
        description = "Infrastructure and internal tooling.";
        owner = "platform";
      };
    };

    policies = {
      access-control = {
        title = "Access control";
        owner = "founder";
        doc = "policies/access-control.md";
        reviewEveryDays = 180;
        lastReviewed = "2026-09-01";
        rules = {
          adminAllowed = ["founder"];
          requireTwoFactor = true;
        };
      };
      acceptable-use = {
        title = "Acceptable use";
        owner = "operations";
        doc = "policies/acceptable-use.md";
        ## Deliberately overdue so the example shows the warning.
        reviewEveryDays = 90;
        lastReviewed = "2026-01-10";
      };
    };

    processes = {
      onboarding = {
        title = "Employee onboarding";
        owner = "operations";
        doc = "processes/docs/onboarding.md";
        trigger = "event";
        inputs = {
          person = {
            description = "Person id of the new hire in company.people.";
          };
          needsHardware = {
            type = "boolean";
            description = "Whether a laptop must be shipped.";
            required = false;
          };
        };
        steps = [
          {
            id = "collect-details";
            title = "Collect details and documents";
            role = "operations";
            slaHours = 48;
            next = ["approve-access"];
          }
          {
            id = "approve-access";
            title = "Approve GitHub and tool access";
            role = "founder";
            kind = "approval";
            approvers = ["founder"];
            slaHours = 24;
            next = ["provision-accounts"];
          }
          {
            id = "provision-accounts";
            title = "Provision accounts from the spec";
            role = "platform";
            kind = "automated";
            next = ["hardware"];
          }
          {
            id = "hardware";
            title = "Needs hardware?";
            role = "operations";
            kind = "decision";
            next = ["ship-laptop" "welcome"];
          }
          {
            id = "ship-laptop";
            title = "Ship laptop";
            role = "operations";
            slaHours = 72;
            next = ["welcome"];
          }
          {
            id = "welcome";
            title = "Welcome call";
            role = "founder";
          }
        ];
      };
      incident = {
        title = "Incident response";
        owner = "platform";
        steps = [
          {
            id = "triage";
            title = "Triage and assign severity";
            role = "platform";
            slaHours = 1;
            next = ["mitigate"];
          }
          {
            id = "mitigate";
            title = "Mitigate";
            role = "engineering";
            next = ["postmortem"];
          }
          {
            id = "postmortem";
            title = "Write postmortem";
            role = "engineering";
            slaHours = 120;
          }
        ];
      };
    };

    reliability.slos = {
      website-availability = {
        system = "website";
        description = "acme.example serves successful responses";
        indicator = "http-availability";
        target = 0.995;
        metricSource = {
          type = "Prometheus";
          spec = {
            good = "sum(rate(http_requests_total{job=\"website\",code!~\"5..\"}[5m]))";
            total = "sum(rate(http_requests_total{job=\"website\"}[5m]))";
          };
        };
      };
      infra-apply-success = {
        system = "infra";
        description = "Infrastructure applies succeed";
        indicator = "custom";
        target = 0.99;
        window = "4w";
        metricSource = {
          type = "Prometheus";
          spec = {
            good = "sum(ci_apply_total{result=\"success\"})";
            total = "sum(ci_apply_total)";
          };
        };
      };
    };

    documents.terms = {
      title = "Terms of service";
      source = "legal/terms.md";
    };

    pricing = {
      currency = "INR";
      plans = {
        starter = {
          name = "Starter";
          priceMinor = 49900;
          features = ["One workshop" "Email support"];
        };
        workshop = {
          name = "Workshop";
          priceMinor = 499000;
          interval = "year";
          features = ["Up to five workshops" "Priority support"];
        };
        setup = {
          name = "Setup";
          priceMinor = 1500000;
          interval = "one-time";
          features = ["On-site installation"];
        };
      };
    };

    systems = {
      website = {
        description = "Marketing website at acme.example.";
        type = "website";
        lifecycle = "production";
        domain = "web";
        owner = "engineering";
        repo = "acme-example/website";
        codeowners = [
          {
            pattern = "*";
            owners = ["engineering"];
          }
          {
            pattern = "/content/legal/";
            owners = ["founder"];
          }
        ];
        dependsOn = ["ui" "infra"];
        links.live = "https://acme.example";
      };
      ui = {
        description = "Shared component library.";
        type = "library";
        domain = "web";
        owner = "engineering";
        repo = "acme-example/ui";
      };
      infra = {
        description = "DNS, repositories and CI as code.";
        type = "infrastructure";
        lifecycle = "production";
        domain = "platform";
        owner = "platform";
        repo = "acme-example/infra";
      };
      handbook = {
        description = "Internal handbook.";
        type = "documentation";
        lifecycle = "deprecated";
        owner = "operations";
      };
    };
  };
}
