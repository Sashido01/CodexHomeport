# Начало работы

[English](../en/GETTING_STARTED.md) | [Описание](README.md)

Запускайте от обычного пользователя, не от администратора. Предварительно изучите скрипты. Храните снимки **за пределами любого Git-репозитория** и не публикуйте их. Windows требует PowerShell 7, Linux/macOS — Python 3.9+.

## Windows

```powershell
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Status
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Backup -BackupDir "$HOME\CodexHomeportBackups\snapshot-01"
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Verify -BackupDir "$HOME\CodexHomeportBackups\snapshot-01"
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Restore -BackupDir "$HOME\CodexHomeportBackups\snapshot-01"
# Только после проверки плана и закрытия Codex:
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Restore -BackupDir "$HOME\CodexHomeportBackups\snapshot-01" -Apply
```

`Homeport.cmd` открывает меню. Команда `-Action Install` вызывает официальный установщик OpenAI, а не альтернативную версию.

## Linux/macOS

```bash
python3 scripts/homeport.py status
python3 scripts/homeport.py backup --dir "$HOME/CodexHomeportBackups/snapshot-01"
python3 scripts/homeport.py verify --dir "$HOME/CodexHomeportBackups/snapshot-01"
python3 scripts/homeport.py restore --dir "$HOME/CodexHomeportBackups/snapshot-01"
# Только после проверки плана:
python3 scripts/homeport.py restore --dir "$HOME/CodexHomeportBackups/snapshot-01" --apply
```

Официальная установка отдельно: `sh scripts/install-official.sh`. В публичный GitHub нельзя загружать снимки. `git clone` переносит только код и обезличенные шаблоны. Проектные файлы и сессии Codex Desktop не мигрируют. См. [безопасность](SECURITY.md).
