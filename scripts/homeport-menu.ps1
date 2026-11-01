#requires -Version 7.0
# User-facing launcher; delegates all changes to the native PowerShell engine.
$ErrorActionPreference = 'Stop'
$engine = Join-Path $PSScriptRoot 'homeport.ps1'
$backupRoot = Join-Path $HOME 'CodexHomeportBackups'
Write-Host 'Codex Homeport 0.1.0 (unofficial)' -ForegroundColor Cyan
Write-Host '1 - Status / read-only diagnostics'
Write-Host '2 - Install/update OFFICIAL Codex CLI'
Write-Host '3 - Export private profile snapshot'
Write-Host '4 - Verify private snapshot'
Write-Host '5 - Restore plan (dry-run)'
Write-Host '6 - Restore profile (requires explicit confirmation)'
Write-Host '0 - Exit'
$choice = Read-Host 'Choose action'
try {
    switch ($choice) {
        '1' { & $engine -Action Status }
        '2' {
            $confirm = Read-Host 'Fetch and execute official OpenAI installer? type INSTALL'
            if ($confirm -cne 'INSTALL') { throw 'Installation cancelled' }
            & $engine -Action Install
        }
        '3' {
            $snapshot = Join-Path $backupRoot ('snapshot-' + [DateTimeOffset]::UtcNow.ToString('yyyyMMddTHHmmssZ') + '-' + [guid]::NewGuid().ToString('N').Substring(0,6))
            & $engine -Action Backup -BackupDir $snapshot
            Write-Host "Keep this PRIVATE: $snapshot"
        }
        { $_ -in @('4','5','6') } {
            $snapshot = Read-Host 'Enter full PRIVATE snapshot folder path'
            if (-not $snapshot) { throw 'Snapshot path required' }
            if ($choice -eq '4') { & $engine -Action Verify -BackupDir $snapshot }
            if ($choice -eq '5') { & $engine -Action Restore -BackupDir $snapshot }
            if ($choice -eq '6') {
                & $engine -Action Restore -BackupDir $snapshot
                if ($LASTEXITCODE -ne 0) { throw 'Preflight failure; nothing written' }
                $confirm = Read-Host 'Close Codex/Desktop; type RESTORE to apply'
                if ($confirm -cne 'RESTORE') { throw 'Restore cancelled' }
                & $engine -Action Restore -BackupDir $snapshot -Apply
            }
        }
        '0' { return }
        default { throw 'Unknown action' }
    }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}
