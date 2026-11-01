# Codex acceptance task: Homeport v0.0.1 source to real Windows + GitHub

Scope: one closure task only; do not start unrelated improvements. Working directory: the repository folder chosen by the maintainer (no absolute path in source). Use an available economical Codex model and medium effort by default; if insufficient, justify escalation. Do not select nonexistent model IDs.

**Goal:** verify and finish the already built, path-independent **native** Codex Homeport `v0.0.1` on the real Windows host, then publish its reviewed source to the owner's **public** GitHub repository. Never publish profile backups, credentials, conversations, logs or local device details.

**Workflow:**
1. Inspect the actual local checkout, status, branches, Git tags, `VERSION`, README, scripts and prior tests. Do not overwrite any newer changes. Identify the canonical repo folder; do not encode its absolute path into public code.
2. Compare installer behavior with official OpenAI docs; keep the original CLI and Desktop, no forks, wrappers, custom update channels or speculative config changes. Confirm which Codex binary is selected on PATH and preserve user auth.
3. Inspect actual global Codex config/AGENTS/skills/MCP paths **read-only**, produce a private inventory (do not copy content to Git). Respect existing working projects and their Git repos. Back up only through an explicit fresh, private, outside-Git path; no cloud uploads.
4. Run Windows PowerShell 7 parser and isolated fake-profile Backup→Verify→Restore dry-run→Apply→SHA256 checks. Run Python unit tests where Python exists and the public-tree scanner. Check error handling and return codes. Real user's profile `Restore -Apply` is **not permitted** without a separate explicit authorization.
5. Fix only confirmed defects; increment microversion if and only if changes require it, update CHANGELOG/ADRs/validation and detailed LOCAL JSONL log. Keep clear FAIL/PARTIAL/NOT_VERIFIED distinctions; do not log secrets.
6. Inspect Git staged diff, run secret scan and tests, commit locally. Publish only reviewed source and tags using native git/gh and the authorized GitHub account, without force push. If GitHub repo creation/push is unauthorized or credentials unavailable, report precise blocker instead of claiming publication.
7. Verify public GitHub README, branches, tag and CI; enable or document unavailable branch protection, security alerts and private vulnerability reporting. Provide exact URLs only after checking them.

**Acceptance:** native Codex unchanged and operable; real Windows isolated integration PASS; public source contains no private machine profile; Git history/tags and changelog agree; public GitHub reachable and CI outcome recorded; evidence report lists commands, hash/commit, PASS/FAIL and gaps. If this scope is done, state COMPLETE and STOP. If blocked, state PARTIAL with the single real blocker; do not fabricate tasks or tests.
