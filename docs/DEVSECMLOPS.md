# DevSecMLOps without a new Codex runtime

**Build / Dev:** Use native OpenAI Codex CLI only. Homeport's code is independently testable with Python stdlib and PowerShell 7. Runtime packaging is forbidden; no Codex binary is vendored.

**Security / Sec:** Source code and public examples are separate from private profile data. Fail closed on unexpected manifest paths, links, hash mismatches, data-size caps and Git-tracked backup destinations. Test negative cases and review dependencies. Local snapshots are NOT encrypted; do not upload them. Code from restored skills/MCP entries is untrusted until the owner reviews it.

**MLOps:** No training, fine-tuning, model serving or agent API is performed. Model routing is user-owned policy in Codex config, not hardcoded into Homeport. Evaluation measures accepted recovery operations and focused regression tests, not model benchmark claims. Record effort as a selectable suggestion; don't silently change the chosen model.

**Operations:** Use one narrow task, record preconditions and baseline hashes, implement, perform tests, capture timestamps and result, then close when acceptance passes. Emit JSONL only into a private local directory. Investigate failures, do not write 'PASS' on an unexecuted scenario.

**Delivery / CD:** Git locally, review diffs, run public-tree scanner, tag microversion, publish reviewed source to GitHub only after explicit owner approval. Branch protection/required reviews, security scanning and CI success must be configured and checked on GitHub; the presence of YAML does not prove remote configuration or successful runs. Avoid auto-release of binaries and auto-uploading backups.

**Supply chain:** GitHub Actions checkout is pinned to a verified full commit SHA and uses read-only credentials. Dependabot can propose changes; no auto-merge. Official installer is separately fetched when the user explicitly executes installation, never in CI. A trusted HTTPS host is not proof of a signed installer; review the actual script and verify provenance as required.

**KPI:** accepted scope / model allowance consumed, reproducible test evidence, and recovery time only when measured. Do not invent savings or success rates.

**Portable guidance:** model routing and reasoning remain advisory user policy. Continue on the selected capable model; do not gate a task on an unknown active-model label. Avoid percentage-based allowance presets unless a user explicitly selects them and has a reliable remaining-usage signal. MCP server definitions are not server installations or authorization and are never copied from a live profile into public examples.
