# Smoke test for the local Docker Compose stack
# - Builds and starts the stack
# - Waits for backend readiness
# - Posts a task and verifies it's returned
# - Checks frontend is serving

$projectRoot = "D:\project"
$composeFile = Join-Path $projectRoot 'docker-compose.yml'

function ExitWithError($msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

Write-Host "Starting smoke test..."

# Start compose stack
Write-Host "Bringing up Docker Compose stack (this may take a minute)..."
$up = docker compose -f $composeFile up -d --build 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host $up
    ExitWithError "docker compose up failed"
}

# Helper to poll an HTTP endpoint
function Wait-ForHttp($url, $expectedContent = $null, $timeoutSec=60) {
    $start = Get-Date
    while (((Get-Date) - $start).TotalSeconds -lt $timeoutSec) {
        try {
            $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 5 -ErrorAction Stop
            $content = $resp.Content
            if ($expectedContent) {
                if ($content -match $expectedContent) { return @{ok=$true; content=$content} }
            } else {
                return @{ok=$true; content=$content}
            }
        } catch {
            Start-Sleep -Seconds 2
        }
    }
    return @{ok=$false; content=$null}
}

# Wait for backend /healthz
$health = Wait-ForHttp -url 'http://localhost:3500/healthz' -timeoutSec 60
if (-not $health.ok) { ExitWithError 'Backend /healthz did not respond in time' }
Write-Host "Backend /healthz: $($health.content)"

# Wait for backend /ready
$ready = Wait-ForHttp -url 'http://localhost:3500/ready' -timeoutSec 60
if (-not $ready.ok) { ExitWithError 'Backend /ready did not respond in time' }
Write-Host "/ready response: $($ready.content)"

if ($ready.content -notmatch 'Ready') {
    ExitWithError 'Backend readiness check failed: not Ready'
}

# Create a task
$body = '{"task":"smoke-test-task"}'
try {
    $post = Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:3500/api/tasks' -Method POST -Body $body -ContentType 'application/json' -TimeoutSec 10 -ErrorAction Stop
    Write-Host "POST /api/tasks response: $($post.Content)"
} catch {
    ExitWithError "POST /api/tasks failed: $_"
}

# Confirm via GET
try {
    $get = Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:3500/api/tasks' -TimeoutSec 10 -ErrorAction Stop
    Write-Host "GET /api/tasks returned: $($get.Content)"
    if ($get.Content -notmatch 'smoke-test-task') { ExitWithError 'Created task not found in GET /api/tasks' }
} catch {
    ExitWithError "GET /api/tasks failed: $_"
}

# Check frontend serving
$front = Wait-ForHttp -url 'http://localhost:8080' -timeoutSec 30
if (-not $front.ok) { ExitWithError 'Frontend did not respond in time' }
Write-Host "Frontend HTTP root responded (length: $($front.content.Length))"

Write-Host "Smoke test completed successfully." -ForegroundColor Green
exit 0
