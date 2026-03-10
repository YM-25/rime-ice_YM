$ErrorActionPreference = 'Stop'

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$rawListPath = "c:\Users\90589\AppData\Roaming\Rime\de_50k_raw.txt"
$baseDictPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de.dict.yaml"
$outDictPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de_ext.dict.yaml"

# 1. Read Base Dictionary to get existing words
Write-Host "Reading base dictionary..."
$baseDictLines = [System.IO.File]::ReadAllLines($baseDictPath, [System.Text.Encoding]::UTF8)
$existingWords = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
foreach ($line in $baseDictLines) {
    if ($line.Trim() -eq "" -or $line.StartsWith("---") -or $line.StartsWith("...") -or $line.Contains(":")) {
        continue
    }
    $parts = $line -split "`t"
    if ($parts.Length -ge 1) {
        [void]$existingWords.Add($parts[0].Trim())
    }
}
Write-Host "Found $($existingWords.Count) existing words."

# 2. Setup names exclusion
$namesToRemove = @(
    "Aaron", "Adam", "Adams", "Adrian", "Amber", "Andrea", "Alex", "Alexander", "Alfred", "Ali", "Ann", "Anna", "Anne", "Anton",
    "Arthur", "Austin", "Barbara", "Barry", "Ben", "Benny", "Berlin", "Bernard", "Bill", "Billy", "Bob", "Bobby", "Brad", "Brian",
    "Bruce", "Carl", "Carlos", "Carol", "Carter", "Charles", "Charlie", "Chloe", "Chris", "Christian", "Christina", "Christine",
    "Christopher", "Chuck", "Claire", "Clark", "Claudia", "Colin", "Craig", "Dan", "Daniel", "Danny", "David", "Dave", "David",
    "Davis", "Dean", "Dennis", "Derek", "Diana", "Dick", "Diego", "Donald", "Donna", "Doris", "Doug", "Douglas", "Earl", "Ed",
    "Eddie", "Edward", "Elena", "Elizabeth", "Ella", "Ellen", "Emily", "Emma", "Eric", "Erik", "Ethan", "Eva", "Evan", "Felix",
    "Frank", "Frankie", "Fred", "Freddy", "Gabriel", "Gary", "George", "Georgie", "Gordon", "Grace", "Greg", "Gregory", "Hannah",
    "Harry", "Harvey", "Helen", "Helena", "Henry", "Howard", "Hugh", "Ian", "Isaac", "Isabella", "Isabelle", "Jack", "Jackie",
    "Jackson", "Jacob", "Jake", "James", "Jamie", "Jane", "Janet", "Jason", "Jay", "Jean", "Jeff", "Jeffrey", "Jenny", "Jeremy",
    "Jerry", "Jesse", "Jessica", "Jim", "Jimmy", "Joan", "Joe", "Joel", "Joey", "John", "Johnny", "Johnson", "Jones", "Jordan",
    "Joseph", "Josh", "Joshua", "Joyce", "Julia", "Julian", "Julie", "Juliet", "Juliette", "Julius", "Justin", "Karen", "Karl",
    "Kate", "Katherine", "Kathleen", "Katie", "Kelly", "Ken", "Kennedy", "Kenneth", "Kevin", "Kim", "King", "Larry", "Laura",
    "Lauren", "Lawrence", "Lee", "Leo", "Leon", "Leonard", "Lewis", "Liam", "Lily", "Lincoln", "Linda", "Lisa", "Logan", "Louis",
    "Lucas", "Lucia", "Lucy", "Luke", "Mac", "Madison", "Maggie", "Malcolm", "Marcus", "Margaret", "Maria", "Marianne", "Marie",
    "Marilyn", "Mark", "Mars", "Marshall", "Martin", "Marty", "Mary", "Mason", "Matthew", "Max", "Maxime", "Maxwell", "May",
    "Megan", "Melissa", "Mia", "Michael", "Mickey", "Mike", "Miller", "Mitchell", "Morgan", "Morris", "Murphy", "Nancy", "Nathan",
    "Neil", "Nelson", "Nicholas", "Nick", "Nico", "Nicolas", "Nina", "Noah", "Norman", "Oliver", "Olivia", "Oscar", "Oskar",
    "Owen", "Pam", "Parker", "Patrick", "Paul", "Paula", "Pauline", "Peter", "Philip", "Phillip", "Rachel", "Ralph", "Ray",
    "Raymond", "Rebecca", "Reed", "Renee", "Rex", "Richard", "Rick", "Ricky", "Riley", "Rita", "Robert", "Roberts", "Robin",
    "Robinson", "Roger", "Roland", "Roman", "Romeo", "Ron", "Ronald", "Rose", "Ross", "Roy", "Ruben", "Russell", "Ruth", "Ryan",
    "Sam", "Samantha", "Sammy", "Samuel", "Sandra", "Sarah", "Scott", "Sean", "Sebastian", "Seth", "Shane", "Sharon", "Shawn",
    "Shirley", "Simon", "Smith", "Sofia", "Sophia", "Sophie", "Spencer", "Stanley", "Stella", "Stephen", "Steve", "Steven",
    "Stewart", "Stuart", "Susan", "Sykes", "Sylvia", "Taylor", "Ted", "Teddy", "Teresa", "Terry", "Theo", "Thomas", "Tim",
    "Timmy", "Tina", "Toby", "Tom", "Tommy", "Tony", "Tracy", "Turner", "Tyler", "Valerie", "Vanessa", "Victor", "Victoria",
    "Vincent", "Virginia", "Wallace", "Walter", "Warren", "Wayne", "Wendy", "White", "William", "Williams", "Willie", "Wilson",
    "Woods", "Wright", "York", "Zoe", "Holmes", "Washington", "New", "York", "London", "Paris", "Sydney", "Houston", "Chicago", 
    "Boston", "Miami", "Vegas", "Venedig", "Rom", "Tokio", "Dallas", "Detroit", "Philadelphia", "Baltimore", "Kansas", "Arizona",
    "Hawaii", "Kuba", "Indien", "Afrika", "Griechenland", "Schottland", "Spanien", "Italien", "Frankreich", "England", "Amerika"
)
$excludeSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
foreach ($name in $namesToRemove) { [void]$excludeSet.Add($name) }

$germanSpellings = @("Venedig", "Rom", "Tokio", "Kuba", "Indien", "Afrika", "Griechenland", "Schottland", "Spanien", "Italien", "Frankreich", "Amerika", "Berlin")
foreach ($g in $germanSpellings) {
    if ($excludeSet.Contains($g)) { [void]$excludeSet.Remove($g) }
}

# 3. Read 50k and take Top 20k
Write-Host "Parsing top 20k from source..."
$rawLines = [System.IO.File]::ReadAllLines($rawListPath, [System.Text.Encoding]::UTF8)

# character constants
$chrAe = [string][char]0x00E4
$chrOe = [string][char]0x00F6
$chrUe = [string][char]0x00FC
$chrSs = [string][char]0x00DF

$entries = @()
$countTop = 0

foreach ($line in $rawLines) {
    if ($countTop -ge 20000) { break }
    if ($line.Trim() -eq "") { continue }

    $parts = $line.Trim() -split " "
    if ($parts.Length -ne 2) { continue }
    
    $word = $parts[0].Trim()
    $freqStr = $parts[1].Trim()

    # Need to properly parse numbers like 5890279
    $freq = 0
    if (-not [int]::TryParse($freqStr, [ref]$freq)) { continue }

    # Capitalize the first letter if the word is long enough to look better heuristically. We won't try to guess nouns perfectly, but often subtitles have all lowercase.
    # Actually wait! The 50k script has EVERYTHING lowercase!
    # Let's inspect $word. Is it fully lowercase?
    # Rime will match lower/upper typing if we provide lowercase codes. It might be better to capitalize it properly.
    # WAIT! There is no capitalization info. We'll leave it lowercase. Oh wait, if it's lowercase, all nouns will appear lowercase in Rime...
    # The existing de_dict has correct casing. We'll leave the extra words lowercase unless we can do dict lookup. Let's capitalize standard words based on existing dictionary? No, existing dict already has top 5000 nouns correctly capitalized. The other 15k will naturally be less common, some adverbs/verbs.
    # It's better to keep it untouched to avoid butchering.

    $countTop++
    
    if ($excludeSet.Contains($word)) { continue }
    if ($existingWords.Contains($word)) { continue }

    # Calculate weight: Log10(freq) * 10
    $weight = [math]::Round([math]::Log10($freq) * 10)

    $wLower = $word.ToLower()
    $codeA = $wLower.Replace($chrAe,"ae").Replace($chrOe,"oe").Replace($chrUe,"ue").Replace($chrSs,"ss")
    $codeA = $codeA -replace "[^a-z]", ""
    
    $codeB = $wLower.Replace($chrAe,"a").Replace($chrOe,"o").Replace($chrUe,"u").Replace($chrSs,"s")
    $codeB = $codeB -replace "[^a-z]", ""

    if ($codeA) {
        $entries += [PSCustomObject]@{ Word = $word; Code = $codeA; Weight = $weight }
    }
    if ($codeB -and $codeB -ne $codeA) {
        $entries += [PSCustomObject]@{ Word = $word; Code = $codeB; Weight = $weight }
    }
}

# 4. Deduplicate (same word + code -> keep max weight)
Write-Host "Deduplicating..."
$uniqueEntries = $entries | Group-Object -Property Word, Code | ForEach-Object {
    $maxWeight = ($_.Group | Measure-Object -Property Weight -Maximum).Maximum
    [PSCustomObject]@{
        Word = $_.Name.Split(',')[0].Trim()
        Code = $_.Name.Split(',')[1].Trim()
        Weight = $maxWeight
    }
}

Write-Host "Sorting alphabetically..."
$sortedEntries = $uniqueEntries | Sort-Object @{Expression={$_.Word}; Descending=$false}, @{Expression={$_.Code}; Descending=$false}

# 5. Build Final Output
$output = New-Object System.Collections.Generic.List[string]
$output.Add("---")
$output.Add("name: de_ext")
$output.Add("version: `"2024.03.09`"")
$output.Add("sort: by_weight")
$output.Add("...")
$output.Add("")

foreach ($e in $sortedEntries) {
    if ($e.Code -ne "") {
        $output.Add("$($e.Word)`t$($e.Code)`t$($e.Weight)")
    }
}

Write-Host "Writing $($output.Count - 6) lines to de_ext.dict.yaml..."
$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($outDictPath, $output, $utf8NoBom)
Write-Host "de_ext successfully created!"
