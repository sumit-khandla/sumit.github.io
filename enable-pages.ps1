# Enables GitHub Pages on sumit-khandla/sumit.github.io via the GitHub API.
# Run in PowerShell after creating a token: https://github.com/settings/tokens
# Required scope: repo (full control of private repositories)

$ErrorActionPreference = "Stop"
$owner = "sumit-khandla"
$repo = "sumit.github.io"

Write-Host ""
Write-Host "GitHub Pages is OFF for this repo (that causes the 404)." -ForegroundColor Yellow
Write-Host "This script turns it ON using the GitHub API." -ForegroundColor Yellow
Write-Host ""

$token = $env:GITHUB_TOKEN
if (-not $token) {
    $token = Read-Host "Paste a GitHub Personal Access Token (classic, repo scope)"
}

$headers = @{
    Accept        = "application/vnd.github+json"
    Authorization = "Bearer $token"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent"  = "sumit-github-io-setup"
}

$body = @{
    source = @{
        branch = "main"
        path   = "/"
    }
    build_type = "legacy"
} | ConvertTo-Json

try {
    $pages = Invoke-RestMethod -Method POST -Uri "https://api.github.com/repos/$owner/$repo/pages" -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "Pages enabled." -ForegroundColor Green
    Write-Host "Live URL: $($pages.html_url)" -ForegroundColor Green
}
catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 409) {
        Write-Host "Pages already exists. Checking status..." -ForegroundColor Cyan
        $pages = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/pages" -Headers $headers
        Write-Host "Live URL: $($pages.html_url)" -ForegroundColor Green
    }
    else {
        Write-Host "Error: $($_.ErrorDetails.Message)" -ForegroundColor Red
        Write-Host "Or enable manually: https://github.com/$owner/$repo/settings/pages" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "Open this URL in 2-5 minutes:" -ForegroundColor Cyan
Write-Host "  https://$owner.github.io/$repo/" -ForegroundColor White
Write-Host ""
Write-Host "For https://$owner.github.io/ (no path), rename the repo to $owner.github.io on GitHub." -ForegroundColor DarkGray
