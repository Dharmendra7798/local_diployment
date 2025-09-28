# Enables shell integration (Docker completion, optional posh-git) for PowerShell
# This script is idempotent and appends a guarded block to the current user's PowerShell profile.

$profilePath = $PROFILE
$markerStart = "# >>> project shell integration start"
$markerEnd = "# <<< project shell integration end"

if (-not (Test-Path -Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$profileContent = Get-Content -Raw -Path $profilePath -ErrorAction SilentlyContinue
if ($profileContent -notmatch [regex]::Escape($markerStart)) {
    $block = @"
$markerStart
# Enable Docker CLI tab completion when Docker is available
try {
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        $completion = docker completion powershell 2>$null
        if ($completion) { Invoke-Expression $completion }
    }
    if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
        # docker-compose (v1) may provide completion via the binary
        $completion = docker-compose completion powershell 2>$null
        if ($completion) { Invoke-Expression $completion }
    }
} catch {
    Write-Verbose "Docker completion not enabled: $_"
}

# Import posh-git automatically if installed (adds git prompt and completions)
if (Get-Module -ListAvailable -Name posh-git) {
    try {
        Import-Module posh-git -ErrorAction SilentlyContinue
    } catch {
        Write-Verbose "posh-git import failed: $_"
    }
}

# Optionally: add more completion hooks here
$markerEnd
"@

    Add-Content -Path $profilePath -Value $block -Encoding UTF8
    Write-Output "Appended shell integration block to $profilePath"
} else {
    Write-Output "Shell integration block already present in $profilePath"
}
