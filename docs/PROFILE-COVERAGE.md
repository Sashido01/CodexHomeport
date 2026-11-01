# Profile material inventory / materials checklist

| Artifact | Public repository | Private snapshot | Notes |
|---|---|---|---|
| Codex CLI binary | Never | Never | Native OpenAI installer; one install channel per host |
| `~/.codex/config.toml` and `*.config.toml` | Example only | Yes | May contain plaintext credentials and platform paths; inspect after recovery |
| `~/.codex/AGENTS.md`, `instructions.md` | Generic template | Yes | Real instructions may expose confidential information |
| Global `~/.codex/skills`, `rules`, `prompts`, `memories` | One example skill | Regular allowed files | Optional by filesystem presence; no claims that all skills run |
| `~/.agents/skills` | Example | Regular allowed files | Executable skill scripts are untrusted code |
| Project-level `.codex/` and `AGENTS.md` | Only project-specific examples | No | Reside in their OWN Git repos; preserve relevant policies there |
| MCP server registrations | Sanitised command guidance only | Config if present | Install dependencies and re-authorize separately; never copy token environment |
| Model choice / effort / sandbox / approval | Policy template, no pinned choice | Config if present | Use available model, do not silently override |
| Model routing and allowance preferences | General advisory guidance only | User decides | No model auto-switch, account entitlement assumption, or universal quota thresholds |
| Project-level settings and instructions | No live project profile | No | Remain with the corresponding project repository and its owner |
| Hooks and external tools | No installed components | No | Inspect compatibility and trust, then install through the component's documented path |
| Desktop chat history and state in Documents, `sessions`, SQLite | Never | Never | Official app owns its state; separate backup policy |
| `auth.json`, keychains, passwords, tokens, `.env` | Never | Never | Sign in again using official flow |
| Windows registry, proxy, firewall, routing, Hiddify/Xray | Never | Never | OS-specific, must be manually inspected and authorized |
| Git worktrees/remotes, SSH credentials | Never | Never | Their own Git and system credential manager |
| Locally installed plugins, extensions and companion programs | No bundles | No executables | Inventory and install using their official paths |

These are **coverage categories**, not an inventory of an individual user's live machine. A trustworthy restore must compare actual items on source and target, including `CODEX_HOME` overrides. Full restoration of all Desktop sessions and external integrations is not claimed.

## Recovery scope: configuration versus complete installation

A Homeport **snapshot is not a full computer or Codex Desktop backup**. Both current engines deliberately limit a snapshot to **5,000 files**, **25 MiB per file** and **250 MiB total** (the manifest limit is **4 MiB**). An oversized or unsupported source fails; do not assume extra files were saved, bypass size guards, or feed an unrelated backup format into the Homeport restore command. Homeport accepts only its own verified manifest schema and allowlisted paths.

The allowlist includes selected global configuration, instructions, regular skill files, rules, prompts and memories. It does **not** include arbitrary helper folders (for example, scripts stored in `~/.codex/network/`), system/desktop runtimes, plugin caches, dependencies, Windows/OS configuration, Git worktrees, authentication, conversations or SQLite state. A restored `AGENTS.md` can therefore refer to a network tool or third-party skill executable that is **not present** on the destination. Resolve such references separately, with source/provenance checks and the user's permission; never copy old credentials or bypass the destination's sandbox.

A Homeport snapshot captures the selected files **at the time of backup**; it does not auto-refresh after later configuration changes. Separately protect any larger private disaster-recovery set with an encrypted, off-device backup and a verified inventory, keeping it out of the public repository. On the destination, install the official product, sign in again, review paths and model settings, verify skill discovery and MCP/network dependencies, and run a focused functional smoke test. A valid hash is not a guarantee of successful application recovery.


## Prepared starter kit (0.0.6)

The bootstrap supplies general instructions, a model-neutral config and three original text-only skills (recovery, diagnostics, focused review), not an owner's complete collection of gstack/Matt/interface-design packages. Existing profile files are preserved. See [English](en/BOOTSTRAP.md) and [Русский](ru/BOOTSTRAP.md) for Desktop setup and the separate private restore process.
