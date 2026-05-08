$composeDir = Join-Path $PSScriptRoot "docker-compose"

Write-Host "Stopping containers and removing volumes..." -ForegroundColor Cyan
Push-Location $composeDir
try {
    docker compose down --volumes 2>&1 | Out-Null
} finally {
    Pop-Location
}

Write-Host "Removing volumes..." -ForegroundColor Cyan
docker volume rm open-webui-data-single-user 2>&1 | Out-Null

Write-Host ""
Write-Host "State cleared. Run .\start.ps1 to start fresh." -ForegroundColor Green
