#requires -Version 7.0
$ErrorActionPreference='Stop'
$repo = Split-Path -Parent $PSScriptRoot
$setup = Join-Path $repo 'scripts/bootstrap.ps1'
$home = Join-Path ([IO.Path]::GetTempPath()) ('homeport-bootstrap-' + [guid]::NewGuid().ToString('N'))
try {
    $dry = & $setup -CodexHome $home
    if ($LASTEXITCODE -ne 0 -or (Test-Path $home)) { throw 'Dry-run modified fake home' }
    $items = @($dry | ForEach-Object { $_ | ConvertFrom-Json })
    if (-not @($items | Where-Object status -eq 'WOULD_CREATE').Count) { throw 'Missing dry-run plan' }
    & $setup -CodexHome $home -Apply | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Apply failed' }
    foreach ($path in @('AGENTS.md','config.toml','skills/homeport-recovery/SKILL.md','skills/homeport-diagnostics/SKILL.md','skills/homeport-review/SKILL.md')) {
        if (-not (Test-Path (Join-Path $home $path))) { throw "Missing: $path" }
    }
    'private = "retain"' | Set-Content -LiteralPath (Join-Path $home 'config.toml')
    & $setup -CodexHome $home -Apply | Out-Null
    if ((Get-Content (Join-Path $home 'config.toml') -Raw) -notmatch 'private') { throw 'Changed private config' }
    [pscustomobject]@{status='PASS';scenario='bootstrap';files=5} | ConvertTo-Json -Compress
} finally {
    if (Test-Path $home) { Remove-Item -LiteralPath $home -Recurse -Force }
}
