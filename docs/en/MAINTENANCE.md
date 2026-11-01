# Maintenance and releases

[Русский](../ru/MAINTENANCE.md) | [CI policy](CI_POLICY.md)

Use native Git and GitHub CLI. Before committing, inspect the repository-local identity and authenticated account:

```powershell
gh auth status
gh api user --jq '.login'
git config --local --get user.name
git config --local --get user.email
git remote -v
git status --short --branch
```

For upstream publication the authenticated account must be the authorized maintainer. For forks, use your own account. Configure local identity with `git config --local user.name "YOUR_LOGIN"` and `git config --local user.email "YOUR_VERIFIED_OR_NOREPLY_EMAIL"`. Email must be verified on the same GitHub account, or be its `ID+LOGIN@users.noreply.github.com` address. Never use placeholder email addresses. Verify `git log -1 --format=fuller` before a push.

Existing published commits retain their historical attribution unless history is rewritten; do not rewrite published release history only to remove a display name.

Use clear natural-language commit messages. Make small scoped changes; update matching English and Russian docs, `CHANGELOG.md`, `VERSION`, engines and launcher together when increasing the microversion. Test before tagging. Record PASS, FAIL and NOT_VERIFIED distinctly. Keep local JSONL logs and personal backups out of Git. No force pushes or moved release tags. Stop when acceptance criteria are satisfied.
