[CmdletBinding()]
param(
    [string]$MinecraftVersion = "1.21.7",
    [string]$TestName = ""
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$RootDir = Split-Path -Parent $PSScriptRoot
$ServerDir = Join-Path $RootDir "ci-server-$MinecraftVersion"
$ModsDir = Join-Path $ServerDir "mods"
$DatapacksDir = Join-Path $ServerDir "world\datapacks"
$FabricApiVersion = if ($MinecraftVersion -eq "1.21.7") { "0.129.0+1.21.7" } else { "0.136.1+1.21.8" }
$PackTestVersion = "2.2.0"

New-Item -ItemType Directory -Force -Path $ModsDir, $DatapacksDir | Out-Null

$loaderVersions = Invoke-RestMethod "https://meta.fabricmc.net/v2/versions/loader/$MinecraftVersion"
$loaderVersion = ($loaderVersions | Where-Object { $_.loader.stable })[0].loader.version
$installerVersions = Invoke-RestMethod "https://meta.fabricmc.net/v2/versions/installer"
$installerVersion = ($installerVersions | Where-Object { $_.stable })[0].version

$serverUrl = "https://meta.fabricmc.net/v2/versions/loader/$MinecraftVersion/$loaderVersion/$installerVersion/server/jar"
Invoke-WebRequest $serverUrl -OutFile (Join-Path $ServerDir "server.jar")

$fabricVersions = Invoke-RestMethod "https://api.modrinth.com/v2/project/P7dR8mSH/version"
$packTestVersions = Invoke-RestMethod "https://api.modrinth.com/v2/project/XsKUhp45/version"
$fabricVersion = $fabricVersions | Where-Object { $_.version_number -eq $FabricApiVersion } | Select-Object -First 1
$packTestVersion = $packTestVersions | Where-Object { $_.version_number -eq $PackTestVersion } | Select-Object -First 1

Invoke-WebRequest $fabricVersion.files[0].url -OutFile (Join-Path $ModsDir "fabric-api.jar")
Invoke-WebRequest $packTestVersion.files[0].url -OutFile (Join-Path $ModsDir "packtest.jar")

Remove-Item (Join-Path $DatapacksDir "HeartStakes"), (Join-Path $DatapacksDir "heartstakes-tests") -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $RootDir "HeartStakes") (Join-Path $DatapacksDir "HeartStakes") -Recurse
Copy-Item (Join-Path $RootDir "tests\heartstakes-testpack") (Join-Path $DatapacksDir "heartstakes-tests") -Recurse
if ($TestName) {
    Get-ChildItem (Join-Path $DatapacksDir "heartstakes-tests\data\heartstakes\test") -Filter "*.mcfunction" |
        Where-Object { $_.BaseName -ne $TestName } |
        Remove-Item -Force
}

$javaArgs = @("-Xmx2G", "-Dpacktest.auto=true", "-Dpacktest.auto.annotations=true", "-jar", "server.jar", "nogui")
$process = Start-Process java -ArgumentList $javaArgs -WorkingDirectory $ServerDir -PassThru -NoNewWindow
$logPath = Join-Path $ServerDir "logs\latest.log"
$deadline = (Get-Date).AddSeconds(180)

function Stop-TestServer {
    if ($null -eq $process) {
        return
    }

    $processIds = @($process.Id)
    do {
        $children = @(Get-CimInstance Win32_Process | Where-Object { $processIds -contains $_.ParentProcessId })
        if ($children.Count -gt 0) {
            $processIds += $children.ProcessId
        }
    } while ($children.Count -gt 0)

    foreach ($processId in ($processIds | Sort-Object -Descending -Unique)) {
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
}

while ((Get-Date) -lt $deadline) {
    if (Test-Path $logPath) {
        $log = Get-Content $logPath -Raw
        if ($log -match "All \d+ required tests passed") {
            if (-not $process.WaitForExit(10000)) {
                Stop-TestServer
            }
            exit 0
        }
        if ($log -match "required tests failed|GAME TESTS FAILED") {
            Stop-TestServer
            exit 1
        }
    }

    if ($process.HasExited) {
        exit $process.ExitCode
    }
    Start-Sleep -Seconds 1
}

Stop-TestServer
Write-Error "PackTest did not finish within 180 seconds."
exit 124
