# Changelog

All entries describe implemented, tested changes; no claim of remote release is implied.

## [0.0.3] - 2026-11-01

- Fixed the Windows PowerShell engine leaving `$LASTEXITCODE` set to 128 after the expected non-Git probe of an outside-Git private directory. Successful backup/restore commands now return a successful process status.
- Added this fix after GitHub Actions showed all PowerShell profile operations passing but the Windows job exiting 1. The failed `v0.0.2` run is recorded in validation evidence; `v0.0.3` must pass before closure.

## [0.0.2] - 2026-11-01

- Corrected the launcher menu's displayed version and aligned the Python and PowerShell engines with the release version.
- Completed native Windows PowerShell 7 synthetic acceptance: parser, status/version, backup, manifest and SHA-256 verification, auth exclusion, restore dry-run, apply over existing files, and tampered-manifest rejection.
- Confirmed the existing local Codex CLI is reachable on PATH and reports its installed version; no installer, login, update, or real-profile write was run.
- Preserved the existing GitHub initial commit alongside the local bundle history; publication and remote CI results are recorded after their actual completion.

## [0.0.1] - 2026-11-01

- Added portable public repository foundation, sanitised AGENTS/config/skill templates and explicit ADR decisions.
- Added profile coverage matrix, DevSecMLOps controls, release/publishing procedure, and scoped Codex acceptance task.
- Hardened both backup engines with manifest entry/size limits and staging before restore; Python also rejects case-insensitive filename collisions and symlinked backup paths.
- Added Windows line-ending policy and strengthened source-only GitHub CI (synthetic Windows PowerShell smoke planned for GitHub Actions) and added a heuristic public-tree check.
- Synthetic Python Linux regression suite extended from 11 to 17 tests. Windows runtime and GitHub CI remain NOT_VERIFIED until actually executed.

## [0.0.0] - 2026-11-01

- Established tagged baseline for official Codex CLI installation entry points and private profile backup/recovery engines.
- Recorded public-source/private-profile architecture and repository microversion policy.

## Unreleased prototype (untagged earlier commit)

The former draft described itself as 0.1.0. No public release was made; historical source commit is preserved for audit while public versioning starts at 0.0.0.
