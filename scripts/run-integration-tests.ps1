[CmdletBinding()]
param(
    [string]$MinecraftVersion = "1.21.7"
)

$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $PSScriptRoot
$ServerDir = Join-Path $RootDir "ci-server-$MinecraftVersion"
$ModsDir = Join-Path $ServerDir "mods"
$DatapacksDir = Join-Path $ServerDir "world\datapacks"

New-Item -ItemType Directory -Force -Path $ModsDir, $DatapacksDir | Out-Null

$loaderVersions = Invoke-RestMethod "https://meta.fabricmc.net/v2/versions/loader/$MinecraftVersion"
$loaderVersion = ($loaderVersions | Where-Object { $_.loader.stable })[0].loader.version
$installerVersions = Invoke-RestMethod "https://meta.fabricmc.net/v2/versions/installer"
$installerVersion = ($installerVersions | Where-Object { $_.stable })[0].version

$serverUrl = "https://meta.fabricmc.net/v2/versions/loader/$MinecraftVersion/$loaderVersion/$installerVersion/server/jar"
Invoke-WebRequest $serverUrl -OutFile (Join-Path $ServerDir "server.jar")

$fabricVersions = Invoke-RestMethod "https://api.modrinth.com/v2/project/P7dR8mSH/version"
$packTestVersions = Invoke-RestMethod "https://api.modrinth.com/v2/project/XsKUhp45/version"
$fabricVersion = $fabricVersions | Where-Object { $_.game_versions -contains $MinecraftVersion -and $_.loaders -contains "fabric" } | Select-Object -First 1
$packTestVersion = $packTestVersions | Where-Object { $_.game_versions -contains $MinecraftVersion -and $_.loaders -contains "fabric" } | Select-Object -First 1

Invoke-WebRequest $fabricVersion.files[0].url -OutFile (Join-Path $ModsDir "fabric-api.jar")
Invoke-WebRequest $packTestVersion.files[0].url -OutFile (Join-Path $ModsDir "packtest.jar")

Remove-Item (Join-Path $DatapacksDir "HeartStakes"), (Join-Path $DatapacksDir "heartstakes-tests") -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $RootDir "HeartStakes") (Join-Path $DatapacksDir "HeartStakes") -Recurse
Copy-Item (Join-Path $RootDir "tests\heartstakes-testpack") (Join-Path $DatapacksDir "heartstakes-tests") -Recurse

$javaArgs = @("-Xmx2G", "-Dpacktest.auto=true", "-Dpacktest.auto.annotations=true", "-jar", "server.jar", "nogui")
$process = Start-Process java -ArgumentList $javaArgs -WorkingDirectory $ServerDir -PassThru -NoNewWindow
if (-not $process.WaitForExit(90000)) {
    Stop-Process -Id $process.Id -Force
    Write-Error "PackTest did not finish within 90 seconds."
    exit 124
}
exit $process.ExitCode
