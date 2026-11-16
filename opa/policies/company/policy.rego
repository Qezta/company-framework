# Generic company policies evaluated against exports/opa/data.json.
# `deny` must be empty for the company spec to pass; `warn` is advisory.
package policies.company

people := data.company.people

roles := data.company.roles

# Review dates are judged against company.asOf when set, else the clock.
today_ns := time.parse_ns("2006-01-02", data.company.asOf) if {
	data.company.asOf != null
} else := time.now_ns()

has_slo(system) if {
	some slo in data.company.slos
	slo.system == system
}

admin_allowed contains role if {
	some policy in data.company.policies
	some role in policy.rules.adminAllowed
}

# METADATA
# title: Company spec violations
# description: Must be empty for the company spec to pass.
# entrypoint: true
deny contains msg if {
	some id, person in people
	person.status != "former"
	count(person.roles) == 0
	msg := sprintf("person %q is %s but has no roles", [id, person.status])
}

deny contains msg if {
	some id, system in data.company.systems
	system.lifecycle == "production"
	not has_slo(id)
	msg := sprintf("production system %q has no SLO", [id])
}

deny contains msg if {
	some id, role in roles
	role.githubPermission == "admin"
	not id in admin_allowed
	msg := sprintf(
		"role %q has GitHub admin but is not listed in any policy's rules.adminAllowed",
		[id],
	)
}

warn contains msg if {
	some id, policy in data.company.policies
	policy.lastReviewed != null
	due := time.add_date(time.parse_ns("2006-01-02", policy.lastReviewed), 0, 0, policy.reviewEveryDays)
	due < today_ns
	msg := sprintf(
		"policy %q review is overdue (last reviewed %s, due every %d days)",
		[id, policy.lastReviewed, policy.reviewEveryDays],
	)
}
