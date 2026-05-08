$url = "http://localhost:3000"
$composeDir = Join-Path $PSScriptRoot "docker-compose"

$envFile = Join-Path $composeDir ".env"
if (-not (Test-Path $envFile)) {
    Write-Host "ERROR: .env file not found." -ForegroundColor Red
    Write-Host "  1. Copy sample.env to .env:" -ForegroundColor Yellow
    Write-Host "       Copy-Item docker-compose\sample.env docker-compose\.env" -ForegroundColor Yellow
    Write-Host "  2. Open docker-compose\.env and set your privatemode.ai API key." -ForegroundColor Yellow
    exit 1
}

Push-Location $composeDir
try {
    Write-Host "Pulling latest Docker images..." -ForegroundColor Cyan
    docker compose pull

    Write-Host "Starting Privatemode Proxy + Open WebUI..." -ForegroundColor Cyan
    docker compose up -d
} finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to start containers." -ForegroundColor Red
    exit 1
}

Write-Host "Waiting for Open WebUI to become ready..." -ForegroundColor Cyan

while ($true) {
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 1 -ErrorAction Stop
        if ($response.StatusCode -lt 400) { break }
    } catch {
        # not ready yet
    }
    Start-Sleep -Seconds 1
    Write-Host "  ...still waiting" -ForegroundColor DarkGray
}

Write-Host "Open WebUI is ready and will open in your default browser in 1 second..." -ForegroundColor Green
$openUrl = "http://localhost:3000/?model=kimi-latest"

Write-Host ""
Write-Host "Open WebUI is ready at:" -ForegroundColor Green
Write-Host "  $openUrl" -ForegroundColor Yellow
Write-Host ""

Start-Sleep -Seconds 1
Start-Process $openUrl
