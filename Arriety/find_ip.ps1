$dllPath = "E:/ArrietyV2/Arriety/Dragonboy_vn_v230/Dragonboy_vn_v230_Data/Managed/Assembly-CSharp.dll"
$bytes = [System.IO.File]::ReadAllBytes($dllPath)
$text = [System.Text.Encoding]::ASCII.GetString($bytes)
$idx = $text.IndexOf("14.225.212.183")
Write-Host "IP found at offset: $idx"

if ($idx -gt 0) {
    # Replace IP
    $oldIP = [System.Text.Encoding]::ASCII.GetBytes("14.225.212.183")
    $newIP = [System.Text.Encoding]::ASCII.GetBytes("127.0.0.1" + [char]0 + [char]0 + [char]0 + [char]0 + [char]0)

    for ($i = 0; $i -lt $oldIP.Length; $i++) {
        $bytes[$idx + $i] = $newIP[$i]
    }

    [System.IO.File]::WriteAllBytes($dllPath, $bytes)
    Write-Host "IP replaced successfully!"
}
