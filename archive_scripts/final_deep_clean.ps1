$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$deExtPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de_ext.dict.yaml"
$refPath = "c:\Users\90589\AppData\Roaming\Rime\trash\wortliste_ref.txt"
$enDictPath = "c:\Users\90589\AppData\Roaming\Rime\en_dicts\en.dict.yaml"

# 1. Load Reference Lists
$refSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
foreach ($l in (Get-Content $refPath)) {
    if ($l.Trim()) { [void]$refSet.Add($l.Trim()) }
}

$enSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
foreach ($l in (Get-Content $enDictPath)) {
    if ($l -match "^([A-Za-z'-]+)`t") {
        [void]$enSet.Add($matches[1])
    }
}

# 2. DACH Protection (Places, Entities, Brands)
$dachWhitelist = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
$manualDach = @(
    "Aachen", "Berlin", "Bonn", "Bremen", "Darmstadt", "Dortmund", "Dresden", "Düsseldorf", 
    "Erfurt", "Essen", "Frankfurt", "Freiburg", "Gera", "Göttingen", "Halle", "Hamburg", 
    "Hamm", "Hannover", "Heidelberg", "Heilbronn", "Ingolstadt", "Jena", "Karlsruhe", 
    "Kassel", "Kiel", "Koblenz", "Köln", "Leipzig", "Leverkusen", "Lübeck", "Ludwigshafen", 
    "Magdeburg", "Mainz", "Mannheim", "Mönchengladbach", "München", "Münster", "Neuss", 
    "Nürnberg", "Oberhausen", "Offenbach", "Oldenburg", "Osnabrück", "Paderborn", "Pforzheim", 
    "Potsdam", "Recklinghausen", "Regensburg", "Remscheid", "Rostock", "Saarbrücken", 
    "Salzgritter", "Siegen", "Solingen", "Stuttgart", "Ulm", "Wiesbaden", "Wolfsburg", 
    "Wuppertal", "Würzburg", "Zwickau",
    "Wien", "Graz", "Linz", "Salzburg", "Innsbruck", "Klagenfurt", "Villach", "Wels", "St. Pölten", "Dornbirn",
    "Zürich", "Genf", "Basel", "Lausanne", "Bern", "Winterthur", "Luzern", "St. Gallen", "Lugano", "Biel/Bienne",
    "Bayern", "Sachsen", "Hessen", "Tirol", "Steiermark", "Kärnten",
    "GmbH", "AG", "DDR", "BRD", "VW", "BMW", "Audi", "Mercedes", "Porsche", "Bosch", "Siemens"
)
foreach ($item in $manualDach) { [void]$dachWhitelist.Add($item) }

# 3. Explicit Name Blacklist (User examples + common Global names)
$nameBlacklist = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
$forcedRemovals = @(
    "Aaron", "Adam", "Adams", "Adolf", "Adrien", "Aiden", "Alejandro", "Alessandro", "Alfonzo", "Alfredo", 
    "Alistair", "Almanzo", "Alphonse", "Alvarez", "Ambrose", "Anakin", "Annabeth", "Annika", "Anubis", 
    "Antoine", "Apophis", "Archie", "Archibald", "Armand", "Arnie", "Asher", "Ashton", "Asterix", "Athos", "Atticus",
    "Alice", "Annie", "Arthur", "Austin", "Barry", "Benji", "Billy", "Blaine", "Bobby", "Bojack", "Brandon", 
    "Bryce", "Caffrey", "Cahill", "Callen", "Castiel", "Cavanaugh", "Cece", "Chakotay", "Channing", "Colby", 
    "Conner", "Coulson", "Crixus", "Cuddy", "Cutler", "Danny", "Darnell", "Davey", "Declan", "Deeks", "Dexter",
    "Dinozzo", "Dobbs", "Doggett", "Dolan", "Donnelly", "Dougie", "Dunham", "Durant", "Ezra", "Falcone",
    "Fozzie", "Gabbie", "Gaines", "Garak", "Garvey", "Gatsby", "Gemma", "Geordi", "Gisborne", "Grady", 
    "Grimes", "Hailey", "Hardcastle", "Hawthorne", "Healey", "Healy", "Hiro", "Hodgins", "Hollis", "Homie",
    "Howie", "Hutch", "Isaiah", "Izzy", "Jace", "Jadzia", "Janeway", "Jethro", "Jimbo", "Jonah", "Jonesy", 
    "Keating", "Kelso", "Kepner", "Kiera", "Kieran", "Kiki", "Kwan", "Lavon", "Lebeau", "Lestrade", "Lightman",
    "Lisbon", "Lockhart", "Lorelai", "Lucrezia", "Macgyver", "Marple", "Mcgill", "Mcmanus", "Mcqueen", "Merlyn",
    "Micah", "Moriarty", "Munson", "Muppet", "Murph", "Nathaniel", "Neville", "Newark", "Nigel", "Noel", "Nolan"
)
foreach ($n in $forcedRemovals) { [void]$nameBlacklist.Add($n) }

# 4. Processing
$lines = [System.IO.File]::ReadAllLines($deExtPath, [System.Text.Encoding]::UTF8)
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
    
    # RULE 0: PROTECT Umlauts
    if ($word -match "[äöüÄÖÜß]") {
        $finalLines.Add($line)
        continue
    }

    # RULE 1: PROTECT DACH Whitelist
    if ($dachWhitelist.Contains($word)) {
        $finalLines.Add($line)
        continue
    }

    # RULE 2: REMOVE Explicit Blacklist
    if ($nameBlacklist.Contains($word)) {
        $removedLog.Add("[Explicit] $word")
        continue
    }

    # RULE 3: PROTECT recognized German words (nouns/verbs)
    # If it's in the German reference AND NOT in English Dict -> Very likely German.
    # If it's in BOTH, and not a forced removal, we'll keep it for safety (could be Bauer, Koch, etc.)
    if ($refSet.Contains($word)) {
        $finalLines.Add($line)
        continue
    }

    # RULE 4: REMOVE English overlaps that are NOT in German Reference
    # (Catches names and English words like 'About', 'Access', 'Avenue' if missing from ref)
    if ($enSet.Contains($word)) {
        $removedLog.Add("[EN Overlap] $word")
        continue
    }

    # RULE 5: REMOVE Capitalized words that are NOT in German Reference
    # (Catches subtitle names like 'Ahsoka', 'Bajor' etc.)
    if ($word -match "^[A-Z][a-z]+") {
        $removedLog.Add("[Non-Ref Capital] $word")
        continue
    }

    $finalLines.Add($line)
}

# 5. Save
$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($deExtPath, $finalLines, $utf8NoBom)
[System.IO.File]::WriteAllLines("c:\Users\90589\AppData\Roaming\Rime\trash\final_clean_log.txt", $removedLog, $utf8NoBom)

Write-Host "Final Deep Clean completed."
Write-Host "Removed $($removedLog.Count) words."
