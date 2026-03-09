$ErrorActionPreference = 'Stop'
$dictPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de.dict.yaml"

# Read all lines
$lines = [System.IO.File]::ReadAllLines($dictPath, [System.Text.Encoding]::UTF8)

# Separate header from body
$header = @()
$body = @()
$inHeader = $true

foreach ($line in $lines) {
    if ($inHeader) {
        $header += $line
        if ($line -eq "...") {
            
            # Change sort type in header since we are changing it to alphabetical 
            $header = $header | ForEach-Object {
                if ($_ -match "^sort:") { "sort: original" } else { $_ }
            }
            $inHeader = $false
        }
    } else {
        if ($line.Trim() -ne "") {
            $body += $line
        }
    }
}

# Sort body ignoring case
$bodySorted = $body | Sort-Object

# Combine
$finalContent = $header + "" + $bodySorted

# Write back
$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($dictPath, $finalContent, $utf8NoBom)
Write-Host "Dictionary sorted successfully."
