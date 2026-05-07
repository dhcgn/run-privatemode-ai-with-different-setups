$url = "http://localhost:3000"

Write-Host "Starting Privatemode Proxy + Open WebUI..." -ForegroundColor Cyan
docker compose up -d

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

$openUrl = "http://localhost:3000/?model=kimi-latest"

Write-Host ""
Write-Host "Open WebUI is ready at:" -ForegroundColor Green
Write-Host "  $openUrl" -ForegroundColor Yellow
Write-Host ""
Start-Process $openUrl
