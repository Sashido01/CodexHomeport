# ADR-0001: Native Codex boundary

Status: Accepted | 2026-11-01

- This repository does not fork, patch, vendor, proxy, or rebuild Codex.
- Official CLI installation is an explicit operation; provider authentication remains with the user.
- Profile backup uses a local private directory outside the Git working tree.
- By default, recovery is a read-only preview. Mutations require a separate `apply` flag.
- Public templates are generic; they do not represent the maintainers' installed profiles.
- Native Desktop application storage, sessions, keyrings and authentication are excluded.
