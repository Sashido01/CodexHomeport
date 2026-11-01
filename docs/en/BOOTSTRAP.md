# Quick prepared Codex setup

[Русский](../ru/BOOTSTRAP.md) · [Getting started](GETTING_STARTED.md) · [Security](SECURITY.md)

**The public scaffold is not a private backup.** Homeport adds global instructions, starter configuration and three original skills. Secrets, conversations, private projects, SQLite and authentication never go into public Git.

## Windows 11

From a local Homeport checkout (PowerShell 7), run **one command** to install the starter profile, official CLI and Desktop through Windows Store:

```powershell
pwsh -NoProfile -File .\scripts\bootstrap.ps1 -Apply -InstallCli -InstallDesktop
```

Official Windows Desktop install uses `winget install --id 9PLM9XGG6VKS -s msstore`. See the [official Windows guide](https://learn.chatgpt.com/docs/app/windows). Sign in to your account yourself.

If Desktop is installed, use `pwsh -NoProfile -File .\scripts\bootstrap.ps1 -Apply`. Double-click `Homeport-Setup.cmd` for **public templates only**, without any network installers. Dry-run: `pwsh -NoProfile -File .\scripts\bootstrap.ps1`.

## Linux (Desktop preview)

The official ChatGPT app with Codex is in preview on supported Ubuntu/Debian/Fedora/Arch (x64/ARM64). Install an official `.deb`/`.rpm` or Arch package via your native package manager following the [Linux guide](https://learn.chatgpt.com/docs/linux/linux-app). Homeport does not substitute CLI for the GUI. Computer Use is not yet supported on Linux preview.

From a local checkout (Python 3.9+):

```bash
sh setup.sh --apply --install-cli
```

Profile only: `sh setup.sh --apply`. Dry-run: `sh setup.sh`. Sign in through the official app and test a new chat.

## Starter contents

- New profiles get `AGENTS.md`, `config.toml` without a pinned model ID or private services, and three original text-only skills: `homeport-recovery`, `homeport-diagnostics`, `homeport-review`.
- Re-runs never replace existing files (`SKIP_EXISTS`). Writing requires explicit `-Apply` / `--apply`. JSONL events go to stdout; keep private logs outside Git.
- `CODEX_HOME` is supported. Windows and Linux have separate profile roots, with no automatic synchronization.
- Third-party gstack, Matt Pocock, interface-design, external MCP servers and binaries are **not bundled**. They need separately verified provenance, licenses, platform support and dependencies.

## Private restore is a second layer

Apply a **compatible** Homeport snapshot separately: Verify → dry-run → explicit Apply after closing Codex and preserving new state. A large MyCodex recovery set containing runtimes/SQLite and a **different manifest** cannot be passed directly to Homeport: follow its original private runbook and staging. Never migrate old credentials, IPC or live databases. Keep an encrypted off-device disaster-recovery backup.

**Evidence limit:** CI tests synthetic Windows/Linux profiles, not real Desktop startup, sign-in, external skills or MCP on a clean computer; those remain NOT_VERIFIED.
