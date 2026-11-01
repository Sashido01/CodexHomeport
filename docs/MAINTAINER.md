# Maintainer GitHub workflow (path-independent)

Work in any ordinary folder selected by the maintainer. No script assumes a fixed drive letter, username or repository checkout path. The repository is a public **source-only** project; private snapshots and JSONL logs live outside the checkout.

1. Inspect `git status`, `git diff`, the current branch, and `VERSION` before edits.
2. Work in a micro-scoped branch when reviewing a functional change; preserve changes from other work.
3. Validate: `python -m unittest discover -s tests -v`, `python scripts/check-public-tree.py`, source review, Windows CI where applicable.
4. Commit only reviewed sources. Tag `v0.0.N` on the reviewed release commit, with matching changelog and validation evidence.
5. Create the public GitHub repo with **GitHub CLI** after signing into your own account. On a machine with `gh` installed, while in the repo root:

   ```powershell
   gh auth status
   gh repo create OWNER/CodexHomeport --public --source . --remote origin --push
   git push origin --follow-tags
   ```

   Replace OWNER with your account name. **Do not run `gh repo create` if this repository already exists.** If it does, add/verify `origin`, check its exact URL, then push explicitly. No automatic force push.

6. On GitHub, independently set description, topics, vulnerability reporting, branch protections/rulesets, review requirements and security alerts. Confirm rendered README, tags, check results and zero unexpected tracked files. A local commit is not remote publication.

No script provisions GitHub credentials; authentication stays in `gh`/Git's native credential provider. Issue/PR attachments must be synthetic.
