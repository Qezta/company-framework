package policies.company_test

import data.policies.company

fixture := {
	"asOf": "2026-06-01",
	"people": {"ada": {"status": "active", "roles": ["founder"], "githubUser": "ada"}},
	"roles": {"founder": {"parent": null, "githubTeam": "founders", "githubPermission": "admin"}},
	"systems": {"site": {"type": "website", "lifecycle": "production", "owner": "founder", "repo": "org/site"}},
	"slos": {"site-up": {"system": "site", "target": 0.99, "window": "28d"}},
	"policies": {"access": {
		"title": "Access",
		"owner": "founder",
		"reviewEveryDays": 30,
		"lastReviewed": "2026-05-20",
		"rules": {"adminAllowed": ["founder"]},
	}},
}

# object.union merges nested objects; replace a top-level field outright.
with_field(key, value) := object.union(object.remove(fixture, [key]), {key: value})

test_clean_fixture_passes if {
	count(company.deny) == 0 with data.company as fixture
	count(company.warn) == 0 with data.company as fixture
}

test_current_person_without_roles_denied if {
	bo := {"status": "onboarding", "roles": [], "githubUser": null}
	people := object.union(fixture.people, {"bo": bo})
	msg := "person \"bo\" is onboarding but has no roles"
	msg in company.deny with data.company as object.union(fixture, {"people": people})
}

test_former_person_without_roles_allowed if {
	old := {"status": "former", "roles": [], "githubUser": null}
	people := object.union(fixture.people, {"old": old})
	count(company.deny) == 0 with data.company as object.union(fixture, {"people": people})
}

test_production_system_without_slo_denied if {
	"production system \"site\" has no SLO" in company.deny with data.company as with_field("slos", {})
}

test_experimental_system_without_slo_allowed if {
	systems := {"lab": {"type": "tool", "lifecycle": "experimental", "owner": "founder", "repo": null}}
	no_slos := object.union(object.remove(fixture, ["systems", "slos"]), {"systems": systems, "slos": {}})
	count(company.deny) == 0 with data.company as no_slos
}

test_admin_outside_allow_list_denied if {
	eng := {"parent": "founder", "githubTeam": "eng", "githubPermission": "admin"}
	roles := object.union(fixture.roles, {"eng": eng})
	msg := "role \"eng\" has GitHub admin but is not listed in any policy's rules.adminAllowed"
	msg in company.deny with data.company as object.union(fixture, {"roles": roles})
}

test_overdue_policy_warns if {
	msg := "policy \"access\" review is overdue (last reviewed 2026-05-20, due every 30 days)"
	msg in company.warn with data.company as object.union(fixture, {"asOf": "2026-07-01"})
}
