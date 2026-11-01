# GitHub Actions and repository policy

[Русский](../ru/CI_POLICY.md) | [Maintenance](MAINTENANCE.md)

CI runs synthetic Python tests on Windows and Ubuntu, native Windows PowerShell profile checks, public-tree scanner, and paired-document/version checks. No login, private user profile, or self-hosted runner is necessary.

The workflow pins `actions/checkout` to a reviewed full SHA, sets `permissions: contents: read`, disables credential persistence, and does not use dangerous `pull_request_target` execution. CI must never install or update a real Codex profile.

Review separately in GitHub UI: **Settings → Actions → General** (allowed actions, read-only token defaults); **Settings → Rules → Rulesets** (protect `main`, prohibit force-push/deletion, require actual check names); **Settings → Security** (Dependabot, secret scanning, private vulnerability reporting). Check execution-protection actor/event rules introduced in 2026 to allow your intended `push`, `pull_request`, and `workflow_dispatch` runs.

PR #1's original failed Windows run came from an older PowerShell exit-code bug already fixed in v0.0.3, **not** from checkout v7.0.1. After merging, verify the resulting main branch CI independently. Ruleset enforcement depends on repository plan and settings and cannot be asserted by YAML alone.
