# Access control

> Fictional example policy for the Acme example company.

- Access is granted per role, never per person; roles live in the company spec.
- Only the `founder` role holds GitHub `admin` (`rules.adminAllowed`).
- Two-factor authentication is required on every account (`rules.requireTwoFactor`).
- Access is removed on the last working day as part of offboarding.
