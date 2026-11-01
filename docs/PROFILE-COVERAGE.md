# Profile material inventory / materials checklist

| Artifact | Public repository | Private snapshot | Notes |
|---|---|---|---|
| Codex CLI binary | Never | Never | Native OpenAI installer; one install channel per host |
| `~/.codex/config.toml` and `*.config.toml` | Example only | Yes | May contain plaintext credentials and platform paths; inspect after recovery |
| `~/.codex/AGENTS.md`, `instructions.md` | Generic template | Yes | Real instructions may expose confidential information |
| Global `~/.codex/skills`, `rules`, `prompts`, `memories` | One example skill | Regular allowed files | Optional by filesystem presence; no claims that all skills run |
| `~/.agents/skills` | Example | Regular allowed files | Executable skill scripts are untrusted code |
| Project-level `.codex/` and `AGENTS.md` | Only project-specific examples | No | Reside in their OWN Git repos; preserve relevant policies there |
| MCP server registrations | No actual servers | Config file only | Must separately install tools and re-authorize; do not copy token environment |
| Model choice / effort / sandbox / approval | Policy template, no pinned choice | Config if present | Use available model, do not silently override |
| Desktop chat history and state in Documents, `sessions`, SQLite | Never | Never | Official app owns its state; separate backup policy |
| `auth.json`, keychains, passwords, tokens, `.env` | Never | Never | Sign in again using official flow |
| Windows registry, proxy, firewall, routing, Hiddify/Xray | Never | Never | OS-specific, must be manually inspected and authorized |
| Git worktrees/remotes, SSH credentials | Never | Never | Their own Git and system credential manager |
| Locally installed plugins, extensions and companion programs | No bundles | No executables | Inventory and install using their official paths |

These are **coverage categories**, not an inventory of an individual user's live machine. A trustworthy restore must compare actual items on source and target, including `CODEX_HOME` overrides. Full restoration of all Desktop sessions and external integrations is not claimed.
