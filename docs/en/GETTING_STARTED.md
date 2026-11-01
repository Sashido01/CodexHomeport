# Getting started

[Русский](../ru/GETTING_STARTED.md) | [Overview](README.md)

Optional templates and settings guidance: [Codex customization](CUSTOMIZATION.md).

Use an ordinary OS account, not an administrator. Review the scripts first. Keep snapshots **outside any Git repository** and private. On Windows use PowerShell 7; on Linux/macOS use Python 3.9+.

## Windows

```powershell
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Status
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Backup -BackupDir "$HOME\CodexHomeportBackups\snapshot-01"
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Verify -BackupDir "$HOME\CodexHomeportBackups\snapshot-01"
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Restore -BackupDir "$HOME\CodexHomeportBackups\snapshot-01"
# Only after reviewing the plan and closing Codex:
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Restore -BackupDir "$HOME\CodexHomeportBackups\snapshot-01" -Apply
```

`Homeport.cmd` opens an interactive menu. Explicit `-Action Install` invokes the official OpenAI CLI installer, not a fork.

## Linux/macOS

```bash
python3 scripts/homeport.py status
python3 scripts/homeport.py backup --dir "$HOME/CodexHomeportBackups/snapshot-01"
python3 scripts/homeport.py verify --dir "$HOME/CodexHomeportBackups/snapshot-01"
python3 scripts/homeport.py restore --dir "$HOME/CodexHomeportBackups/snapshot-01"
# Only after reviewing dry-run:
python3 scripts/homeport.py restore --dir "$HOME/CodexHomeportBackups/snapshot-01" --apply
```

Official installation is separate: `sh scripts/install-official.sh`. Never upload snapshots to public GitHub. A Git clone contains only application source and sanitized templates. Project-local files and Codex Desktop sessions are not migrated. See [security](SECURITY.md).
