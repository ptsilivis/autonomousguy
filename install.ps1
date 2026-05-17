# autonomousguy installer for Windows — no Node.js required
# Usage (from a cloned repo):
#   .\install.ps1
#
# Or download and run in one step:
#   irm https://raw.githubusercontent.com/ptsilivis/autonomousguy/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$VERSION   = "0.1.0"
$ToolNames = @("Claude Code","GitHub Copilot","Cursor","Gemini CLI","ChatGPT Codex","OpenCode","JetBrains AI","General Agent")
$ToolDirs  = @(".claude",".github",".cursor",".gemini",".agents",".opencode",".idea",".autonomousguy")

# ---------------------------------------------------------------------------
# Locate skills directory
# ---------------------------------------------------------------------------
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$SkillsDir = Join-Path $ScriptDir "skills"

if (-not (Test-Path $SkillsDir)) {
  # Running via iex — download the archive
  Write-Host "Downloading autonomousguy skills..."
  $TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
  New-Item -ItemType Directory -Path $TmpDir | Out-Null
  $ZipPath = Join-Path $TmpDir "autonomousguy.zip"
  Invoke-WebRequest -Uri "https://github.com/ptsilivis/autonomousguy/archive/refs/heads/master.zip" -OutFile $ZipPath
  Expand-Archive -Path $ZipPath -DestinationPath $TmpDir
  $SkillsDir = Join-Path $TmpDir "autonomousguy-master" "skills"
}

if (-not (Test-Path $SkillsDir)) {
  Write-Error "Could not locate skills/ directory."
  exit 1
}

# ---------------------------------------------------------------------------
# 1. Intro
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "autonomousguy v$VERSION"
Write-Host "AI skill prompts for embedded automotive engineers"
Write-Host ""

# ---------------------------------------------------------------------------
# 2. Scope
# ---------------------------------------------------------------------------
Write-Host "Install scope:"
Write-Host "  1) Local  - installs into the current directory"
Write-Host "  2) Global - installs into your home directory"
$scopeChoice = Read-Host "Enter 1 or 2 [1]"
if (-not $scopeChoice) { $scopeChoice = "1" }

if ($scopeChoice -eq "2") {
  $BaseDir    = $env:USERPROFILE
  $ScopeLabel = "global"
} else {
  $BaseDir    = (Get-Location).Path
  $ScopeLabel = "local"
}

# ---------------------------------------------------------------------------
# 3. Tools
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Which AI tool(s)? Enter comma-separated numbers, or 'a' for all."
for ($i = 0; $i -lt $ToolNames.Count; $i++) {
  Write-Host ("  {0}) {1}" -f ($i + 1), $ToolNames[$i])
}
$toolsInput = Read-Host "Selection [a]"
if (-not $toolsInput) { $toolsInput = "a" }

$selectedToolIndices = @()
if ($toolsInput -match '^[Aa]$') {
  $selectedToolIndices = 0..($ToolNames.Count - 1)
} else {
  foreach ($part in ($toolsInput -split ',')) {
    $num = $part.Trim()
    if ($num -match '^\d+$') {
      $idx = [int]$num - 1
      if ($idx -ge 0 -and $idx -lt $ToolNames.Count) { $selectedToolIndices += $idx }
    }
  }
}

if ($selectedToolIndices.Count -eq 0) {
  Write-Error "No valid tools selected."
  exit 1
}

# ---------------------------------------------------------------------------
# 4. Skills
# ---------------------------------------------------------------------------
$categories = Get-ChildItem -Path $SkillsDir -Directory | Sort-Object Name | Select-Object -ExpandProperty Name
$total = ($categories | ForEach-Object {
  (Get-ChildItem (Join-Path $SkillsDir $_) -Filter "*.md").Count
} | Measure-Object -Sum).Sum

Write-Host ""
$installAll = Read-Host "Install all $total skills? [Y/n]"
if (-not $installAll) { $installAll = "y" }

$selectedCats = $categories

if ($installAll -notmatch '^[Yy]') {
  Write-Host ""
  Write-Host "Available categories:"
  for ($i = 0; $i -lt $categories.Count; $i++) {
    $count = (Get-ChildItem (Join-Path $SkillsDir $categories[$i]) -Filter "*.md").Count
    Write-Host ("  {0}) {1,-22} ({2} skills)" -f ($i + 1), $categories[$i], $count)
  }
  $catsInput = Read-Host "Enter comma-separated numbers (or 'a' for all) [a]"
  if (-not $catsInput) { $catsInput = "a" }

  if ($catsInput -notmatch '^[Aa]$') {
    $selectedCats = @()
    foreach ($part in ($catsInput -split ',')) {
      $num = $part.Trim()
      if ($num -match '^\d+$') {
        $idx = [int]$num - 1
        if ($idx -ge 0 -and $idx -lt $categories.Count) { $selectedCats += $categories[$idx] }
      }
    }
  }
}

if ($selectedCats.Count -eq 0) {
  Write-Error "No categories selected."
  exit 1
}

# ---------------------------------------------------------------------------
# 5. Copy
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Installing..."
Write-Host ""
$copied = 0

foreach ($idx in $selectedToolIndices) {
  $toolName = $ToolNames[$idx]
  $toolDir  = $ToolDirs[$idx]
  $destBase = Join-Path $BaseDir "$toolDir\skills\autonomousguy"

  foreach ($cat in $selectedCats) {
    $srcCat  = Join-Path $SkillsDir $cat
    $destCat = Join-Path $destBase $cat
    New-Item -ItemType Directory -Path $destCat -Force | Out-Null
    Get-ChildItem "$srcCat\*.md" | ForEach-Object {
      Copy-Item $_.FullName -Destination $destCat
      $copied++
    }
  }

  $rel = if ($ScopeLabel -eq "global") { "~\$toolDir\skills\autonomousguy" } `
         else                          { ".\$toolDir\skills\autonomousguy" }
  Write-Host ("  + {0,-18} -> {1}" -f $toolName, $rel)
}

# ---------------------------------------------------------------------------
# 6. Summary
# ---------------------------------------------------------------------------
$skillCount = [math]::Floor($copied / $selectedToolIndices.Count)
Write-Host ""
Write-Host "Installed $skillCount skills across $($selectedToolIndices.Count) tool(s)."
Write-Host ""
Write-Host "To use a skill: paste its contents into your AI tool of choice,"
Write-Host "or invoke it by name if your tool supports skill discovery."
Write-Host ""

if ($selectedCats -contains "workspace") {
  Write-Host "Tip: run the [codebase-analysis] skill first in a new project to"
  Write-Host "generate .autonomousguy/CODEBASE_MAP.md — all other skills will"
  Write-Host "reference it automatically."
  Write-Host ""
}
