param(
    [string[]]$Agents = @('all'),
    [switch]$Force,
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Rules = Join-Path $Root 'rules/progressive-agentic-coding.md'
$Skills = Join-Path $Root 'skills'
$Allowed = @('all', 'cursor', 'claude', 'codex', 'opencode')
$Replace = [bool]$Force
$Asked = $false
$Prompted = $false
$Selected = @()
foreach ($value in $Agents) {
    foreach ($agent in ($value -split ',')) {
        $normalized = $agent.Trim().ToLowerInvariant()
        if ($normalized -notin $Allowed) { throw "Unsupported agent: $agent" }
        if ($normalized -eq 'all') { $Selected = @('cursor', 'claude', 'codex', 'opencode'); break }
        if ($normalized -notin $Selected) { $Selected += $normalized }
    }
    if ('all' -in ($Agents -split ',')) { break }
}
if ($Selected.Count -eq 0) { $Selected = @('cursor', 'claude', 'codex', 'opencode') }

$Start = '# BEGIN PROGRESSIVE AGENTIC CODING (managed)'
$End = '# END PROGRESSIVE AGENTIC CODING (managed)'
function Confirm-Overwrite {
    if ($Replace -or $Asked -or $WhatIf) { return }
    $script:Asked = $true
    $interactive = $false
    try { $interactive = -not [Console]::IsInputRedirected } catch { $interactive = $false }
    if (-not $interactive) { return }
    $script:Prompted = $true
    $reply = Read-Host 'Overwrite existing installed files? [y/N]'
    if ($reply -match '^(?i:y|yes)$') { $script:Replace = $true }
}
function Backup-Item([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        $tag = (Get-Date -Format 'yyyyMMddHHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 6)
        $backup = "$Path.bak.$tag"
        if ($WhatIf) { Write-Host "[preview] Backup $Path to $backup" }
        else { Copy-Item -LiteralPath $Path -Destination $backup -Recurse -Force }
    }
}
function Install-Skills([string]$Dir) {
    foreach ($name in @('progressive-build', 'progressive-review', 'reconcile-feedback', 'open-review-worktree', 'review-loop')) {
        $source = Join-Path $Skills $name
        $destination = Join-Path $Dir $name
        if (Test-Path -LiteralPath $destination) {
            Confirm-Overwrite
            if (-not $Replace) {
                if ($Prompted) {
                    Write-Host "[skip] $destination (left unchanged)"
                } else {
                    Write-Host "[skip] $destination (already exists; pass -Force to replace)"
                }
                continue
            }
            Backup-Item $destination
            if (-not $WhatIf) { Remove-Item -LiteralPath $destination -Recurse -Force }
        }
        if ($WhatIf) { Write-Host "[preview] Copy $source to $destination"; continue }
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        Copy-Item -LiteralPath $source -Destination $destination -Recurse
        Write-Host "[installed] $destination"
    }
}
function Install-Rule([string]$Path) {
    $original = if (Test-Path -LiteralPath $Path) { Get-Content -LiteralPath $Path -Raw } else { '' }
    $block = "$Start`n" + (Get-Content -LiteralPath $Rules -Raw).TrimEnd() + "`n$End"
    if ($original.Contains($Start)) {
        $a = $original.IndexOf($Start)
        $b = $original.IndexOf($End, $a)
        if ($b -lt 0) { throw "Incomplete managed block in $Path. Fix it manually first." }
        $newText = $original.Substring(0, $a) + $block + $original.Substring($b + $End.Length)
    } else {
        $newText = $original.TrimEnd() + "`n`n" + $block + "`n"
    }
    if ($newText -eq $original) { Write-Host "[unchanged] $Path"; return }
    if ($WhatIf) { Write-Host "[preview] Update managed rules block in $Path"; return }
    Backup-Item $Path
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    [System.IO.File]::WriteAllText($Path, $newText, [System.Text.UTF8Encoding]::new($false))
    Write-Host "[installed] $Path"
}

if ('cursor' -in $Selected) {
    Install-Skills (Join-Path $HOME '.cursor/skills')
    Write-Host "[manual] Paste $Rules into Cursor > Customize > Rules > User Rules"
    Write-Host '[manual] To sync to Cursor Cloud Agents: Settings > Agents > Context and Tools > Sync Skills for Cloud Agents'
}
if ('claude' -in $Selected) {
    Install-Skills (Join-Path $HOME '.claude/skills')
    Install-Rule (Join-Path $HOME '.claude/CLAUDE.md')
}
if ('codex' -in $Selected -or 'opencode' -in $Selected) {
    Install-Skills (Join-Path $HOME '.agents/skills')
}
if ('codex' -in $Selected) { Install-Rule (Join-Path $HOME '.codex/AGENTS.md') }
if ('opencode' -in $Selected) { Install-Rule (Join-Path $HOME '.config/opencode/AGENTS.md') }
if ($WhatIf) { Write-Host 'Preview only; no files were modified.' }
