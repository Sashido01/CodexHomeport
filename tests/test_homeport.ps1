#requires -Version 7.0
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$engine = Join-Path $root 'scripts/homeport.ps1'
$menu = Join-Path $root 'scripts/homeport-menu.ps1'
$pwsh = (Get-Command pwsh -ErrorAction Stop).Source
$parseTokens = $null
$parseErrors = $null
foreach ($file in @($engine, $menu)) {
    [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$parseTokens, [ref]$parseErrors) | Out-Null
    if ($parseErrors.Count -gt 0) { throw "PowerShell parse failed: $file" }
}

$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('homeport-acceptance-' + [guid]::NewGuid().ToString('N'))
$testHome = Join-Path $testRoot 'profile'
$codexHome = Join-Path $testHome '.codex'
$snapshot = Join-Path $testRoot 'snapshot'
$null = New-Item -ItemType Directory -Path $codexHome -Force
$checks = [ordered]@{}

function Invoke-Homeport([string[]]$Arguments, [switch]$ExpectFailure) {
    $output = @(& $pwsh -NoProfile -File $engine @Arguments 2>&1)
    $code = $LASTEXITCODE
    if ($ExpectFailure) {
        if ($code -eq 0) { throw "Expected Homeport failure for: $($Arguments -join ' ')" }
    } elseif ($code -ne 0) {
        throw "Homeport failed ($code): $($output -join "`n")"
    }
    $jsonLine = $output | Where-Object { $_ -is [string] -and $_.TrimStart().StartsWith('{') } | Select-Object -Last 1
    if (-not $jsonLine) { throw "Homeport did not emit its JSON result: $($output -join "`n")" }
    return ($jsonLine | ConvertFrom-Json)
}

try {
    'model = "synthetic-acceptance-model"' | Set-Content -LiteralPath (Join-Path $codexHome 'config.toml')
    'synthetic instructions' | Set-Content -LiteralPath (Join-Path $codexHome 'AGENTS.md')
    'AUTH_SENTINEL_DO_NOT_BACKUP' | Set-Content -LiteralPath (Join-Path $codexHome 'auth.json')

    $version = Invoke-Homeport @('-Action', 'Version')
    if ($version.homeport -ne (Get-Content (Join-Path $root 'VERSION') -Raw).Trim()) { throw 'Version mismatch' }
    $checks.version = 'PASS'

    $status = Invoke-Homeport @('-Action', 'Status', '-UserHome', $testHome)
    if ($status.status -ne 'PASS') { throw 'Isolated status did not pass' }
    $checks.status = 'PASS'

    $null = Invoke-Homeport @('-Action', 'Backup', '-UserHome', $testHome, '-BackupDir', $snapshot)
    $manifestPath = Join-Path $snapshot 'manifest.json'
    $manifestRaw = Get-Content -LiteralPath $manifestPath -Raw
    $manifest = $manifestRaw | ConvertFrom-Json
    if ($manifest.files.path -contains 'codex/auth.json') { throw 'Authentication file entered the snapshot' }
    foreach ($row in $manifest.files) {
        $dataPath = Join-Path (Join-Path $snapshot 'data') ($row.path.Replace('/', [IO.Path]::DirectorySeparatorChar))
        $digest = (Get-FileHash -LiteralPath $dataPath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($digest -cne $row.sha256) { throw "SHA-256 mismatch: $($row.path)" }
    }
    $verified = Invoke-Homeport @('-Action', 'Verify', '-BackupDir', $snapshot)
    if ($verified.status -ne 'PASS') { throw 'Manifest verification did not pass' }
    $checks.backup_manifest_sha256 = 'PASS'
    $checks.auth_exclusion = 'PASS'

    'changed target value' | Set-Content -LiteralPath (Join-Path $codexHome 'config.toml')
    $dryRun = Invoke-Homeport @('-Action', 'Restore', '-UserHome', $testHome, '-BackupDir', $snapshot)
    if ($dryRun.status -ne 'DRY_RUN') { throw 'Restore did not default to dry-run' }
    if ((Get-Content (Join-Path $codexHome 'config.toml') -Raw) -notmatch 'changed target value') { throw 'Dry-run modified the target' }
    $checks.dry_run = 'PASS'

    $applied = Invoke-Homeport @('-Action', 'Restore', '-UserHome', $testHome, '-BackupDir', $snapshot, '-Apply')
    if ($applied.status -ne 'PASS') { throw 'Restore apply did not pass' }
    if ((Get-Content (Join-Path $codexHome 'config.toml') -Raw) -notmatch 'synthetic-acceptance-model') { throw 'Restored config content mismatch' }
    $rollbackFile = Join-Path (Join-Path ([string]$applied.rollback) 'old') 'codex/config.toml'
    if (!(Test-Path -LiteralPath $rollbackFile) -or (Get-Content -LiteralPath $rollbackFile -Raw) -notmatch 'changed target value') { throw 'Previous target file was not preserved' }
    $checks.apply_and_previous_file = 'PASS'

    'pre-failure config' | Set-Content -LiteralPath (Join-Path $codexHome 'config.toml')
    'pre-failure instructions' | Set-Content -LiteralPath (Join-Path $codexHome 'AGENTS.md')
    $configLock = [IO.File]::Open((Join-Path $codexHome 'config.toml'), [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
    try {
        $null = Invoke-Homeport @('-Action', 'Restore', '-UserHome', $testHome, '-BackupDir', $snapshot, '-Apply', '-AuditLog', (Join-Path $testRoot 'restore-audit.jsonl')) -ExpectFailure
    } finally {
        $configLock.Dispose()
    }
    if ((Get-Content (Join-Path $codexHome 'AGENTS.md') -Raw) -notmatch 'pre-failure instructions') { throw 'Mid-restore error did not roll back the first replaced file' }
    if ((Get-Content (Join-Path $codexHome 'config.toml') -Raw) -notmatch 'pre-failure config') { throw 'Mid-restore error changed the locked file' }
    $checks.rollback_after_partial_apply = 'PASS'

    'sentinel must remain after rejected restore' | Set-Content -LiteralPath (Join-Path $codexHome 'config.toml')
    $first = $manifest.files | Select-Object -First 1
    $firstData = Join-Path (Join-Path $snapshot 'data') ($first.path.Replace('/', [IO.Path]::DirectorySeparatorChar))
    $firstOriginalBytes = [IO.File]::ReadAllBytes($firstData)
    'tampered data' | Set-Content -LiteralPath $firstData
    $null = Invoke-Homeport @('-Action', 'Restore', '-UserHome', $testHome, '-BackupDir', $snapshot, '-Apply') -ExpectFailure
    if ((Get-Content (Join-Path $codexHome 'config.toml') -Raw) -notmatch 'sentinel must remain') { throw 'Corrupt snapshot partially changed the target' }
    $checks.corrupt_snapshot_fail_closed = 'PASS'

    [IO.File]::WriteAllBytes($firstData, $firstOriginalBytes)
    $tampered = $manifest.files | Select-Object -First 1
    $tampered.sha256 = '0' * 64
    $tamperedManifest = $manifest | ConvertTo-Json -Depth 10
    Set-Content -LiteralPath $manifestPath -Value $tamperedManifest -Encoding utf8
    $null = Invoke-Homeport @('-Action', 'Verify', '-BackupDir', $snapshot) -ExpectFailure
    Set-Content -LiteralPath $manifestPath -Value $manifestRaw -Encoding utf8
    $manifest.files[0].path = 'codex/skills/../../auth.json'
    Set-Content -LiteralPath $manifestPath -Value ($manifest | ConvertTo-Json -Depth 10) -Encoding utf8
    $null = Invoke-Homeport @('-Action', 'Restore', '-UserHome', $testHome, '-BackupDir', $snapshot, '-Apply') -ExpectFailure
    if ((Get-Content (Join-Path $codexHome 'config.toml') -Raw) -notmatch 'sentinel must remain') { throw 'Invalid manifest partially changed the target' }
    $checks.bad_hash_and_path_fail_closed = 'PASS'

    $linkStatus = 'NOT_VERIFIED'
    $linkPath = Join-Path $codexHome 'skills\escape'
    $outside = Join-Path $testRoot 'outside'
    $null = New-Item -ItemType Directory -Path (Split-Path $linkPath -Parent) -Force
    $null = New-Item -ItemType Directory -Path $outside -Force
    try {
        'outside sentinel' | Set-Content -LiteralPath (Join-Path $outside 'outside.txt')
        $null = New-Item -ItemType SymbolicLink -Path $linkPath -Target $outside -ErrorAction Stop
        $symlinkSnapshot = Join-Path $testRoot 'symlink-snapshot'
        $null = Invoke-Homeport @('-Action', 'Backup', '-UserHome', $testHome, '-BackupDir', $symlinkSnapshot)
        $symlinkManifest = Get-Content -LiteralPath (Join-Path $symlinkSnapshot 'manifest.json') -Raw | ConvertFrom-Json
        if ($symlinkManifest.files.path -contains 'codex/skills/escape/outside.txt') { throw 'Backup followed a source symlink' }
        $targetConfig = Join-Path $codexHome 'AGENTS.md'
        Remove-Item -LiteralPath $targetConfig -Force
        $null = New-Item -ItemType SymbolicLink -Path $targetConfig -Target (Join-Path $outside 'outside.txt') -ErrorAction Stop
        $beforeSymlinkRestore = Get-Content -LiteralPath (Join-Path $codexHome 'config.toml') -Raw
        $null = Invoke-Homeport @('-Action', 'Restore', '-UserHome', $testHome, '-BackupDir', $snapshot, '-Apply') -ExpectFailure
        if ((Get-Content (Join-Path $outside 'outside.txt') -Raw) -notmatch 'outside sentinel') { throw 'Restore wrote through a destination symlink' }
        if ((Get-Content -LiteralPath (Join-Path $codexHome 'config.toml') -Raw) -cne $beforeSymlinkRestore) { throw 'Symlink rejection partially changed another target' }
        $linkStatus = 'PASS'
    } catch [System.UnauthorizedAccessException] {
        $linkStatus = 'PARTIAL_PRIVILEGE'
    } catch [System.IO.IOException] {
        $linkStatus = 'PARTIAL_PRIVILEGE'
    }
    $checks.symlink_fail_closed = $linkStatus

    [pscustomobject]@{ status = 'PASS'; checks = $checks; synthetic_files = $manifest.files.Count } | ConvertTo-Json -Depth 5 -Compress
} finally {
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $resolvedTestRoot = [IO.Path]::GetFullPath($testRoot)
    $relativeTestRoot = [IO.Path]::GetRelativePath($tempRoot, $resolvedTestRoot)
    if ($relativeTestRoot -notmatch '^homeport-acceptance-[0-9a-f]{32}$' -or [IO.Path]::IsPathRooted($relativeTestRoot) -or $relativeTestRoot.StartsWith('..')) {
        throw 'Refusing to clean an unexpected path'
    }
    Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force -ErrorAction SilentlyContinue
}
