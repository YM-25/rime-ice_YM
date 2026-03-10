$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$extDictPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de_ext.dict.yaml"
$enDictPath = "c:\Users\90589\AppData\Roaming\Rime\en_dicts\en.dict.yaml"

$enCapSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::Ordinal)

$lines = [System.IO.File]::ReadAllLines($enDictPath, [System.Text.Encoding]::UTF8)
foreach ($line in $lines) {
    if ($line.Trim() -eq "" -or $line.StartsWith("#") -or $line.StartsWith("---") -or $line.StartsWith("...") -or $line -match "^[a-z_]+:") { continue }
    $parts = $line -split "`t"
    if ($parts.Length -ne 2) { continue }
    $word = $parts[0]
    if ($word -cmatch "^[A-Z][A-Za-z]*$") {
        [void]$enCapSet.Add($word)
    }
}

$extLines = [System.IO.File]::ReadAllLines($extDictPath, [System.Text.Encoding]::UTF8)
$overlap = New-Object System.Collections.Generic.List[string]

foreach ($line in $extLines) {
    $parts = $line -split "`t"
    if ($parts.Length -lt 2) { continue }
    $word = $parts[0]
    
    if ($enCapSet.Contains($word)) {
        $overlap.Add($word)
    }
}

[System.IO.File]::WriteAllLines("c:\Users\90589\AppData\Roaming\Rime\trash\overlap_names.txt", $overlap, [System.Text.Encoding]::UTF8)
Write-Host "Found $($overlap.Count) overlapping capitalized words. Saved to overlap_names.txt"
