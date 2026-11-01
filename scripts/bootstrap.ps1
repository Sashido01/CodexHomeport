#requires -Version 7.0
<#
Public Codex profile bootstrap. Dry-run by default; no replacement of existing files.
Only explicit -InstallCli/-InstallDesktop invoke official installers.
#>
param(
    [switch]$Apply,
    [switch]$InstallCli,
    [switch]$InstallDesktop,
    [string]$CodexHome = '',
    [string]$UserHome = ''
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
if (-not $UserHome) { $UserHome = $HOME }
if (-not $CodexHome) {
    if ($env:CODEX_HOME) { $CodexHome = $env:CODEX_HOME }
    else { $CodexHome = Join-Path $UserHome '.codex' }
}
$CodexHome = [IO.Path]::GetFullPath($CodexHome)
$created = [Collections.Generic.List[string]]::new()

function Write-Event([string]$Status,[string]$Item,[string]$Detail='') {
    [pscustomobject]@{ time=[DateTimeOffset]::UtcNow.ToString('o'); action='bootstrap'; status=$Status; item=$Item; message=$Detail } | ConvertTo-Json -Compress -Depth 3
}
function Assert-NoLink([string]$Path) {
    $item = [IO.Path]::GetFullPath($Path)
    while ($true) {
        if (Test-Path -LiteralPath $item) {
            $attr = (Get-Item -LiteralPath $item -Force).Attributes
            if ($attr -band [IO.FileAttributes]::ReparsePoint) { throw "Symlink/reparse destination denied: $item" }
        }
        $parent = [IO.Path]::GetDirectoryName($item)
        if (-not $parent -or $parent -eq $item) { break }
        $item = $parent
    }
}
try {
    $entries = @(
        @{ src='templates/codex/AGENTS.md'; dest='AGENTS.md'; name='codex/AGENTS.md' },
        @{ src='templates/codex/config.example.toml'; dest='config.toml'; name='codex/config.toml' }
    )
    $skills = Join-Path $repo 'templates/skills'
    foreach ($folder in @(Get-ChildItem -LiteralPath $skills -Directory | Sort-Object Name)) {
        if ($folder.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Symlinked skill source denied' }
        $entry = Join-Path $folder.FullName 'SKILL.md'
        if (-not (Test-Path -LiteralPath $entry -PathType Leaf)) { throw "Missing skill entry: $($folder.Name)" }
        $entries += @{ src=("templates/skills/" + $folder.Name + "/SKILL.md"); dest=("skills/" + $folder.Name + "/SKILL.md"); name=("codex/skills/" + $folder.Name + "/SKILL.md") }
    }
    foreach ($row in $entries) {
        $src = Join-Path $repo ($row.src.Replace('/',[IO.Path]::DirectorySeparatorChar))
        $dst = Join-Path $CodexHome ($row.dest.Replace('/',[IO.Path]::DirectorySeparatorChar))
        if ((Get-Item -LiteralPath $src -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Symlinked template denied' }
        if ((Get-Item -LiteralPath $src).Length -gt 256KB) { throw 'Oversized template denied' }
        Assert-NoLink $dst
        if ((Test-Path -LiteralPath $dst) -and -not (Test-Path -LiteralPath $dst -PathType Leaf)) { throw 'File destination is a directory' }
    }
    foreach ($row in $entries) {
        $src = Join-Path $repo ($row.src.Replace('/',[IO.Path]::DirectorySeparatorChar))
        $dst = Join-Path $CodexHome ($row.dest.Replace('/',[IO.Path]::DirectorySeparatorChar))
        if (Test-Path -LiteralPath $dst) { Write-Event 'SKIP_EXISTS' $row.name; continue }
        if (-not $Apply) { Write-Event 'WOULD_CREATE' $row.name; continue }
        Assert-NoLink $dst
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dst)) | Out-Null
        Assert-NoLink $dst
        $bytes = [IO.File]::ReadAllBytes($src)
        $file = [IO.FileStream]::new($dst, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
        $created.Add($dst)
        try { $file.Write($bytes,0,$bytes.Length) } finally { $file.Dispose() }
        Write-Event 'CREATED' $row.name
    }
    Write-Event 'PASS' 'bootstrap' $(if ($Apply) { 'apply' } else { 'dry-run' })
} catch {
    foreach ($path in $created) { Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue }
    Write-Event 'FAIL' 'bootstrap' $_.Exception.Message
    exit 1
}
if ($InstallCli) {
    if (-not $Apply) { throw '-InstallCli requires -Apply' }
    & (Join-Path $PSScriptRoot 'homeport.ps1') -Action Install -UserHome $UserHome
    if ($LASTEXITCODE -ne 0) { throw 'Official Codex CLI installation failed' }
}
if ($InstallDesktop) {
    if (-not $Apply) { throw '-InstallDesktop requires -Apply' }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw 'winget not found. See official Windows app guide.' }
    & winget install --id 9PLM9XGG6VKS -s msstore --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw 'Official Windows Desktop installation failed' }
}
