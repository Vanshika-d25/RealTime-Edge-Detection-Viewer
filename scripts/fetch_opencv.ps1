
# Download OpenCV Android SDK (Windows) into third_party/OpenCV-android
# Usage: .\fetch_opencv.ps1 -Version 4.5.5
param(
    [string]$Version = "4.5.5"
)

$candidates = @(
    "opencv-${Version}-android-sdk.zip",
    "opencv-${Version}-android.zip",
    "opencv-${Version}-android-sdk.tar.gz"
)

$destPath = Join-Path -Path $PSScriptRoot -ChildPath "..\third_party\OpenCV-android"
$dest = Resolve-Path -Path $destPath -ErrorAction SilentlyContinue
if (-not $dest) {
    New-Item -ItemType Directory -Path $destPath -Force | Out-Null
    $dest = Resolve-Path -Path $destPath
}

# If jni folder already exists under the expected path, skip download/extract
$vendoredJni = Join-Path -Path $dest.Path -ChildPath "OpenCV-android-sdk/sdk/native/jni"
if (Test-Path $vendoredJni) {
    Write-Host "Vendored OpenCV JNI already present at: $vendoredJni. Skipping download/extract."
    return
}

$downloaded = $null
foreach ($name in $candidates) {
    $url = "https://github.com/opencv/opencv/releases/download/${Version}/${name}"
    $out = Join-Path -Path $PSScriptRoot -ChildPath $name
    Write-Host "Trying $url ..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -ErrorAction Stop
        Write-Host "Downloaded $name"
        $downloaded = $out
        break
    } catch {
        Write-Host "Not found: $name"
    }
}

if (-not $downloaded) {
    Write-Error "Failed to download OpenCV for version $Version. Check available release assets on GitHub and try again."
    exit 1
}

Write-Host "Extracting $downloaded to $dest ..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($downloaded, $dest.Path)
    Write-Host "Extraction complete."
} catch {
    Write-Host "ZipFile.ExtractToDirectory failed; attempting manual extraction via ZipArchive..."
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($downloaded.FullName)
        foreach ($entry in $zip.Entries) {
            $target = Join-Path -Path $dest.Path -ChildPath $entry.FullName
            $dir = Split-Path $target -Parent
            if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            if ($entry.Length -eq 0) { continue }
            $stream = $entry.Open()
            $outFile = [System.IO.File]::Create($target)
            try { $stream.CopyTo($outFile) } finally { $outFile.Close(); $stream.Close() }
        }
        $zip.Dispose()
        Write-Host "Manual extraction complete."
    } catch {
        Write-Host "Manual ZipArchive extraction failed. Trying 7z if available..."
        $seven = "C:\Program Files\7-Zip\7z.exe"
        if (Test-Path $seven) {
            & $seven x $downloaded.FullName "-o$($dest.Path)" -y
            Write-Host "7z extraction finished."
        } else {
            Write-Error "No suitable extractor found. Please extract $($downloaded.FullName) manually to $($dest.Path)"
            exit 1
        }
    }
}

Write-Host "OpenCV files should be under: $($dest.Path)"
