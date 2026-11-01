---
name: homeport-diagnostics
description: Diagnose Codex CLI, Desktop and configuration issues using evidence and official tools without modifying the live profile.
---

# Codex diagnostics

1. Identify Windows, Linux or WSL, actual Codex installation and CODEX_HOME. Distinguish CLI from Desktop versions.
2. Prefer safe native status commands and official documentation. Do not inspect secrets or chat contents.
3. Record the exact failure, stdout, exit code and the smallest reproducible scenario. Don't infer root cause from correlation.
4. Use existing project tests before proposing a new framework. Avoid repeating unchanged probes.
5. Separate MACHINE_VERIFIED, USER_ATTESTED, NOT_VERIFIED and upstream limitations.
6. Change only the affected scope after a backup and explicit permissions; never disable sandbox, TLS or credential protection to make a test pass.
