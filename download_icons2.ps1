$baseDir = "E:\ArrietyV2\Arriety\CRBO_ARRIETY\Arriety\arriety_beo\arriety\data\girlkun\icon"
$baseUrl = "https://electroheavenvn.github.io/DataNRO/TeaMobi/Icons/"

# Download to x2 folder (1501-5000)
for ($i = 1501; $i -le 5000; $i++) {
    $url = $baseUrl + $i + ".png"
    $out = Join-Path $baseDir "x2" ($i.ToString() + ".png")
    if (-not (Test-Path $out)) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $out -ErrorAction Stop
            Write-Host "Downloaded: $i"
        } catch {
            # Icon not found, skip
        }
    }
}
Write-Host "Done downloading!"

# Copy all from x2 to x3 and x4
Write-Host "Copying to x3 and x4..."
Get-ChildItem (Join-Path $baseDir "x2") -Filter "*.png" | ForEach-Object {
    Copy-Item $_.FullName -Destination (Join-Path $baseDir "x3" $_.Name) -Force
    Copy-Item $_.FullName -Destination (Join-Path $baseDir "x4" $_.Name) -Force
}
Write-Host "All done!"
