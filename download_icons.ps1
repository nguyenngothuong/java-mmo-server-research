$outDir = "E:\ArrietyV2\Arriety\CRBO_ARRIETY\Arriety\arriety_beo\arriety\data\girlkun\icon\x2"
$baseUrl = "https://electroheavenvn.github.io/DataNRO/TeaMobi/Icons/"

for ($i = 1; $i -le 1500; $i++) {
    $url = $baseUrl + $i + ".png"
    $out = Join-Path $outDir ($i.ToString() + ".png")
    try {
        Invoke-WebRequest -Uri $url -OutFile $out -ErrorAction Stop
        Write-Host "Downloaded: $i"
    } catch {
        # Icon not found, skip
    }
}
Write-Host "Done!"
