$baseDir = "E:\ArrietyV2\Arriety\CRBO_ARRIETY\Arriety\arriety_beo\arriety\data\girlkun\icon"

Get-ChildItem (Join-Path $baseDir "x2") -Filter "*.png" | ForEach-Object {
    $name = $_.Name
    Copy-Item $_.FullName -Destination (Join-Path $baseDir "x3" $name) -Force
    Copy-Item $_.FullName -Destination (Join-Path $baseDir "x4" $name) -Force
}
Write-Host "Copied all icons to x3 and x4!"
