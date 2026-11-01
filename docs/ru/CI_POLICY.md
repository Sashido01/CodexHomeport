# GitHub Actions и политика репозитория

[English](../en/CI_POLICY.md) | [Сопровождение](MAINTENANCE.md)

CI выполняет синтетические Python-тесты на Ubuntu и Windows, проверку PowerShell 7 на Windows, сканирование публичных файлов и проверку согласованности двух языков и версий. Авторизация, реальные профили и собственные runner'ы не нужны.

Workflow закрепляет `actions/checkout` полным проверенным SHA, задаёт `permissions: contents: read`, отключает сохранение учётных данных и не использует опасный `pull_request_target`. CI не должен изменять работающий Codex.

Отдельно проверьте в интерфейсе GitHub: **Settings → Actions → General** (список разрешённых Actions, токен только на чтение); **Settings → Rules → Rulesets** (защита `main`, запрет force-push/удаления, обязательные проверки с фактическими именами); **Settings → Security** (Dependabot, сканирование секретов, приватные сообщения об уязвимостях). С учётом обновлений 2026 года проверьте правила запуска по участникам/событиям: разрешены ли необходимые `push`, `pull_request`, `workflow_dispatch`.

Первоначальный CI PR #1 упал из-за старой ошибки кода завершения PowerShell, исправленной в v0.0.3, **а не из-за** `checkout v7.0.1`. После объединения необходимо отдельно проверить CI итоговой ветки. Сам YAML не гарантирует включение и применение правил защиты.

## Подтверждённые проверки (01.11.2026)

После исправления теста с жёстко заданной версией [запуск 41333518665](https://github.com/Sashido01/CodexHomeport/actions/runs/41333518665) прошёл все четыре задания: Python Ubuntu, Python Windows, PowerShell и проверка двуязычной документации. Публичный API GitHub показывает, что ветка `main` защищена, но **обязательность прохождения проверок не включена**. Владелец репозитория должен проверить это в разделе Rules. Код и CI работают и без изменения этой административной настройки.

Официальные источники: [синтаксис GitHub Actions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax), [ограничения запуска 2026](https://github.blog/changelog/2026-09-17-workflow-execution-protections-in-github-actions-generally-available/), [доступность списков разрешённых Actions](https://github.blog/changelog/2026-02-05-github-actions-early-february-2026-updates/).
