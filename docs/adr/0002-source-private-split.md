# ADR-0002: Public source, private profile

Status: Accepted | 2026-11-01

Public Git is strictly source, generic examples, tests, CI and documentation. No automatic exporter of real user config into the public checkout. Private backups can contain sensitive plaintext and may only be written to a new local outside-Git destination. Hashes verify corruption but not authenticity of a malicious replacement; snapshots require trusted custody. Model/router advice is not an installed model entitlement and must not replace a user's chosen config. Any per-project files remain in their own Git repositories.

## Acceptance confirmation (2026-11-01)

The live-profile inventory for this acceptance is maintained outside this repository. It records component names and coverage only; configuration values, credentials, history, databases, logs and backup contents are excluded from public source and the public acceptance evidence.

The Windows engine normalizes the expected non-Git result of its private-destination probe so a successful backup or restore reports a successful process exit. Unexpected path or verification failures remain fail-closed.
