# GitHub Actions and repository policy

[Русский](../ru/CI_POLICY.md) | [Maintenance](MAINTENANCE.md)

CI runs synthetic Python tests on Windows and Ubuntu, native Windows PowerShell profile checks, public-tree scanner, and paired-document/version checks. No login, private user profile, or self-hosted runner is necessary.

The workflow pins `actions/checkout` to a reviewed full SHA, sets `permissions: contents: read`, disables credential persistence, and does not use dangerous `pull_request_target` execution. CI must never install or update a real Codex profile.

Review separately in GitHub UI: **Settings → Actions → General** (allowed actions, read-only token defaults); **Settings → Rules → Rulesets** (protect `main`, prohibit force-push/deletion, require actual check names); **Settings → Security** (Dependabot, secret scanning, private vulnerability reporting). Check execution-protection actor/event rules introduced in 2026 to allow your intended `push`, `pull_request`, and `workflow_dispatch` runs.

PR #1's original failed Windows run came from an older PowerShell exit-code bug already fixed in v0.0.3, **not** from checkout v7.0.1. After merging, verify the resulting main branch CI independently. Ruleset enforcement depends on repository plan and settings and cannot be asserted by YAML alone.

## Confirmed checks (2026-11-01)

After fixing the test's hard-coded version, [run 41333518665](https://github.com/Sashido01/CodexHomeport/actions/runs/41333518665) passed all four jobs: Python Ubuntu, Python Windows, native PowerShell, and paired documentation. The public branch API reports that `main` is protected but **required status checks are not enforced**; this setting needs owner verification in GitHub's Rules screen. The repo's source-only CI works even without changing that administrative setting.

Sources: [GitHub Actions workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax), [2026 execution protections](https://github.blog/changelog/2026-09-17-workflow-execution-protections-in-github-actions-generally-available/), [allowed-actions availability](https://github.blog/changelog/2026-02-05-github-actions-early-february-2026-updates/).
