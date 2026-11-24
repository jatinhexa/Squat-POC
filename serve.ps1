# Serves the Squat Analyzer POC on http://localhost:8765
# Camera access requires https:// or localhost, so the page must be served, not opened as a file.
param([int]$Port = 8765)

Set-Location -Path $PSScriptRoot
Write-Host "Squat Analyzer POC running at http://localhost:$Port  (Ctrl+C to stop)"
python -m http.server $Port --bind 127.0.0.1
