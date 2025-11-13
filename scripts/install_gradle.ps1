# Attempt to install Gradle via common Windows package managers (requires admin for choco)
Write-Host "Checking for existing gradle..."
$g = Get-Command gradle -ErrorAction SilentlyContinue
if ($g) { Write-Host "Gradle already installed at: $($g.Source)"; exit 0 }

# Try scoop
$scoop = Get-Command scoop -ErrorAction SilentlyContinue
if ($scoop) {
    Write-Host "Attempting to install gradle via scoop..."
    try {
        scoop install gradle
        if ($LASTEXITCODE -eq 0) { Write-Host "Gradle installed via scoop."; exit 0 }
    } catch {
        Write-Host "scoop install failed or not elevated; falling back to local download."
    }
}

# Try chocolatey
$choco = Get-Command choco -ErrorAction SilentlyContinue
if ($choco) {
    Write-Host "Attempting to install gradle via chocolatey (requires admin)..."
    try {
        choco install gradle -y
        if ($LASTEXITCODE -eq 0) { Write-Host "Gradle installed via chocolatey."; exit 0 }
    } catch {
        Write-Host "chocolatey install failed or not elevated; falling back to local download."
    }
}

Write-Host "Package manager installs failed or not available. Falling back to local Gradle download."

# If we get here, attempt to download a Gradle binary distribution and extract locally
$version = '7.6'
$destRoot = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) -ChildPath "..\third_party\gradle"
$dest = Join-Path -Path $destRoot -ChildPath "gradle-$version"
if (Test-Path $dest) { Write-Host "Local Gradle already present at $dest"; exit 0 }

New-Item -ItemType Directory -Path $destRoot -Force | Out-Null
$zipName = "gradle-$version-bin.zip"
$url = "https://services.gradle.org/distributions/$zipName"
$zipPath = Join-Path -Path $env:TEMP -ChildPath $zipName
Write-Host "Downloading Gradle $version from $url ..."
try {
    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Error ("Failed to download Gradle from " + $url + ": " + $_.ToString())
    exit 1
}
Write-Host "Extracting to $destRoot ..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $destRoot)
    Write-Host "Gradle extracted to $dest"
    Write-Host "You can run gradle with: $($dest)\bin\gradle.bat"
    exit 0
} catch {
    Write-Error ("Failed to extract Gradle: " + $_.ToString())
    exit 1
}