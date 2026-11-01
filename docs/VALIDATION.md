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

## GitHub Actions and bilingual documentation audit — 0.0.4 development (2026-11-01)

**PASS:** Authorized GitHub connection resolves to account `Sashido01`. New commit `328e5299d2be89f74a613ff0c47ba16ce9bec929` identifies its Git author/committer as `Sashido01` with the GitHub-generated private email address. Older immutable commit history contains a different author and placeholder email; no published tag or history was rewritten.

**PASS:** Dependabot PR #1 for `actions/checkout` v7.0.1 (pinned `3d3c42e5aac5ba805825da76410c181273ba90b1`) was squash-merged in commit `79d5cee`. Historical failure `41331901840` was due to the PowerShell exit-code defect already fixed in `v0.0.3`; the combined-main run `41332769330` passed.

**PASS:** The bilingual documentation and source/version changes are committed on `main`. A first run `41333433827` failed in two Python matrix jobs solely because a version test expected literal `0.0.3`. The test now reads the `VERSION` file. The follow-up run [41333518665](https://github.com/Sashido01/CodexHomeport/actions/runs/41333518665) **passed all four jobs**: Python Ubuntu, Python Windows, native PowerShell Windows, and documentation/version consistency. All checks are synthetic; no live profile was restored.

**PARTIAL — settings:** GitHub's public branch endpoint reports `main.protected=true` but `required_status_checks.enforcement_level=off` and an empty required-check list. Branch protection detail endpoint returned 403 for this integration. Therefore mandatory CI checks and exact protection rules cannot be confirmed as enforced; an administrator must inspect Settings → Rules/Actions. Source files cannot turn those settings on.

**NOT_VERIFIED:** Local checkout state and identity, local JSONL logs, a new `v0.0.4` release tag, native Codex installer/GUI execution, live profile restore and MCP reconnection. The remote updates were made through the authorized GitHub connection, not through the user's local Git checkout. Do not call 0.0.4 a fully accepted release before those separate release criteria are met.

## Portable customization and Windows acceptance — v0.0.5 development (2026-11-01)

**PASS:** PowerShell 7.5.4 parsed the Windows engine/menu and `tests/test_homeport.ps1` passed against an isolated temporary profile. The test verified the version and status commands, a private-data exclusion, manifest entries and SHA-256, verify, non-writing restore dry-run, explicit apply, preservation of replaced files, an induced mid-apply failure with rollback of the earlier replacement, and rejection of a corrupted data file, invalid digest, traversal path, and source/destination symlinks. The temporary profile, snapshot, rollback and synthetic audit log were removed. This is synthetic Windows evidence, not a live-profile restore.

**PASS:** Python unittest suite: 17/17. Public tracked-tree heuristic passed for all 54 staged files. The bilingual documentation and local Markdown-link checker passed at version `0.0.5`. Python compile and staged `git diff --check` passed.

**PASS:** The actual `Homeport.cmd` was opened in an interactive Windows terminal, displayed menu version `0.0.5`, and exited with choice `0`. The native Codex CLI returned `codex-cli 0.166.0`; `Homeport.ps1 -Action Status` detected it with PASS. No install, update, login, profile backup, or restore was run against the real user profile.

**PASS:** A private read-only inventory of the actual user profile and MyCodex components was saved outside Git. It contains selected identifiers and component names only; config contents, authentication, history, databases, logs and backups were not read into the public repository. MyCodex and the live Codex profile were not modified.

**PASS:** GitHub Actions push run [41335797088](https://github.com/Sashido01/CodexHomeport/actions/runs/41335797088) and PR run [41335835928](https://github.com/Sashido01/CodexHomeport/actions/runs/41335835928) both completed successfully on implementation SHA `049fbd2c84ac3f55154760609fc932967bd7b8c5`. Each run passed all four jobs: Python Ubuntu, Python Windows, native PowerShell, and bilingual docs/version validation. These are hosted synthetic checks, not live-profile tests.

**PARTIAL — repository enforcement:** GitHub confirms `main` is protected against force-push and deletion; required status checks and required reviews are both unset. PR #2 was held for successful checks before merge, but the host does not enforce that gate for future PRs. Existing repository security settings report Dependabot alerts/updates and secret scanning/push protection enabled; non-provider secret patterns are disabled. Settings were inspected without changing them.

**NOT_VERIFIED:** Codex Desktop GUI/session continuity, whether configured MCP servers can connect, and live-profile restore. The configured model default is not evidence of the active model in this conversation. Hosted Windows and Linux jobs use synthetic profiles and do not prove user-profile recovery.


## Prepared public bootstrap — 0.0.6

The new isolated Python tests target dry-run, installation into an empty fake profile, repeat safety, preservation of existing global files, `CODEX_HOME` overrides and symlink refusal. Windows PowerShell acceptance exercises an isolated synthetic profile and idempotency. Hosted push CI run [41341336238](https://github.com/Sashido01/CodexHomeport/actions/runs/41341336238) **PASS 4/4** on implementation SHA `7d47a56547541efdb0af960dda9afa96fdffcdfe`: Python Ubuntu/Windows, native PowerShell (including isolated bootstrap) and bilingual documentation. The first run failed on a PowerShell test-only variable named `$home`, which conflicts with read-only `$HOME`; renamed it to `$fakeHome` before this passing run. Tests use only synthetic profiles; they do not prove native GUI install or login.

**NOT_VERIFIED:** first-time Windows/Linux Desktop GUI installation and sign-in, real Linux preview GUI, third-party skill activation and MCP, and restoration of the private MyCodex bundle. These cannot be inferred from synthetic profile tests.
