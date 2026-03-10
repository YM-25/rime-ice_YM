$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$extDictPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de_ext.dict.yaml"
$refPath = "c:\Users\90589\AppData\Roaming\Rime\trash\wortliste_ref.txt"

$refSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
$lines = Get-Content $refPath
foreach ($l in $lines) {
    if ($l.Trim()) { [void]$refSet.Add($l.Trim()) }
}

$candidates = New-Object System.Collections.Generic.List[string]
$extLines = Get-Content $extDictPath
foreach ($l in $extLines) {
    if ($l -match "^([A-Z][a-zA-ZäöüÄÖÜß]+)`t") {
        $word = $matches[1]
        if (-not $refSet.Contains($word)) {
            $candidates.Add($word)
        }
    }
}

$candidates | Sort-Object -Unique | Out-File "c:\Users\90589\AppData\Roaming\Rime\trash\cleaning_candidates.txt" -Encoding UTF8
Write-Host "Found $($candidates.Count) candidate words (including duplicates in dict) for removal. Unique: $(($candidates | Select-Object -Unique).Count)"
