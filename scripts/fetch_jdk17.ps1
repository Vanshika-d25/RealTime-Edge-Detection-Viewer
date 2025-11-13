# Download Temurin JDK 17 (Windows x64) into third_party/jdk17
$versionTag = 'jdk-17.0.8+7'
$zipName = 'OpenJDK17U-jdk_x64_windows_hotspot_17.0.8_7.zip'
$url = "https://github.com/adoptium/temurin17-binaries/releases/download/$($versionTag)/$zipName"
$destRoot = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) -ChildPath "..\third_party\jdk17"
if (-not (Test-Path $destRoot)) { New-Item -ItemType Directory -Path $destRoot -Force | Out-Null }
$zipPath = Join-Path $env:TEMP $zipName
Write-Host "Downloading JDK 17 from $url ..."
try {
    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Error "Failed to download JDK 17: $_"
    exit 1
}
Write-Host "Extracting JDK to $destRoot ..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $destRoot)
} catch {
    Write-Error "Failed to extract JDK: $_"
    exit 1
}
# Find extracted JDK dir
$jdirs = Get-ChildItem -Path $destRoot | Where-Object { $_.PSIsContainer }
if ($jdirs.Count -eq 0) { Write-Error "No JDK directory found after extraction"; exit 1 }
$jdkDir = $jdirs[0].FullName
Write-Host "JDK extracted to: $jdkDir"
Write-Host "After extraction, run Gradle with a JDK 17 environment, for example:"
Write-Host "    &{ `\$env:JAVA_HOME='$jdkDir'; .\\run_build.ps1 downloadOpenCV }"