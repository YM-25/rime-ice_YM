$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$extDictPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de_ext.dict.yaml"

$englishWords = @("never", "baby", "babys", "honey", "okay", "yeah", "fuck", "shit", "please", "sorry", "sir", "hi", "bye", "hello", "wow", "oh", "ah", "uh", "cool", "hey", "yes", "no", "man", "guy", "guys", "boy", "girl", "bitch", "crap", "damn", "god", "jesus", "christ", "lord", "lady", "boss", "chief", "king", "queen", "prince", "princess", "brother", "sister", "mom", "dad", "mother", "father", "son", "daughter", "wife", "husband", "friend", "enemy", "love", "hate", "life", "death", "time", "day", "night", "week", "month", "year", "today", "tomorrow", "yesterday", "now", "then", "here", "there", "where", "why", "who", "what", "which", "how", "all", "some", "any", "many", "much", "few", "little", "big", "small", "good", "bad", "right", "wrong", "true", "false", "new", "old", "young", "hot", "cold", "warm", "high", "low", "fast", "slow", "hard", "soft", "easy", "difficult", "simple", "complex", "stop", "go", "come", "leave", "stay", "wait", "walk", "run", "jump", "fly", "swim", "drive", "ride", "play", "work", "sleep", "wake", "eat", "drink", "talk", "listen", "watch", "see", "look", "hear", "feel", "touch", "smell", "taste", "want", "need", "like", "dislike", "hope", "fear", "think", "know", "believe", "understand", "remember", "forget", "learn", "teach", "read", "write", "speak", "say", "tell", "ask", "answer", "call", "help", "save", "kill", "die", "live", "win", "lose", "break", "fix", "build", "destroy", "create", "make", "do", "be", "have", "get", "give", "take", "put", "keep", "find", "show", "hide", "use", "try", "fail", "succeed", "start", "finish", "begin", "end", "open", "close", "turn", "change", "move", "hold", "let", "pull", "push", "drop", "catch", "throw", "hit", "kick", "punch", "bite", "kiss", "hug", "smile", "laugh", "cry", "weep", "shout", "scream", "yell", "whisper", "sing", "dance", "paint", "draw", "game", "toy", "book", "pen", "pencil", "paper", "computer", "phone", "tv", "radio", "music", "song", "movie", "film", "picture", "photo", "camera", "car", "bus", "train", "plane", "boat", "ship", "bike", "bicycle", "motorcycle", "truck", "van", "road", "street", "highway", "path", "bridge", "house", "home", "building", "room", "door", "window", "wall", "floor", "ceiling", "roof", "bed", "chair", "table", "desk", "sofa", "couch", "lamp", "light", "fire", "water", "air", "earth", "sun", "moon", "star", "sky", "cloud", "rain", "snow", "wind", "storm", "ice", "flower", "tree", "plant", "grass", "leaf", "bird", "fish", "dog", "cat", "horse", "cow", "pig", "sheep", "chicken", "duck", "mouse", "rat", "bear", "lion", "tiger", "elephant", "monkey", "ape", "snake", "spider", "insect", "bug", "ant", "bee", "butterfly", "food", "milk", "coffee", "tea", "juice", "beer", "wine", "alcohol", "bread", "cheese", "meat", "beef", "pork", "fruit", "apple", "banana", "orange", "grape", "strawberry", "lemon", "vegetable", "carrot", "potato", "tomato", "onion", "garlic", "salt", "pepper", "sugar", "sweet", "sour", "bitter", "spicy", "breakfast", "lunch", "dinner", "supper", "meal", "snack", "restaurant", "cafe", "bar", "pub", "club", "store", "shop", "market", "supermarket", "mall", "hospital", "clinic", "pharmacy", "doctor", "nurse", "patient", "medicine", "pill", "school", "college", "university", "student", "teacher", "professor", "class", "course", "lesson", "homework", "exam", "test", "grade", "degree", "job", "career", "business", "company", "office", "factory", "manager", "employee", "worker", "colleague", "salary", "wage", "pay", "money", "cash", "coin", "bank", "account", "credit", "card", "check", "price", "cost", "value", "tax", "fee", "bill", "invoice", "receipt", "city", "town", "village", "country", "state", "province", "region", "world", "planet", "universe", "space", "galaxy", "black", "white", "red", "blue", "green", "yellow", "brown", "pink", "purple", "gray", "grey", "silver", "gold")
$englishSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
foreach ($ew in $englishWords) { [void]$englishSet.Add($ew) }

$shortWhitelist = @("ich", "du", "er", "sie", "es", "der", "die", "das", "und", "ist", "hat", "auf", "aus", "bei", "mit", "von", "zu", "an", "in", "im", "am", "um", "ab", "ob", "da", "wo", "so", "ja", "nie", "nun", "nur", "oft", "gut", "tun", "mal", "tag", "zug", "tür", "uhr", "ohr", "eis", "hut", "wem", "wen", "wer", "was", "wie", "wir", "ihr", "mir", "dir", "ihm", "ihn", "uns", "euch", "den", "dem", "des", "ein", "hin", "her", "gar", "weh", "tod", "mut", "not", "weg", "ruf", "ort", "art", "rat", "tat", "tal", "rad", "bad", "gas", "los", "see", "fee", "tee", "kuh", "sau", "tor", "hof", "ohr", "ast", "amt", "arm", "bar", "gut", "bös", "neu", "alt", "pol", "wal", "hai", "bär")
$shortSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
foreach ($sw in $shortWhitelist) { [void]$shortSet.Add($sw) }

Write-Host "Downloading German reference wordlist to check capitalization..."
$refText = ""
try {
    $webClient = New-Object System.Net.WebClient
    $bytes = $webClient.DownloadData("https://raw.githubusercontent.com/davidak/wortliste/master/wortliste.txt")
    $refText = [System.Text.Encoding]::UTF8.GetString($bytes)
} catch {
    Write-Host "Download failed."
}

$casingMap = @{}
if ($refText) {
    foreach ($w in ($refText -split "`n")) {
        $w = $w.Trim()
        if ($w) { $casingMap[$w] = $w }
    }
}

$nounSuffixes = @("heit", "keit", "ung", "schaft", "tum", "nis", "sal", "ling", "lein", "chen", "tion", "ismus", "ität", "tur", "enz", "ie", "ik")

$lines = [System.IO.File]::ReadAllLines($extDictPath, [System.Text.Encoding]::UTF8)

$removedEnglish = 0
$removedShort = 0
$capitalizedCount = 0

$header = @()
$entries = @()

foreach ($line in $lines) {
    if ($line.Trim() -eq "" -or $line.StartsWith("---") -or $line.StartsWith("...") -or $line.StartsWith("name:") -or $line.StartsWith("version:") -or $line.StartsWith("sort:")) {
        $header += $line
        continue
    }

    $parts = $line -split "`t"
    if ($parts.Length -ne 3) { continue }

    $word = $parts[0]
    $code = $parts[1]
    $weight = [int]$parts[2]
    
    if ($englishSet.Contains($word)) {
        $removedEnglish++
        continue
    }

    if ($word.Length -le 3 -and -not $shortSet.Contains($word) -and $word -notmatch "^\d") {
        # Keep numbers like "3D", but drop tiny meaningless letter strings
        $removedShort++
        continue
    }

    $finalWord = $word
    if ($casingMap.ContainsKey($word)) {
        $mapped = $casingMap[$word]
        # Only capitalize if the mapped word starts with uppercase
        if ([char]::IsUpper($mapped[0]) -and -not [char]::IsUpper($word[0])) {
            $finalWord = $mapped.Substring(0,1).ToUpper() + $mapped.Substring(1)
            $capitalizedCount++
        }
    } else {
        $isNoun = $false
        foreach ($suf in $nounSuffixes) {
            if ($word.EndsWith($suf)) {
                $isNoun = $true
                break
            }
        }
        if ($isNoun -and $word.Length -gt 0) {
           $finalWord = $word.Substring(0,1).ToUpper() + $word.Substring(1)
           $capitalizedCount++
        }
    }

    $entries += [PSCustomObject]@{ Word = $finalWord; Code = $code; Weight = $weight }
}

Write-Host "Sorting entries..."
# Deduplicate on output side
$uniqueEntries = $entries | Group-Object -Property Word, Code | ForEach-Object {
    $maxW = ($_.Group | Measure-Object -Property Weight -Maximum).Maximum
    [PSCustomObject]@{
        Word = $_.Name.Split(',')[0].Trim()
        Code = $_.Name.Split(',')[1].Trim()
        Weight = $maxW
    }
}
$sortedEntries = $uniqueEntries | Sort-Object @{Expression={$_.Word}; Descending=$false}, @{Expression={$_.Code}; Descending=$false}

$finalLines = New-Object System.Collections.Generic.List[string]
foreach ($h in $header) { $finalLines.Add($h) }
foreach ($e in $sortedEntries) { $finalLines.Add("$($e.Word)`t$($e.Code)`t$($e.Weight)") }

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($extDictPath, $finalLines, $utf8NoBom)

Write-Host "Cleanup completed successfully!"
Write-Host "Removed English words: $removedEnglish"
Write-Host "Removed short words: $removedShort"
Write-Host "Capitalized nouns: $capitalizedCount"
Write-Host "Total entries remaining: $($sortedEntries.Count)"
