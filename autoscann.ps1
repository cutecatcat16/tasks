# autoscann.ps1

param(
    [string]$RequestFile = $args[0],
    [string]$ProxyHost = $args[1],
    [string]$ProxyPort = $args[2]
)

# Check if all required arguments are present
if (-not $RequestFile -or -not $ProxyHost -or -not $ProxyPort) {
    Write-Host "Usage: .\autoscann.ps1 <request_file> <proxy_host> <proxy_port>"
    Write-Host "Example: .\autoscann.ps1 request.txt 127.0.0.1 8080"
    exit 1
}

# Get full path and directory for log
$RequestFullPath = Resolve-Path $RequestFile
$LogFile = "$($RequestFullPath).log"

# Build commands with output redirection to log file
$commixCmd  = "python3 commix/commix.py -r `"$RequestFile`" --batch --proxy http://$ProxyHost`:$ProxyPort --technique T --level 3 >> `"$LogFile`" 2>&1"
$sqlmapCmd  = "python3 sqlmap/sqlmap.py -r `"$RequestFile`" --batch --proxy=http://$ProxyHost`:$ProxyPort >> `"$LogFile`" 2>&1"
$sstimapCmd = "python3 SSTImap/sstimap.py -r `"$RequestFile`" --proxy http://$ProxyHost`:$ProxyPort >> `"$LogFile`" 2>&1"
$ssrfmapCmd = "python3 SSRFmap/ssrfmap.py -r `"$RequestFile`" --proxy http://$ProxyHost`:$ProxyPort >> `"$LogFile`" 2>&1"
$lfimapCmd  = "python3 LFImap/lfimap.py -r `"$RequestFile`" --proxy http://$ProxyHost`:$ProxyPort >> `"$LogFile`" 2>&1"

# Run commands and log headers
"`n===================================================" | Out-File -Append $LogFile
"Running Commix..." | Out-File -Append $LogFile
Invoke-Expression $commixCmd

"`n===================================================" | Out-File -Append $LogFile
"Running sqlmap..." | Out-File -Append $LogFile
Invoke-Expression $sqlmapCmd

"`n===================================================" | Out-File -Append $LogFile
"Running sstimap..." | Out-File -Append $LogFile
Invoke-Expression $sstimapCmd

"`n===================================================" | Out-File -Append $LogFile
"Running ssrfmap..." | Out-File -Append $LogFile
Invoke-Expression $ssrfmapCmd

"`n===================================================" | Out-File -Append $LogFile
"Running lfimap..." | Out-File -Append $LogFile
Invoke-Expression $lfimapCmd

"`n===================================================" | Out-File -Append $LogFile
Write-Host "Scan completed. Output saved to: $LogFile"
