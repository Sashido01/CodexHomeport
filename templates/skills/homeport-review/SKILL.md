---
name: homeport-review
description: Review a bounded change for correctness, security, testing and documentation without producing unnecessary follow-up tasks.
---

# Focused change review

1. Identify the task's acceptance criteria and exact changed files; do not search unrelated private projects.
2. Check data safety, permissions, secret exposure, source provenance, rollback and platform assumptions.
3. Run existing relevant tests if available. Explain what they do and do not prove; do not label unrun tests PASS.
4. Report only confirmed defects and meaningful risks, with files and reproducible evidence; distinguish optional style observations.
5. When acceptance passes, report COMPLETE in the tested scope and stop. Do not start a fresh project or another review cycle without a new request.
