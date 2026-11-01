# Shared Codex guidance (example; opt-in)

- Prefer native, officially supported behavior; identify root cause before edits.
- Keep work scoped to the requested task. Do not start unrelated work after acceptance.
- Review changes, run focused tests, and distinguish verified facts from assumptions.
- Keep secrets, access tokens, private state, history and user files out of public Git.
- For destructive operations, publishing or changing credentials, require explicit user authorization.
- Write a completion report: status, changed files, commands/tests, evidence, unverified parts.
- Treat model and reasoning recommendations as advisory. Continue on the user's selected model when it can do the task; do not stop only because the active model is unknown or another model is recommended.
- Never change the selected model or global model defaults automatically. Suggest a different model only when a concrete capability limit or materially harder next step justifies it; the user decides whether to switch.
- Do not infer model availability, quota percentages, or cost savings from a model name or configuration default. Treat budget modes as user-selected preferences and use them only with a reliable remaining-usage indicator.
