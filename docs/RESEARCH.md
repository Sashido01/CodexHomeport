# Research decision record — 2026-11-01

## Primary official sources (verified by opening on 2026-11-01)

1. Official Codex repository — https://github.com/openai/codex : documents `https://chatgpt.com/codex/install.sh` (Linux/macOS) and `install.ps1` (Windows), plus npm/Homebrew alternatives. CLI starts with `codex` and supports ChatGPT login.
2. Official Codex installer shell source — https://github.com/openai/codex/blob/main/scripts/install/install.sh : supports `CODEX_HOME`, standalone package layout, upstream distribution URL. The script is not mirrored here.
3. Official PowerShell installer source — https://github.com/openai/codex/blob/main/scripts/install/install.ps1 : native Windows script; no custom binary packaging here.
4. Official advanced config / state locations — https://developers.openai.com/codex/config-advanced : `CODEX_HOME` default `~/.codex`; config, auth, history and other app state; project-level `.codex/config.toml` is separate from global config and depends on repository trust.
5. Official environment variables — https://developers.openai.com/codex/environment-variables : installer variables `CODEX_NON_INTERACTIVE`, `CODEX_INSTALL_DIR`, core variables `CODEX_HOME` / `CODEX_SQLITE_HOME`.
6. Latest official releases page — https://github.com/openai/codex/releases : on 2026-11-01 the latest stable displayed was CLI `0.166.0` (published 2026-10-29). **Do not pin this value**: always follow current official installer.

## Decisions / reasons

- **Do not build a Codex fork, browser-wrapper, internal updater, or self-compiled binary:** conflicts with a genuinely native, supportable release and creates upgrade drift.
- **Do not put an entire `~/.codex/` directory in public Git:** it can include credentials, chats, logs, data stores and platform-specific state.
- **Preserve real model choice:** the project must not overwrite the user's current `model` with a guessed or recommended value. A user-provided backup is the only source of truth.
- **Do not assume that CLI installation restores Desktop:** CLI and desktop distribution/versions are distinct. The tools support CLI installation and user-config migration only.
- **No automatic secret migration:** sign-in again using the official login mechanism on the destination computer.
- **No automated copy of project worktrees:** their own version history should live in their individual Git repos and backup systems.
- **No external dependency manager for the backup engine:** Python standard library on Ubuntu/macOS; PowerShell 7 on Windows.

## Context-specific requirements addressed in design

The desired real profile may include global/project `AGENTS.md`, dozens of skills, model-effort routing rules, local Git workflow conventions, MCP entries and memories. A public starter must **not invent or ship** the user's actual 2026 configuration: the export command reads whatever exists on the source machine when actually run. The tool does not auto-set a default model. A full clone of in-progress Desktop conversations and credentials is beyond this scope, and cannot be truthfully described as restored.

## Validation evidence and limitations

See `docs/VALIDATION.md` for local isolation tests. Cross-platform Windows end-to-end and physical GUI testing require access to that OS and are explicitly NOT_VERIFIED as of this artifact build. Shell and PowerShell official installer downloads were not run, to avoid modifying an unrelated runtime.
