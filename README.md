# Codex Homeport

**Native Codex. Safe recovery. Your workflow intact.**

**Codex Homeport** — community-maintained, unofficial, open-source tools for installing/updating the **official OpenAI Codex CLI**, backing up a **local private copy** of user configuration, and safely restoring that configuration to a new or repaired machine. **Not an OpenAI product, not a Codex fork, not an alternative runtime.**

> [Русский](#быстрый-старт-windows-и-linux) · [English](#quick-start-english)

## Состав проекта / repository map

```text
.github/         CI, Dependabot, SECURITY, issue & pull request templates
scripts/         native Windows/Unix backup engines, official installer, public-tree guard
tests/           isolated synthetic profile and security regression tests
templates/       optional, sanitized AGENTS/config and a recovery skill
 docs/           ADRs, architecture, research, security, profile coverage, operations
Homeport.cmd     Windows interactive launcher (PowerShell 7 required)
Homeport.sh      Unix status launcher
VERSION         single source of the project's microversion
CHANGELOG.md    release history
AGENTS.md       repository-scoped Codex instructions
```

**Version:** `0.0.2` (previous untagged `0.1.0` was an unreleased prototype). Tags advance from `v0.0.0`; see [versioning](docs/VERSIONING.md). The project is universal: no built-in developer-specific drive letter or home path. A local clone can live anywhere; only personal private snapshots belong outside that clone.

**Included practical material:** [profile coverage matrix](docs/PROFILE-COVERAGE.md), [DevSecMLOps workflow](docs/DEVSECMLOPS.md), [reviewed public templates](templates), [maintainer GitHub procedure](docs/MAINTAINER.md), and [Codex acceptance task](docs/TASK_FOR_CODEX.md). Real installed configurations are deliberately not shipped. Users may copy/modify templates explicitly; Homeport never silently installs templates into a working profile.

## Быстрый старт (Windows и Linux)

**Прежде чем начать:** внимательно прочитайте код загрузчика и [документ о безопасности](docs/SECURITY.md). Работайте от своей обычной учётной записи, **не от администратора**. Вся информация пользователя сохраняется **только локально, вне Git**. Закройте работающие сеансы Codex на время восстановления файлов.

**Windows 10/11, PowerShell 7:**

```powershell
# Проверить, какой Codex найден, и какие настройки доступны:
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Status

# Установка/обновление CLI ЧЕРЕЗ ОФИЦИАЛЬНЫЙ установщик OpenAI:
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Install

# Создать локальную приватную резервную копию (путь НЕ в репозитории Git):
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Backup -BackupDir "$HOME\CodexHomeportBackups\first-snapshot"

# Проверить копию и посмотреть план восстановления без записи:
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Verify  -BackupDir "$HOME\CodexHomeportBackups\first-snapshot"
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Restore -BackupDir "$HOME\CodexHomeportBackups\first-snapshot"

# ТОЛЬКО после проверки плана выполнить восстановление:
pwsh -NoProfile -File .\scripts\homeport.ps1 -Action Restore -BackupDir "$HOME\CodexHomeportBackups\first-snapshot" -Apply
```

**Ubuntu/macOS, Python 3.9+ из стандартной системной установки:**

```bash
python3 scripts/homeport.py status

# Официальная загрузка и установка Codex CLI:
sh scripts/install-official.sh

# Снимок личных настроек создавайте ВНЕ репозитория:
python3 scripts/homeport.py backup --dir "$HOME/CodexHomeportBackups/first-snapshot"
python3 scripts/homeport.py verify --dir "$HOME/CodexHomeportBackups/first-snapshot"
python3 scripts/homeport.py restore --dir "$HOME/CodexHomeportBackups/first-snapshot"         # dry-run
python3 scripts/homeport.py restore --dir "$HOME/CodexHomeportBackups/first-snapshot" --apply # writes
```

> Для переноса на другой компьютер сначала создайте резервную копию на исходной машине и **безопасно скопируйте её приватным способом** на новую (не через публичный репозиторий). Обычный `git clone` не содержит и не должен содержать ваши настройки. Важные внешние файлы рабочего проекта нужно переносить отдельным Git remote или отдельным бэкапом.

## Что переносится

| Источник | Содержимое | По умолчанию |
|---|---|---|
| `${CODEX_HOME:-~/.codex}/config.toml` | модель, approval/sandbox, MCP-конфигурация | Да |
| `~/.codex/AGENTS.md`, `instructions.md` | пользовательские инструкции | Да |
| `~/.codex/*.config.toml` | отдельные конфигурационные профили | Да |
| `~/.codex/{skills,rules,prompts,memories}/` | локальные навыки, правила, подсказки, память — если существуют | Да, обычные файлы |
| `~/.agents/skills/` | глобальные навыки | Да, обычные файлы |
| Авторизация, `auth.json`, keychain/keyring, токены | секреты учётной записи | **Нет** |
| `history.jsonl`, `sessions/`, SQLite, другие UI state DB | история диалогов и приватное состояние | **Нет** |
| `.git`, внутренний кэш, логи, `packages/`, скачанные исполняемые файлы | внутренние артефакты | **Нет** |
| `AGENTS.md` / `.codex/` внутри отдельных проектов, исходники проектов | проектные настройки | **Нет: через Git каждого проекта** |
| Сторонние CLI, MCP-сервера, провайдеры | внешние зависимости | **Нет: установите отдельно** |

Важно: `config.toml` и даже `AGENTS.md` могут содержать секреты, пути и чувствительные данные. Копия **не шифруется**, не публикуется и не пригодна для загрузки на GitHub. Никогда не копируйте её в репозиторий. Ссылки (symlinks/reparse points) не сохраняются; результат проверяйте самостоятельно.

Если используется переопределённый `CODEX_HOME`, выставьте его в окружении; в Python доступно также `--codex-home`, в PowerShell — `-CodexHome`. `CODEX_SQLITE_HOME` не копируется, поскольку state DB исключена из этого безопасного профиля.

## Подробные журналы

Каждая команда печатает JSON-событие с UTC-временем, действием и результатом. Для детального **локального** аудита используйте `--audit-log "$HOME/CodexHomeportBackups/audit.jsonl"` в Python или `-AuditLog "$HOME\CodexHomeportBackups\audit.jsonl"` в PowerShell. В этом JSONL будут также записи по каждому файлу (относительный путь, размер и SHA-256). Храните журнал вне Git: имена навыков/файлов могут быть чувствительными. Сам `manifest.json` служит машинно-проверяемым реестром содержимого снимка.

## Поведение восстановления

1. Загружается `manifest.json` (версия формата 1; максимум 5000 файлов, 25 MiB на файл, 250 MiB всего) и проверяются допустимые пути, SHA-256 и размеры **всех** файлов.
2. По умолчанию `Restore` только считает изменения. Никакого обновления конфигурации без `--apply` или `-Apply`.
3. Перед записью существующие целевые файлы копируются в соседний каталог `*-rollback-YYYYMMDDTHHMMSSZ` **вне Git**.
4. Обновляются только файлы, перечисленные в манифесте. Другие существующие настройки и файлы не удаляются.
5. После применения SHA-256 сверяется повторно. При ошибке производится попытка отката уже изменённых файлов; сохранённый rollback остаётся для ручной проверки.

**Границы гарантии:** не автоматическое восстановление всей истории Codex Desktop или его базы; не миграция авторизации; не проверка правильности всех MCP-серверов и сторонних навыков; не автоматическое преобразование путей Windows↔Linux. Это консервативное восстановление *конфигурационного профиля*, а не клонирование работающей сессии.

## Статус реализации 0.0.2

- **Linux и Windows PowerShell 7:** изолированные profile flows прошли синтетические проверки; подробности и границы доказательств — в [VALIDATION.md](docs/VALIDATION.md).
- **Штатный Codex CLI:** существующая установка найдена и отвечает на `--version`. Установка, обновление и вход не выполнялись; Homeport использует официальный установщик только по явному действию пользователя.
- **Профиль:** реальная конфигурация обследуется отдельно и только для частного локального инвентаря. Восстановление поверх неё не выполнялось.
- **Codex Desktop:** не обновляется и не восстанавливается автоматически; следует штатному каналу поставки системы.
- **Публикация и CI:** результат конкретной GitHub-публикации и Actions запуска указан в [VALIDATION.md](docs/VALIDATION.md) после проверки удалённых refs и run status.

Проверки и границы описаны в [VALIDATION.md](docs/VALIDATION.md), [RESEARCH.md](docs/RESEARCH.md), [SECURITY.md](docs/SECURITY.md) и [ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Безопасность публикации / safety before public push

```bash
python3 -m unittest discover -s tests -v
python3 scripts/check-public-tree.py
```

The tracked-file scanner is a heuristic, **not a substitute for human review or GitHub secret scanning**. Do not publish a profile snapshot, its manifest or its private log, even if it has valid hashes. GitHub guidance for branch protection, code review and source-only publishing is in [MAINTAINER](docs/MAINTAINER.md). The reference docs for official Codex installation remain [openai/codex](https://github.com/openai/codex).

## Quick start (English)

Codex Homeport ships native **Codex CLI** installation entry points and a separate, private profile-backup mechanism. It does **not** distribute Codex, credentials, chat transcripts, or proprietary configurations. Run `python3 scripts/homeport.py --help` on Linux/macOS, or `pwsh -File scripts/homeport.ps1 -Action Status` on Windows. Start with a backup and restore dry-run, then use `--apply` / `-Apply` to write. Windows functionality is provided but not yet exercised on real Windows hardware. See the Russian instructions above for exact commands.

## License & trademark

MIT — see [LICENSE](LICENSE). "Codex" and "OpenAI" refer to products of OpenAI; this project is independent and unaffiliated.

### Windows launcher

Double-click `Homeport.cmd` to open a single native PowerShell menu for inspection, official CLI installation, export and dry-run/confirmed restore. It needs PowerShell 7 and does not bypass the original Codex installation or sign-in system. The Windows menu path has not been physically tested on a Windows device.
