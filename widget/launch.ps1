# Kawaii Todo Widget Launcher (Electron)
$widgetDir = $PSScriptRoot

# Check node_modules
if (-not (Test-Path "$widgetDir\node_modules")) {
    Write-Host "Installing dependencies first..."
    Set-Location $widgetDir
    npm install 2>&1
}

Set-Location $widgetDir
npm start 2>&1
