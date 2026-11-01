# Быстрая установка подготовленного Codex

[English](../en/BOOTSTRAP.md) · [Начало работы](GETTING_STARTED.md) · [Безопасность](SECURITY.md)

**Публичный каркас не является приватным бэкапом.** Homeport добавляет глобальные инструкции, стартовый конфиг и три оригинальных навыка. Секреты, история чатов, приватные проекты, базы SQLite и авторизация в публичный Git не входят.

## Windows 11

Из локального клона Homeport (PowerShell 7) выполните **одну команду** для подготовки профиля, официального CLI и Desktop из Windows Store:

```powershell
pwsh -NoProfile -File .\scripts\bootstrap.ps1 -Apply -InstallCli -InstallDesktop
```

Штатная установка Windows Desktop выполняется через `winget install --id 9PLM9XGG6VKS -s msstore`. Источник — [официальная инструкция](https://learn.chatgpt.com/docs/app/windows). Вход в аккаунт выполняйте самостоятельно.

Если клиент установлен, достаточно `pwsh -NoProfile -File .\scripts\bootstrap.ps1 -Apply`. Двойное нажатие `Homeport-Setup.cmd` устанавливает **только публичные шаблоны**, без сетевых установщиков. Просмотр без изменений: `pwsh -NoProfile -File .\scripts\bootstrap.ps1`.

## Linux (Desktop preview)

Официальное приложение ChatGPT с Codex доступно в preview на поддерживаемых Ubuntu/Debian/Fedora/Arch, x64/ARM64. Устанавливайте `.deb`/`.rpm` или штатный Arch installer по [официальной инструкции](https://learn.chatgpt.com/docs/linux/linux-app) через пакетный менеджер. Homeport не подменяет GUI инструментом CLI. Computer Use на Linux preview пока отсутствует.

Из локального клона (Python 3.9+):

```bash
sh setup.sh --apply --install-cli
```

Только каркас: `sh setup.sh --apply`. План без записи: `sh setup.sh`. Войдите в аккаунт через официальное приложение и проверьте новый чат.

## Что готово

- В новый профиль создаются `AGENTS.md`, `config.toml` без закреплённого ID модели и приватных серверов, а также три текстовых оригинальных навыка: `homeport-recovery`, `homeport-diagnostics`, `homeport-review`.
- Повторный запуск не перезаписывает существующие файлы (`SKIP_EXISTS`); запись требует `-Apply` / `--apply`. JSONL-события выводятся в консоль; приватный журнал храните вне Git.
- Поддерживается `CODEX_HOME`. Windows и Linux — отдельные профили, автоматической синхронизации нет.
- Сторонние gstack, Matt Pocock, interface-design, внешние MCP и бинарники **не входят** в публичный набор. Для их установки нужна отдельная проверка источника, лицензии, совместимости и зависимостей.

## Приватное восстановление — второй слой

Совместимый снимок Homeport применяйте отдельно: Verify → dry-run → явный Apply после закрытия Codex и сохранения нового состояния. Большой комплект MyCodex с runtime/SQLite и **другим манифестом** нельзя напрямую передавать восстановителю Homeport: используйте исходный локальный runbook и staging. Старые credentials, IPC и открытые БД не переносите. Держите зашифрованную внешнюю копию аварийного бэкапа.

**Граница проверки:** CI проверяет синтетические Windows/Linux-профили. Реальный GUI, вход в аккаунт, сторонние навыки и MCP на новом компьютере пока NOT_VERIFIED.
