<#
.SYNOPSIS
  Enterprise-style GPO backup script with timestamped folders, retention, and logging.

.NOTES
  Author: RajKumar (lab baseline)
  Run As: Domain Admin or delegated GPO backup account
#>

param(
    [string]$BackupRoot = "C:\Users\Administrator\Desktop\GPO-Backup\",
    [int]$DailyRetentionDays = 14,
    [int]$WeeklyRetentionDays = 90,
    [int]$MonthlyRetentionDays = 365,
    [string]$LogPath = "C:\Users\Administrator\Desktop\GPO-Backup\Logs\GPO-Backup.log"
)

# Ensure modules
Import-Module GroupPolicy -ErrorAction Stop

# Create base folders
$folders = @(
    "$BackupRoot\Daily",
    "$BackupRoot\Weekly",
    "$BackupRoot\Monthly",
    "$BackupRoot\Change-Control",
    "$BackupRoot\Logs"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }
}

# Logging helper
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp [$Level] $Message"
    Add-Content -Path $LogPath -Value $entry
    Write-Output $entry
}

Write-Log "===== GPO Backup Job Started ====="

# Determine backup type (Daily/Weekly/Monthly)
$today = Get-Date
$dayOfWeek = $today.DayOfWeek
$dayOfMonth = $today.Day

$backupType = "Daily"
if ($dayOfWeek -eq 'Sunday') { $backupType = "Weekly" }
if ($dayOfMonth -eq 1) { $backupType = "Monthly" }

$targetRoot = Join-Path $BackupRoot $backupType
$timestampFolder = $today.ToString("yyyy-MM-dd_HH-mm-ss")
$backupPath = Join-Path $targetRoot $timestampFolder

Write-Log "Backup type determined: $backupType"
Write-Log "Backup path: $backupPath"

# Create timestamped backup folder
New-Item -ItemType Directory -Path $backupPath | Out-Null

# Perform backup
try {
    Backup-GPO -All -Path $backupPath -ErrorAction Stop | Out-Null
    Write-Log "Backup-GPO completed successfully."
}
catch {
    Write-Log "Backup-GPO failed: $_" "ERROR"
    exit 1
}

# Retention cleanup
function Cleanup-OldBackups {
    param(
        [string]$Path,
        [int]$RetentionDays
    )

    Write-Log "Running cleanup in $Path (retention: $RetentionDays days)"

    if (-not (Test-Path $Path)) { return }

    $cutoff = (Get-Date).AddDays(-$RetentionDays)

    Get-ChildItem -Path $Path -Directory | ForEach-Object {
        if ($_.LastWriteTime -lt $cutoff) {
            Write-Log "Deleting old backup folder: $($_.FullName)"
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

switch ($backupType) {
    "Daily"   { Cleanup-OldBackups -Path "$BackupRoot\Daily"   -RetentionDays $DailyRetentionDays }
    "Weekly"  { Cleanup-OldBackups -Path "$BackupRoot\Weekly"  -RetentionDays $WeeklyRetentionDays }
    "Monthly" { Cleanup-OldBackups -Path "$BackupRoot\Monthly" -RetentionDays $MonthlyRetentionDays }
}

Write-Log "===== GPO Backup Job Completed ====="