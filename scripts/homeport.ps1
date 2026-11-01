#requires -Version 7.0
<# Codex Homeport native Windows implementation. Does not modify Codex binaries.
   Example: ./scripts/homeport.ps1 -Action Backup -BackupDir "$HOME\CodexHomeportBackups\snapshot-01"
#>
[CmdletBinding()]
param(
    [ValidateSet('Status','Backup','Verify','Restore','Install','Version')]
    [string]$Action = 'Status',
    [string]$BackupDir,
    [string]$AuditLog,
    [switch]$Apply,
    [string]$UserHome = $HOME,
    [string]$CodexHome = ''
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Version = '0.0.2'
$MaxFiles = 5000
$MaxFileBytes = 25MB
$MaxTotalBytes = 250MB
$Excluded = @('.git','.env','auth.json','history.jsonl','sessions','logs','log','backups','cache','tmp','temp','packages','node_modules','__pycache__','secrets.json','credentials.json','token.json','.ssh','id_rsa','id_ed25519','.aws','.azure')
$DirAllow = @('codex/skills','codex/rules','codex/prompts','codex/memories','agents/skills')
$FileAllow = @('codex/config.toml','codex/AGENTS.md','codex/instructions.md')
$UserHome = [System.IO.Path]::GetFullPath($UserHome)
if (-not $CodexHome) {
    if ($env:CODEX_HOME) { $CodexHome = $env:CODEX_HOME } else { $CodexHome = Join-Path $UserHome '.codex' }
}
$Roots = @{ codex = [System.IO.Path]::GetFullPath($CodexHome); agents = [System.IO.Path]::GetFullPath((Join-Path $UserHome '.agents')) }

function Log-Event([string]$Task, [string]$State, [hashtable]$Fields) {
    $data = [ordered]@{ time = [DateTimeOffset]::UtcNow.ToString('o'); action = $Task; status = $State }
    foreach ($key in $Fields.Keys) { $data[$key] = $Fields[$key] }
    $line = $data | ConvertTo-Json -Depth 5 -Compress
    Write-Output $line
    if ($AuditLog) {
        $dir = [IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($AuditLog))
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        if (Test-Path -LiteralPath $AuditLog) { Assert-NotLink $AuditLog $dir }
        Add-Content -LiteralPath $AuditLog -Value $line -Encoding UTF8
    }
}
function Log-File([string]$Task,[string]$Rel,[long]$Size,[string]$Hash) {
    if (-not $AuditLog) { return }
    $row = @{ time = [DateTimeOffset]::UtcNow.ToString('o'); action=$Task; status='FILE'; path=$Rel; size=$Size; sha256=$Hash }
    Add-Content -LiteralPath $AuditLog -Value ($row | ConvertTo-Json -Compress) -Encoding UTF8
}
function Assert-Allow([string]$Rel) {
    if (-not $Rel -or $Rel.Contains([char]92) -or $Rel.Contains(':') -or $Rel.StartsWith('/') -or $Rel.Contains([char]0)) {
        throw 'Unsafe manifest path'
    }
    $parts = $Rel.Split('/')
    if ($parts | Where-Object {
        $x = $_.ToLowerInvariant()
        $_ -eq '' -or $_ -eq '.' -or $_ -eq '..' -or $x -in $Excluded -or $x.StartsWith('.env') -or
        $x -match '(\.sqlite(-wal|-shm)?|\.pem|\.key)$' -or $x.EndsWith(' ') -or $x.EndsWith('.') -or
        $x -match '[<>"|?*]' -or $x -match '[\x00-\x1f]' -or
        ($x.Split('.')[0] -in @('con','prn','aux','nul','com1','com2','com3','com4','com5','com6','com7','com8','com9','lpt1','lpt2','lpt3','lpt4','lpt5','lpt6','lpt7','lpt8','lpt9'))
    }) {
        throw "Excluded or unsafe manifest entry: $Rel"
    }
    $allowed = ($Rel -cin $FileAllow)
    if ($parts.Count -eq 2 -and $parts[0] -ceq 'codex' -and $parts[1].EndsWith('.config.toml', [StringComparison]::Ordinal)) { $allowed = $true }
    foreach ($dir in $DirAllow) { if ($Rel.StartsWith("$dir/", [StringComparison]::Ordinal)) { $allowed = $true } }
    if (-not $allowed) { throw "Not on allowlist: $Rel" }
}
function Assert-NotLink([string]$Absolute, [string]$Boundary) {
    $Absolute = [System.IO.Path]::GetFullPath($Absolute)
    $Boundary = [System.IO.Path]::GetFullPath($Boundary)
    $sub = [System.IO.Path]::GetRelativePath($Boundary, $Absolute)
    if ($sub -eq '..' -or $sub.StartsWith('../') -or $sub.StartsWith('..\') -or [System.IO.Path]::IsPathRooted($sub)) { throw 'Path escapes boundary' }
    $walk = $Boundary
    foreach ($segment in @('.') + @($sub.Split([char][System.IO.Path]::DirectorySeparatorChar))) {
        if ($segment -ne '.') { $walk = Join-Path $walk $segment }
        $item = Get-Item -LiteralPath $walk -Force -ErrorAction SilentlyContinue
        if ($null -ne $item -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) { throw "Symlink/reparse point denied: $walk" }
    }
}
function Target-Path([string]$Rel) {
    Assert-Allow $Rel
    $parts = $Rel.Split('/')
    $root = $Roots[$parts[0]]
    $target = $root
    for ($i=1; $i -lt $parts.Count; $i++) { $target = Join-Path $target $parts[$i] }
    Assert-NotLink $target ([System.IO.Path]::GetDirectoryName($root))
    return $target
}
function Assert-PrivateDestination([string]$Dir) {
    $probe = [System.IO.Path]::GetFullPath($Dir)
    $git = Get-Command git -ErrorAction SilentlyContinue
    while ($true) {
        $node = Get-Item -LiteralPath $probe -Force -ErrorAction SilentlyContinue
        if ($node -and ($node.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) { throw 'Private backup path contains symlink/reparse point' }
        if (Test-Path -LiteralPath (Join-Path $probe '.git')) { throw 'Backup location inside Git repo is forbidden' }
        if ((Test-Path -LiteralPath $probe) -and $git) {
            $inside = & git -C $probe rev-parse --is-inside-work-tree 2>$null
            if ($LASTEXITCODE -eq 0 -and $inside -eq 'true') { throw 'Backup location inside Git repo is forbidden' }
            break
        }
        $parent = [System.IO.Path]::GetDirectoryName($probe)
        if (-not $parent -or $parent -eq $probe) { break }
        $probe = $parent
    }
}
function Assert-OutsideProfile([string]$FullPath) {
    foreach ($root in $Roots.Values) {
        $relative = [IO.Path]::GetRelativePath($root, $FullPath)
        if ($relative -eq '.' -or (-not [IO.Path]::IsPathRooted($relative) -and $relative -ne '..' -and -not $relative.StartsWith('..\') -and -not $relative.StartsWith('../'))) {
            throw 'Private backup/audit must not be inside a live profile'
        }
    }
}
function File-Hash([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Get-Entries {
    $found = @{}
    if (Test-Path -LiteralPath $Roots.codex) {
        if ((Get-Item -LiteralPath $Roots.codex).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Symlinked CODEX_HOME must be reviewed manually' }
    }
    foreach ($leaf in @('config.toml','AGENTS.md','instructions.md')) {
        $p = Join-Path $Roots.codex $leaf
        if ((Test-Path -LiteralPath $p -PathType Leaf) -and -not ((Get-Item -LiteralPath $p).Attributes -band [System.IO.FileAttributes]::ReparsePoint)) { $found["codex/$leaf"] = $p }
    }
    if (Test-Path -LiteralPath $Roots.codex -PathType Container) {
        foreach ($item in @(Get-ChildItem -LiteralPath $Roots.codex -File -Filter '*.config.toml' -ErrorAction Stop)) {
            if (-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) { $found["codex/$($item.Name)"] = $item.FullName }
        }
    }
    foreach ($dir in $DirAllow) {
        $parts = $dir.Split('/')
        $base = Join-Path $Roots[$parts[0]] $parts[1]
        if (-not (Test-Path -LiteralPath $base -PathType Container)) { continue }
        try { Assert-NotLink $base ([IO.Path]::GetDirectoryName($Roots[$parts[0]])) } catch { continue }
        foreach ($item in @(Get-ChildItem -LiteralPath $base -Recurse -File -Force -ErrorAction Stop)) {
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { continue }
            $sub = [System.IO.Path]::GetRelativePath($base,$item.FullName).Replace('\','/')
            $rel = "$dir/$sub"
            try { Assert-Allow $rel; Assert-NotLink $item.FullName $base } catch { continue }
            $found[$rel] = $item.FullName
        }
    }
    return $found
}
function Verify-Snapshot([string]$Dir) {
    $manifest = Join-Path $Dir 'manifest.json'
    Assert-NotLink $manifest $Dir
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) { throw 'Missing manifest.json' }
    if ((Get-Item -LiteralPath $manifest).Length -gt 4MB) { throw 'Manifest too large' }
    $info = Get-Content -LiteralPath $manifest -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    if ($info.format -cne 'codex-homeport' -or $info.schema -ne 1 -or $info.files.Count -lt 1) { throw 'Unsupported/empty manifest' }
    if ($info.files.Count -gt $MaxFiles) { throw 'Too many manifest entries' }
    $totalBytes = [long]0
    $seen = @{}
    foreach ($entry in $info.files) {
        $rel = [string]$entry.path
        if ($entry.size -isnot [int] -and $entry.size -isnot [long]) { throw 'Invalid manifest size' }
        if ([long]$entry.size -lt 0 -or [long]$entry.size -gt $MaxFileBytes) { throw 'Invalid manifest size' }
        $totalBytes += [long]$entry.size
        if ($totalBytes -gt $MaxTotalBytes) { throw 'Manifest size limit exceeded' }
        if ([string]$entry.sha256 -cnotmatch '^[a-f0-9]{64}$') { throw 'Invalid SHA256' }
        Assert-Allow $rel
        if ($seen.ContainsKey($rel)) { throw 'Duplicate manifest path' }
        $seen[$rel] = $true
        $p = Join-Path (Join-Path $Dir 'data') ($rel.Replace('/',[IO.Path]::DirectorySeparatorChar))
        Assert-NotLink $p $Dir
        if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { throw "Missing file: $rel" }
        $f = Get-Item -LiteralPath $p
        if ($f.Length -ne [long]$entry.size -or (File-Hash $p) -cne [string]$entry.sha256) { throw "Invalid hash/size: $rel" }
        Log-File 'verify' $rel $f.Length ([string]$entry.sha256)
    }
    return $info
}
try {
    if ($AuditLog) {
        try {
            Assert-PrivateDestination ([IO.Path]::GetFullPath($AuditLog))
            Assert-OutsideProfile ([IO.Path]::GetFullPath($AuditLog))
        } catch {
            $AuditLog = $null
            throw
        }
    }
    if ($Action -eq 'Version') {
        Log-Event 'version' 'PASS' @{ homeport = $Version }
    } elseif ($Action -eq 'Install') {
        $temp = Join-Path ([IO.Path]::GetTempPath()) ("codex-official-" + [guid]::NewGuid().ToString('N') + '.ps1')
        try {
            Invoke-WebRequest -Uri 'https://chatgpt.com/codex/install.ps1' -OutFile $temp -MaximumRedirection 5 -ErrorAction Stop
            if ((Get-Item -LiteralPath $temp).Length -lt 1000) { throw 'Unexpectedly small official installer; not running' }
            & $temp
            if (-not $?) { throw 'Official installer returned error' }
            Log-Event 'install' 'PASS' @{ source = 'https://chatgpt.com/codex/install.ps1' }
        } finally { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
    } elseif ($Action -eq 'Status') {
        $count = (Get-Entries).Count
        $cmd = Get-Command codex -ErrorAction SilentlyContinue
        Log-Event 'status' 'PASS' @{ codex_home = $Roots.codex; file_count = $count; codex_cli = $(if ($cmd) {$cmd.Source} else {'NOT_FOUND'}) }
    } else {
        if (-not $BackupDir) { throw '-BackupDir is required' }
        $BackupDir = [System.IO.Path]::GetFullPath($BackupDir)
        Assert-OutsideProfile $BackupDir
        if ($Action -eq 'Backup') {
            Assert-PrivateDestination $BackupDir
            if (Test-Path -LiteralPath $BackupDir) { throw 'Backup folder already exists; choose a new folder' }
            $entries = Get-Entries
            if ($entries.Count -eq 0) { throw 'No user config files found' }
            if ($entries.Count -gt $MaxFiles) { throw 'Too many profile files' }
            New-Item -ItemType Directory -Path (Join-Path $BackupDir 'data') -Force | Out-Null
            try {
                $rows = @()
                $totalBytes = [long]0
                foreach ($rel in @($entries.Keys | Sort-Object -CaseSensitive)) {
                    $target = Join-Path (Join-Path $BackupDir 'data') ($rel.Replace('/',[IO.Path]::DirectorySeparatorChar))
                    New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($target)) -Force | Out-Null
                    $before = (Get-Item -LiteralPath $entries[$rel]).Length
                    $totalBytes += $before
                    if ($before -gt $MaxFileBytes -or $totalBytes -gt $MaxTotalBytes) { throw 'Profile exceeds size limit' }
                    Copy-Item -LiteralPath $entries[$rel] -Destination $target -ErrorAction Stop
                    $size = (Get-Item -LiteralPath $target).Length
                    if ($size -ne $before) { throw 'Source changed during backup' }
                    $digest = File-Hash $target
                    $rows += @{ path = $rel; size = $size; sha256 = $digest }
                    Log-File 'backup' $rel $size $digest
                }
                $manifestData = @{ format = 'codex-homeport'; schema = 1; created_utc = [DateTimeOffset]::UtcNow.ToString('o'); files = $rows }
                ($manifestData | ConvertTo-Json -Depth 8) | Set-Content -LiteralPath (Join-Path $BackupDir 'manifest.json') -Encoding UTF8
                $null = Verify-Snapshot $BackupDir
                Log-Event 'backup' 'PASS' @{ files = $rows.Count; backup = $BackupDir }
            } catch { Remove-Item -LiteralPath $BackupDir -Recurse -Force -ErrorAction SilentlyContinue; throw }
        } elseif ($Action -eq 'Verify') {
            $info = Verify-Snapshot $BackupDir
            Log-Event 'verify' 'PASS' @{ files = $info.files.Count }
        } elseif ($Action -eq 'Restore') {
            $info = Verify-Snapshot $BackupDir
            $planned = @()
            foreach ($row in $info.files) {
                $rel = [string]$row.path
                $src = Join-Path (Join-Path $BackupDir 'data') ($rel.Replace('/',[IO.Path]::DirectorySeparatorChar))
                $dst = Target-Path $rel
                $planned += @{ path = $rel; source = $src; target = $dst; existed = (Test-Path -LiteralPath $dst) }
            }
            $conflicts = @($planned | Where-Object {$_.existed}).Count
            if (-not $Apply) {
                Log-Event 'restore-plan' 'DRY_RUN' @{ entries = $planned.Count; existing_to_replace = $conflicts; new = ($planned.Count-$conflicts) }
            } else {
                Assert-PrivateDestination $BackupDir
                $rollback = "$BackupDir-rollback-$([DateTimeOffset]::UtcNow.ToString('yyyyMMddTHHmmssZ'))-$([guid]::NewGuid().ToString('N').Substring(0,8))"
                if (Test-Path -LiteralPath $rollback) { throw 'Rollback path already exists' }
                New-Item -ItemType Directory -Path (Join-Path $rollback 'old') -Force | Out-Null
                New-Item -ItemType Directory -Path (Join-Path $rollback 'staged') -Force | Out-Null
                $touched = [Collections.Generic.List[object]]::new()
                try {
                    foreach ($row in $planned) {
                        $staged = Join-Path (Join-Path $rollback 'staged') ($row.path.Replace('/',[IO.Path]::DirectorySeparatorChar))
                        New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($staged)) -Force | Out-Null
                        Copy-Item -LiteralPath $row.source -Destination $staged -ErrorAction Stop
                        $expected = @($info.files | Where-Object { $_.path -ceq $row.path })[0].sha256
                        if ((File-Hash $staged) -cne [string]$expected) { throw 'Source changed during staging' }
                        $row.source = $staged
                        if ($row.existed) {
                            if (-not (Test-Path -LiteralPath $row.target -PathType Leaf)) { throw 'Destination not regular file' }
                            $old = Join-Path (Join-Path $rollback 'old') ($row.path.Replace('/',[IO.Path]::DirectorySeparatorChar))
                            New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($old)) -Force | Out-Null
                            Copy-Item -LiteralPath $row.target -Destination $old -ErrorAction Stop
                        }
                    }
                    foreach ($row in $planned) {
                        New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($row.target)) -Force | Out-Null
                        $null = Target-Path $row.path
                        $tmp = "$($row.target).homeport-$([guid]::NewGuid().ToString('N'))"
                        try {
                            Copy-Item -LiteralPath $row.source -Destination $tmp -ErrorAction Stop
                            Move-Item -LiteralPath $tmp -Destination $row.target -Force -ErrorAction Stop
                        } finally { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
                        $touched.Add($row)
                        Log-File 'restore' $row.path ((Get-Item -LiteralPath $row.target).Length) (File-Hash $row.target)
                    }
                    foreach ($row in $info.files) {
                        $dst = Target-Path ([string]$row.path)
                        if ((File-Hash $dst) -cne [string]$row.sha256) { throw 'Post-restore verification failed' }
                    }
                    Log-Event 'restore' 'PASS' @{ files = $planned.Count; rollback = $rollback }
                } catch {
                    for ($i = $touched.Count - 1; $i -ge 0; $i--) {
                        $row = $touched[$i]
                        if ($row.existed) {
                            $old = Join-Path (Join-Path $rollback 'old') ($row.path.Replace('/',[IO.Path]::DirectorySeparatorChar))
                            Copy-Item -LiteralPath $old -Destination $row.target -Force -ErrorAction Continue
                        } else { Remove-Item -LiteralPath $row.target -Force -ErrorAction Continue }
                    }
                    throw
                }
            }
        }
    }
} catch {
    Log-Event $Action.ToLowerInvariant() 'FAIL' @{ error = $_.Exception.Message }
    exit 1
}
