$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path "de_dicts" -ErrorAction SilentlyContinue

Write-Host "Fetching word list..."
$wordsUrl = "https://raw.githubusercontent.com/badranX/german-frequency/master/data/5000.txt"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$webClient = New-Object System.Net.WebClient
$bytes = $webClient.DownloadData($wordsUrl)
$wordsText = [System.Text.Encoding]::UTF8.GetString($bytes)
$words = $wordsText -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

# Using hex codes for extra words to strictly avoid PowerShell parsing bugs
$chrAe = [string][char]0x00E4
$chrOe = [string][char]0x00F6
$chrUe = [string][char]0x00FC
$chrSs = [string][char]0x00DF

$extraWords = @(
    "Apotheke", "Krankenhaus", "Flughafen", "Feuerwehr", "Polizei", 
    ("B" + $chrUe + "rgersteig"),
    "Zebrastreifen", "Umwelt", "Treibhauseffekt", "Bahnhof", 
    ("M" + $chrAe + "dchen"),
    ("Gem" + $chrUe + "se"), 
    ("Fu" + $chrSs + "ball"), 
    ("Gro" + $chrSs + "vater"), 
    ("Sch" + $chrUe + "ler"), 
    "Arzt", "Zahnarzt", 
    ("Tsch" + $chrUe + "ss"), 
    "Zweifel"
)

$allWords = $words + $extraWords | Select-Object -Unique

Write-Host "Generating entries..."
$output = New-Object System.Collections.Generic.List[string]
$output.Add("---")
$output.Add("name: de")
$output.Add("version: `"2024.03.09`"")
$output.Add("sort: by_weight")
$output.Add("...")
$output.Add("")

foreach ($w in $allWords) {
    if (-not $w) { continue }
    
    $isExtra = ($extraWords -contains $w)
    $weight = if ($isExtra) { 50 } else { 100 }
    
    $wLower = $w.ToLower()
    
    # Base code: ae, oe, ue, ss
    $code1 = $wLower.Replace($chrAe,"ae").Replace($chrOe,"oe").Replace($chrUe,"ue").Replace($chrSs,"ss")
    $code1 = $code1 -replace "[^a-z]", ""
    
    # Loose code: a, o, u, s
    $code2 = $wLower.Replace($chrAe,"a").Replace($chrOe,"o").Replace($chrUe,"u").Replace($chrSs,"s")
    $code2 = $code2 -replace "[^a-z]", ""

    if ($code1) {
        $output.Add("$w`t$code1`t$weight")
    }
    if ($code2 -and $code2 -ne $code1) {
        $output.Add("$w`t$code2`t$weight")
    }
}

Write-Host "Saving to de.dict.yaml..."
$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines((Join-Path (Get-Location) "de_dicts\de.dict.yaml"), $output, $utf8NoBom)
Write-Host "Done! Dictionary perfectly generated."
