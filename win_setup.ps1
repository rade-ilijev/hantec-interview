$dockerStartedNow = $false

function CheckDockerComposeRunning {
    $containers = docker-compose ps --format json | ConvertFrom-Json
    $runningCount = ($containers | Where-Object { $_.State -eq "running" } | Measure-Object).Count
    $isRunning = ($runningCount -eq 4)
    if ($isRunning) {
        Write-Host "All containers are running"
        return $true
    }
    Write-Host "Containers are not running"
    return $false
}

function CheckWordPressInstalled {
    $attempt = 0
    while ($attempt -lt 5) {
        $attempt++
        try {
            docker-compose exec -T wordpress bash -c "test -f /var/www/html/wp-config.php && grep -q 'DB_NAME' /var/www/html/wp-config.php"
            if ($LASTEXITCODE -eq 0) { return $true }
        } catch { Write-Host "Error: $_" }
        Start-Sleep -Seconds 2
    }
    return $false
}

function GetDockerComposeStatus {
    Write-Host "Checking running Docker Compose containers..."
    $containers = docker-compose ps --format json | ConvertFrom-Json
    $runningContainers = $containers | Where-Object { $_.State -eq "running" }
    $containerNames = $runningContainers | ForEach-Object { $_.Name }
    Write-Host "Running containers: $($containerNames -join ', ')"
    return $runningContainers
}

function InstallWordPress {
    Write-Host "Installing WordPress..."
    try {
        # Check if required containers are running with retries
        $maxAttempts = 5
        $attempt = 0
        $containersReady = $false

        while (-not $containersReady -and $attempt -lt $maxAttempts) {
            $attempt++
            Write-Host "Checking containers (Attempt $attempt of $maxAttempts)..."
            
            $containers = GetDockerComposeStatus
            $wordpressContainer = $containers | Where-Object { $_.Name -like "*wordpress*" -and $_.State -eq "running" }
            $mariadbContainer = $containers | Where-Object { $_.Name -like "*mariadb*" -and $_.State -eq "running" }

            if ($wordpressContainer -and $mariadbContainer) {
                # Check if MariaDB is ready to accept connections
                $mariadbReady = $false
                $dbAttempt = 0
                $maxDbAttempts = 5

                while (-not $mariadbReady -and $dbAttempt -lt $maxDbAttempts) {
                    $dbAttempt++
                    Write-Host "Checking MariaDB connection (Attempt $dbAttempt of $maxDbAttempts)..."
                    
                    try {
                        if($containers | Where-Object { $_.Name -like "*mariadb*" }) {
                                $mariadbReady = $true
                                Write-Host "MariaDB is ready to accept connections"
                            } else {
                            Write-Host "MariaDB is not ready yet..."
                            Start-Sleep -Seconds 5
                        }
                    } catch {
                        Write-Host "Error checking MariaDB: $_"
                        Start-Sleep -Seconds 5
                    }
                }

                if ($mariadbReady) {
                    $containersReady = $true
                    Write-Host "All required containers are running:"
                    Write-Host "- WordPress: $($wordpressContainer.Name)"
                    Write-Host "- MariaDB: $($mariadbContainer.Name)"
                } else {
                    Write-Host "MariaDB failed to become ready after $maxDbAttempts attempts"
                }
            } else {
                if (-not $wordpressContainer) {
                    Write-Host "WordPress container is not running"
                }
                if (-not $mariadbContainer) {
                    Write-Host "MariaDB container is not running"
                }
                
                if ($attempt -lt $maxAttempts) {
                    Write-Host "Waiting for containers to start..."
                    Start-Sleep -Seconds 10
                    # Check Docker Compose status again
                    $containers = GetDockerComposeStatus
                }
            }
        }

        if (-not $containersReady) {
            Write-Host "Error: Required containers failed to start after $maxAttempts attempts"
            $response = Read-Host "Do you want to restart Docker Compose? (y/n)"
            if ($response -eq "y") {
                if (-not (RestartDockerCompose)) {
                    return $false
                }
                # Try installation again after restart
                return InstallWordPress
            }
            return $false
        }

        # Capture and clean the output
        $rawOutput = docker-compose exec wordpress bash /var/www/html/setup-wordpress.sh 2>&1
        
        # Filter out progress lines and clean up newlines
        $cleanLines = $rawOutput -split '\r\n|\n' | Where-Object { 
            -not ($_ -match '^\s*\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+\s+') -and 
            -not ($_ -match 'Speed|Time|Dload|Upload|Total|Spent|Left|Current') -and
            $_ -ne ''
        }
        $output = [string]::Join("`n", $cleanLines)
        
        Write-Host $output
    
        return $true
    } catch {
        Write-Host "Error occurred: $_"
        $response = Read-Host "Do you want to continue anyway? (y/n)"
        return $response -eq "y"
    }
}

function RestartDockerCompose {
    Write-Host "Starting containers..."
    docker-compose down
    docker-compose up -d --build
    $script:dockerStartedNow = $true
    return CheckDockerComposeRunning
}

if (-not (CheckDockerComposeRunning)) {
    if ((Read-Host "Docker Compose not running. Start? (y/n)") -eq "y") {
        if (-not (RestartDockerCompose)) { exit 1 }
    } else { exit 1 }
}

if (-not (CheckWordPressInstalled)) {
    if ((Read-Host "WordPress not installed. Install now? (y/n)") -eq "y") {
        if (-not (InstallWordPress)) { exit 1 }
    }
}

# Only ask about restart if Docker wasn't just started
if (-not $dockerStartedNow) {
    if ((Read-Host "`nRestart Docker Compose? (y/n)") -eq "y") {
        if (-not (RestartDockerCompose)) { exit 1 }
    }
}

if ((Read-Host "`nRun WordPress setup? (y/n)") -eq "y") {
    if (-not (InstallWordPress)) { exit 1 }
}

Write-Host "`nDone!"
exit 0