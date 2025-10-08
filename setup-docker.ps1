# Docker Setup Script for Jenkins Pipeline
Write-Host "Checking Docker status..." -ForegroundColor Green

# Check if Docker Desktop is running
$dockerProcess = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
if ($dockerProcess) {
    Write-Host "Docker Desktop is running" -ForegroundColor Green
} else {
    Write-Host "Docker Desktop is not running. Attempting to start..." -ForegroundColor Yellow
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" -WindowStyle Hidden
    Start-Sleep 30
}

# Check Docker service
$dockerService = Get-Service "com.docker.service" -ErrorAction SilentlyContinue
if ($dockerService -and $dockerService.Status -eq "Running") {
    Write-Host "Docker service is running" -ForegroundColor Green
} else {
    Write-Host "Docker service issues detected" -ForegroundColor Red
}

# Test Docker connectivity
try {
    docker --version
    docker info
    Write-Host "Docker is accessible" -ForegroundColor Green
} catch {
    Write-Host "Docker connectivity failed: $_" -ForegroundColor Red
    exit 1
}