$ErrorActionPreference = 'Stop'
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$webClient = New-Object System.Net.WebClient
$bytes = $webClient.DownloadData("https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/de/de_50k.txt")
$text = [System.Text.Encoding]::UTF8.GetString($bytes)

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("c:\Users\90589\AppData\Roaming\Rime\de_50k_raw.txt", $text, $utf8NoBom)
Write-Host "Downloaded de_50k words perfectly via WebClient."
