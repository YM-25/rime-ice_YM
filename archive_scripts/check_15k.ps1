$lines = Get-Content "de_50k_raw.txt" -Encoding UTF8
$top15k = $lines | Select-Object -First 15000

Write-Host "Total extracted: $($top15k.Count)"
Write-Host "Last 10 words of the Top 15k list:"
$top15k[-10..-1] | Out-String
