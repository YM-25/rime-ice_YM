$ErrorActionPreference = 'Stop'
$dictPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de.dict.yaml"

$lines = [System.IO.File]::ReadAllLines($dictPath, [System.Text.Encoding]::UTF8)

# A robust list of common international/English names found in subtitle frequency lists
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

# Convert to hashset for faster case-insensitive lookup
$excludeSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
foreach ($name in $namesToRemove) {
    [void]$excludeSet.Add($name)
}

# DO NOT exclude typical German places we might want, but the user DID say "aaron adam adams... 这种绝大多数情况我会直接英文"
# wait, user said "地名或者这些稍微特殊或者不常见的 尤其德国奥地利瑞士及周边地区的名字... 保留"
# So keeping München, Österreich, Berlin (maybe keep Berlin? It's German. I removed Berlin in array above... Let me remove Berlin from the exclusion list just in case. Same for Venedig, Rom, Spanien etc., these are German spellings of places. I should NOT exclude them.

$germanSpellings = @("Venedig", "Rom", "Tokio", "Kuba", "Indien", "Afrika", "Griechenland", "Schottland", "Spanien", "Italien", "Frankreich", "Amerika", "Berlin")
foreach ($g in $germanSpellings) {
    if ($excludeSet.Contains($g)) {
        [void]$excludeSet.Remove($g)
    }
}


$newLines = @()
$removedCount = 0

foreach ($line in $lines) {
    if ($line.Trim() -eq "" -or $line.StartsWith("name:") -or $line.StartsWith("version:") -or $line.StartsWith("sort:") -or $line.StartsWith("---") -or $line.StartsWith("...")) {
        $newLines += $line
        continue
    }

    $parts = $line -split "`t"
    if ($parts.Length -ge 2) {
        $word = $parts[0]
        if ($excludeSet.Contains($word)) {
            $removedCount++
            continue
        }
    }
    $newLines += $line
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($dictPath, $newLines, $utf8NoBom)
Write-Host "Filtered out $removedCount non-German names/places."
