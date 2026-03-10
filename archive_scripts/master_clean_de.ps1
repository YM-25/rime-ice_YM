$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$extDictPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de_ext.dict.yaml"

# 1. Names and English words to REMOVE
# Based on overlap_names.txt and manual scan
$toRemove = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)

# Add the 494 overlaps found previously (excluding whitelisted ones below)
$overlaps = Get-Content "c:\Users\90589\AppData\Roaming\Rime\trash\overlap_names.txt"
foreach ($o in $overlaps) {
    if ($o.Trim()) { [void]$toRemove.Add($o.Trim()) }
}

# Add obvious English noise from previous lists
$englishNoise = @(
    "after", "again", "agent", "agency", "agencies", "agenten", "agents", "never", "ever", "always", 
    "almost", "alright", "anyone", "anything", "anyway", "awesome", "baby", "babys", "bullshit", "bye", 
    "cops", "detective", "detectives", "did", "doc", "dude", "everybody", "everyone", "everything", 
    "fact", "fake", "friends", "fuck", "fucking", "guy", "guys", "hello", "honey", "idea", "jesus", 
    "joke", "kids", "killer", "look", "maybe", "mission", "mom", "mommy", "money", "movie", "nobody", 
    "nothing", "okay", "party", "people", "please", "problem", "problems", "ready", "really", "relax", 
    "right", "safe", "shit", "sir", "someone", "something", "sometimes", "somewhere", "sorry", "story", 
    "sure", "system", "team", "teams", "today", "tomorrow", "town", "wait", "yeah", "yes",
    "About", "Academy", "Action", "Avatar", "Avenue", "Away"
)
foreach ($e in $englishNoise) { [void]$toRemove.Add($e) }

# 2. Regional/German items to PRESERVE (Whitelist)
$toPreserve = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
$regionalWhitelist = @(
    "Beethoven", "Bosch", "Fischer", "Frankfurt", "Friedrich", "GmbH", "Gustav", 
    "Heinz", "Johann", "Johan", "Markus", "Marx", "Mozart", "Napoleon", "Nazi", 
    "Steiner", "Stephan", "Wagner", "Werner", "Wilhelm", "Wolfgang", "Schmidt",
    "Schneider", "Müller", "Maier", "Huber", "Weber", "Becker", "Schulz", "Hoffmann",
    "Schäfer", "Koch", "Bauer", "Richter", "Klein", "Wolf", "Schröder", "Neumann",
    "Schwarz", "Zimmermann", "Braun", "Krüger", "Hofmann", "Hartmann", "Lange",
    "Schmitt", "Werner", "Schmitz", "Krause", "Meier"
)
foreach ($p in $regionalWhitelist) {
    [void]$toPreserve.Add($p)
    # Ensure they are NOT in the removal list
    if ($toRemove.Contains($p)) { [void]$toRemove.Remove($p) }
}

# 3. Read and filter
$lines = [System.IO.File]::ReadAllLines($extDictPath, [System.Text.Encoding]::UTF8)
$finalLines = New-Object System.Collections.Generic.List[string]
$removedLog = New-Object System.Collections.Generic.List[string]

$header = $true
foreach ($line in $lines) {
    if ($header) {
        $finalLines.Add($line)
        if ($line.StartsWith("...")) { $header = $false }
        continue
    }

    $parts = $line.Split("`t")
    if ($parts.Count -lt 2) {
        $finalLines.Add($line)
        continue
    }

    $word = $parts[0]
    
    # Heuristic: PROTECT words with Umlauts/ß
    if ($word -match "[äöüÄÖÜß]") {
        $finalLines.Add($line)
        continue
    }

    # Heuristic: Remove words ending in -y (often English names/diminutives)
    # UNLESS it's a very short word or whitelisted (though most -y words in German are loanwords)
    # We'll be conservative and only remove if it's also in the removal set or matches a pattern.
    
    if ($toRemove.Contains($word)) {
        $removedLog.Add($word)
        continue
    }

    $finalLines.Add($line)
}

# 4. Save
$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($extDictPath, $finalLines, $utf8NoBom)
[System.IO.File]::WriteAllLines("c:\Users\90589\AppData\Roaming\Rime\trash\removed_in_master_clean.txt", $removedLog, $utf8NoBom)

Write-Host "Master Clean completed."
Write-Host "Removed $($removedLog.Count) words."
Write-Host "Whitelisted $($toPreserve.Count) regional items."
