# Optional Codex customization

[Русский](../ru/CUSTOMIZATION.md) | [Getting started](GETTING_STARTED.md)

Homeport provides a sanitised `config.toml` example and an `AGENTS.md` template. They are starting points for manual customization, not an installed profile or a required set of settings. Compare them with your own files and keep only what you choose. Homeport does not merge or apply presets automatically.

## Model and reasoning

The user's selected model takes priority. Continue with it when it can do the task. Do not stop only because the active model cannot be reliably identified or someone recommended another one. Recommend a switch only for a concrete capability limit or a materially harder next stage; the user decides whether to switch.

A model ID in `config.toml` is a setting, not proof of the model used in the current chat or of account access. Catalogs, settings, and supported reasoning options change; consult the [official Codex configuration reference](https://developers.openai.com/codex/config-reference) and your account settings. Do not set a global model or reasoning default just to install Homeport.

## Allowance and work modes

Modes such as NORMAL, SAVE, STRICT, and RESERVE can be personal preferences. Homeport does not assign universal percentages or calculate remaining allowance: products and plans do not share a reliable general formula. Use such modes only by choice and with a trustworthy remaining-usage indicator. Do not claim measured savings without comparable measurements.

## Instructions, skills, and MCP

- Keep shared user instructions in the Codex-supported `AGENTS.md`; keep project rules in the relevant project repository. Check precedence in the [official AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md).
- Install skills only from sources you trust, after reviewing licenses and executable files. Files on disk do not prove that a skill is active or compatible.
- Add MCP servers through documented Codex commands, one server at a time. Separately verify required local programs, scope, tool permissions, and authentication. Do not migrate tokens or local `env` values.
- After changing personal settings, review the resulting config and perform a safe check with native Codex. Homeport does not change selected authentication, sandbox, or approval settings.

## Transfer boundaries

Homeport can preserve only the settings and instruction files listed in the [coverage matrix](../PROFILE-COVERAGE.md). Model recommendations, local servers, network routes, system policies, and Desktop state need a separate manual decision. Backups and their logs stay outside Git.
