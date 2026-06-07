# ============================================================
#  add-newtab-links.ps1
#  Adds target="_blank" rel="noopener noreferrer" to EXTERNAL
#  links (http:// or https://) in all .html files in this folder.
#  Internal page links (about-us.html, etc.) are left unchanged.
#
#  HOW TO RUN:
#    1. Put this file in  C:\SAHAS_WEB
#    2. Open PowerShell, then:
#         cd C:\SAHAS_WEB
#         .\add-newtab-links.ps1
#  A backup of every file is saved to  C:\SAHAS_WEB\_backup_before_newtab
#  before any change is made.
# ============================================================

$folder = Get-Location
$backupDir = Join-Path $folder "_backup_before_newtab"

# --- make a backup of all html files first ---
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}
Get-ChildItem -Path $folder -Filter *.html -File | ForEach-Object {
    Copy-Item $_.FullName -Destination $backupDir -Force
}
Write-Host "Backup saved to: $backupDir" -ForegroundColor Cyan
Write-Host ""

# --- regex: match an <a ...> opening tag whose href is external ---
# (href points to http:// or https://)
$pattern = '<a\b(?=[^>]*\bhref\s*=\s*["'']https?://)[^>]*?>'

$totalChanged = 0

Get-ChildItem -Path $folder -Filter *.html -File | ForEach-Object {
    $file = $_
    $content = Get-Content -Path $file.FullName -Raw
    $countInFile = 0

    $evaluator = {
        param($m)
        $tag = $m.Value
        # skip if this tag already has a target= attribute
        if ($tag -match '\btarget\s*=') {
            return $tag
        }
        $script:countInFile++
        # insert the attributes just before the closing >
        return ($tag -replace '\s*>$', ' target="_blank" rel="noopener noreferrer">')
    }

    $newContent = [System.Text.RegularExpressions.Regex]::Replace(
        $content, $pattern, $evaluator,
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    if ($countInFile -gt 0) {
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host ("{0,-30} {1} external link(s) updated" -f $file.Name, $countInFile) -ForegroundColor Green
        $totalChanged += $countInFile
    } else {
        Write-Host ("{0,-30} no external links to change" -f $file.Name) -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "Done. $totalChanged external link(s) updated across all files." -ForegroundColor Yellow
Write-Host "If anything looks wrong, restore from: $backupDir" -ForegroundColor Yellow
