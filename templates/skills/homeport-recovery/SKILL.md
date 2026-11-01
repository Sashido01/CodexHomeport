---
name: homeport-recovery
description: Plan and verify a conservative local Codex profile recovery using official Codex and Codex Homeport.
---

# Recovery workflow

1. Check official Codex is installed; if missing, use a documented **official** channel only.
2. Record profile paths without reading private authentication, histories, logs or SQLite data.
3. Back up allowlisted settings to a new PRIVATE path outside a Git repository.
4. Verify manifest hashes. Inspect the restore dry-run; enumerate OS-specific MCP paths.
5. Close Codex sessions. Apply only after explicit user approval, then verify hashes and native Codex behavior.
6. Record tests, rollback path, unverified integrations; never upload the private snapshot.
