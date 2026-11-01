# Validation evidence — Homeport v0.0.1 (2026-11-01)

## Confirmed local isolated checks

Command: `python -m unittest discover -s tests -v` (Linux, Python 3.13). **17/17 PASS** on a synthetic fake home directory; no current Codex profile read or written. Coverage: backup manifest and allowlist, exclusions of auth/sessions, verify and recovery dry-run/apply, rollback snapshot, tampering/traversal checks, Git worktree backup refusal, symlink paths, repeated snapshots, private filename exclusion, duplicate rows, private JSONL event rows, custom `CODEX_HOME`, version, manifest size/hash invalid types, portable collision rejection, oversized backup cleanup, and refusal of backup/audit files inside a live profile.

Command: `python scripts/check-public-tree.py` with staged source tracked in Git. PASS at release creation; heuristic names and tokens only, not a formal proof of secret absence. `python -m py_compile scripts/homeport.py scripts/check-public-tree.py` and `git diff --check` also verified at release packaging.

## NOT_VERIFIED (not an implementation claim)

- Genuine Windows PowerShell 7 runtime, ACL behavior, Windows installer execution, and real GUI double-click.
- GitHub Actions remote runner outcomes, remote branch protections, publication of this source/tag to the already existing public repository and public tag existence.
- Native official Codex installer execution/upgrade, ChatGPT sign-in, Codex Desktop session restore, MCP reconnect, physical device behavior.
- Real existing user profile migration on Windows/Ubuntu and cross-OS path rewriting.

## Scope and stop condition

The following paragraph records the historical `v0.0.1` state and is superseded by the `v0.0.2` acceptance section below. This package is a profile recovery tool, **not** a proven way to restore the entire Codex Desktop installation.

## Windows acceptance — v0.0.2 (2026-11-01)

**PASS:** PowerShell 7.5.4 on the user's Windows host parsed both PowerShell entrypoints. An isolated temporary fake profile exercised Homeport version/status, backup, manifest verification, SHA-256 equality, exclusion of `auth.json`, dry-run without changing existing files, apply over existing files, restored prior contents, and fail-closed verification after manifest digest tampering. The temporary profile and snapshots were removed after the run. This is synthetic Windows evidence, not a real-profile restore or physical-device claim.

**PASS:** The existing native Codex CLI was found through read-only status checks. No install, update, login, or auth command was run. Host-specific CLI details are kept in the private local acceptance journal.

**PASS:** Python 3.14 Windows suite: 17/17 tests. Public tracked-tree heuristic: 37 files scanned, PASS. Python compile: PASS. `git diff --check`: PASS before release commit.

**NOT_VERIFIED:** Desktop UI startup/session continuity, MCP reconnect functionality, and physical-device acceptance are outside this synthetic profile test. No live profile snapshot or restore was performed. The remote Actions outcome is recorded below.

## GitHub result and follow-up — v0.0.2

**PARTIAL:** Public `main` and tags `v0.0.0`, `v0.0.1`, and `v0.0.2` were published without force. GitHub Actions run [41331843139](https://github.com/Sashido01/CodexHomeport/actions/runs/41331843139) passed both Python matrix jobs, including the public-tree guard, but failed `powershell-native` at process exit. The log shows Version, Status, Backup, Verify, dry-run, and Apply all reporting PASS; the step then exited 1 because the expected failed `git rev-parse` outside a worktree left `$LASTEXITCODE` set to 128. This is a real integration defect, fixed in `0.0.3`.

**PASS:** GitHub vulnerability alerts, Dependabot security updates, and private vulnerability reporting are enabled. Secret scanning and push protection were already enabled. `main` protection now enforces the branch rule for administrators and blocks force-push and deletion; direct non-force updates remain allowed.

## Windows and CI recheck — v0.0.3

**PASS:** Local PowerShell 7 synthetic acceptance, including successful `$LASTEXITCODE` after Backup and Apply, passed. GitHub Actions branch run [41332039873](https://github.com/Sashido01/CodexHomeport/actions/runs/41332039873) and tag run [41332045423](https://github.com/Sashido01/CodexHomeport/actions/runs/41332045423) both passed on exact release SHA `1ed3f61c21792360e1243808d3d838ee0fc1ea36`. Each run passed `python-profile (ubuntu-latest)`, `python-profile (windows-latest)`, and `powershell-native`.

**PASS:** The public repository displays the current README and source tree. The `v0.0.3` release tag remains on its tested source SHA; a documentation-only validation update follows on `main`. Tags `v0.0.0` through `v0.0.3` preserve the original history. Security settings are enabled as recorded above. No force push was used.

**NOT_VERIFIED:** Codex Desktop session continuity, MCP reconnect behavior, and physical-device acceptance are outside this profile-tool task. No live user profile snapshot or restore was performed.
