$ErrorActionPreference = 'Stop'
$dictPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de.dict.yaml"

$lines = [System.IO.File]::ReadAllLines($dictPath, [System.Text.Encoding]::UTF8)

$header = @()
$bodyLines = @()
$inHeader = $true

foreach ($line in $lines) {
    if ($inHeader) {
        $header += $line
        if ($line -eq "...") { $inHeader = $false }
    } else {
        if ($line.Trim() -ne "") {
            $bodyLines += $line
        }
    }
}

# 1. Parse into objects: Word, Code, Weight
$entries = @()
foreach ($line in $bodyLines) {
    $parts = $line -split "`t"
    if ($parts.Length -eq 3) {
        $entries += [PSCustomObject]@{
            Word = $parts[0]
            Code = $parts[1]
            Weight = [int]$parts[2]
        }
    } elseif ($parts.Length -eq 2) {
        $entries += [PSCustomObject]@{
            Word = $parts[0]
            Code = $parts[1]
            Weight = 100
        }
    }
}

# 2. Deduplicate. 
# Sometimes the same word has multiple codes (e.g. M盲dchen -> maedchen / madchen)
# We want to group by Word AND Code (exact match) and take the highest weight.
$uniqueEntries = $entries | Group-Object -Property Word, Code | ForEach-Object {
    $maxWeight = ($_.Group | Measure-Object -Property Weight -Maximum).Maximum
    [PSCustomObject]@{
        Word = $_.Name.Split(',')[0].Trim()
        Code = $_.Name.Split(',')[1].Trim()
        Weight = $maxWeight
    }
}

# 3. Sort purely alphabetically by Word (Case-Insensitive), then by Code
$sortedEntries = $uniqueEntries | Sort-Object @{Expression={$_.Word}; Descending=$false}, @{Expression={$_.Code}; Descending=$false}

# 4. Format back to string
$formattedBody = $sortedEntries | ForEach-Object {
    "$($_.Word)`t$($_.Code)`t$($_.Weight)"
}

$finalContent = $header + "" + $formattedBody

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($dictPath, $finalContent, $utf8NoBom)
Write-Host "Dictionary deduplicated and sorted successfully."
