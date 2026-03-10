$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$enDictPath = "c:\Users\90589\AppData\Roaming\Rime\en_dicts\en.dict.yaml"
$enExtPath = "c:\Users\90589\AppData\Roaming\Rime\en_dicts\en_ext.dict.yaml"
$deExtPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de_ext.dict.yaml"

$enWords = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)

function Load-En($path) {
    if (Test-Path $path) {
        $lines = Get-Content $path
        foreach ($l in $lines) {
            if ($l -match "^([A-Za-z'-]+)`t") {
                [void]$enWords.Add($matches[1])
            }
        }
    }
}

Load-En $enDictPath
Load-En $enExtPath

# DACH Protection Whitelist (Manual + Patterns)
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
    "GmbH", "AG", "DDR", "BRD", "VW", "BMW", "Audi", "Mercedes", "Porsche"
)
foreach ($item in $manualDach) { [void]$dachWhitelist.Add($item) }

$toRemove = New-Object System.Collections.Generic.List[string]

$deLines = Get-Content $deExtPath
foreach ($l in $deLines) {
    if ($l -match "^([A-Z][a-z]+)`t") {
        $word = $matches[1]
        
        # If it's in English dict AND not in DACH whitelist
        if ($enWords.Contains($word) -and -not $dachWhitelist.Contains($word)) {
            # Check if it's a common German word in lower case? 
            # We already did capitalization recovery, so if it's Capitalized, it's either a Noun or a Name.
            # If it's in EN dict, it's likely a Name or an English Noun.
            $toRemove.Add($word)
        }
    }
}

$toRemove | Sort-Object -Unique | Out-File "c:\Users\90589\AppData\Roaming\Rime\trash\en_overlap_candidates.txt" -Encoding UTF8
Write-Host "Found $($toRemove.Count) overlapping candidates for removal."
