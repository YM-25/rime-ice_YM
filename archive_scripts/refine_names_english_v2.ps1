$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$extDictPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de_ext.dict.yaml"

$namesSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)

# Provide targeted names to remove without using external DB.
# This contains the cross-referenced English names from EN dict, excluding German ones.
$targetedEnglishNames = @(
    "Aaron", "Adam", "Adams", "Abdul", "Addison", "Ahmed", "Alabama", "Alain", "Alan", "Alaska", "Alberto", 
    "Albuquerque", "Alec", "Alexandre", "Alexandria", "Allan", "Allen", "Alvin", "America", "American",
    "Anderson", "Andre", "Andrew", "Angeles", "Angelo", "Angus", "Anthony", "Antonio", "Apollo", "Armstrong",
    "Atlantic", "Atlantis", "Avery", "Bahamas", "Baldwin", "Bangkok", "Barcelona", "Barnes", "Barrett", "Barton",
    "Beirut", "Belfast", "Bennett", "Benson", "Berkeley", "Bilder", "Bolton", "Boone", "Bordeaux", "Bowie",
    "Boyd", "Boyle", "Brady", "Brandon", "Branson", "Brendan", "Brennan", "Briggs", "Brighton", "Broadway",
    "Bronx", "Bryan", "Buchanan", "Buckingham", "Buckley", "Burnett", "Burt", "Byron", "Cadillac", "Caesar",
    "Cain", "Caldwell", "California", "Calvin", "Cambridge", "Cameron", "Campbell", "Carlisle", "Carlo",
    "Carlton", "Carson", "Casper", "Cassidy", "Castro", "Chanel", "Chapman", "Charleston", "Chen", "Chester",
    "Cheyenne", "Chico", "Chinatown", "Chinese", "Churchill", "Clayton", "Cleveland", "Clifford", "Clint",
    "Clinton", "Clive", "Clyde", "Cobb", "Coco", "Cohen", "Coleman", "Colorado", "Columbia", "Columbus",
    "Compton", "Connecticut", "Connor", "Conway", "Cruz", "Curtis", "Cyrus", "Dakota", "Dalton", "Damien",
    "Damon", "Dante", "Darren", "Darwin", "Davidson", "Davies", "Denis", "Denver", "Dewey", "Dillon",
    "Disney", "Disneyland", "Dominic", "Dover", "Dracula", "Duane", "Dubai", "Dublin", "Dudley", "Dunn",
    "Dustin", "Dutch", "Dwight", "Dylan", "Edison", "Edmund", "Edwards", "Edwin", "Elijah", "Eliot", "Elliot",
    "Elliott", "Ellis", "Elton", "Emerson", "English", "Ernest", "Essex", "Eugene", "Everett", "Fargo",
    "Farrell", "Ferguson", "Fernando", "Ferrari", "Ferris", "Finn", "Fitzgerald", "Fleming", "Floyd", "Flynn",
    "Foley", "Forrest", "Francesco", "Francis", "Francisco", "Franco", "Francois", "Frankenstein", "Franklin",
    "Fraser", "Frederick", "French", "Gandhi", "Garde", "Gardner", "Garfield", "Garrett", "Gavin", "Geoff",
    "Geoffrey", "Georges", "Gerald", "Gerard", "Gibbs", "Giles", "Gilmore", "Giorgio", "Giovanni", "Gomez",
    "Gonzales", "Google", "Grande", "Greene", "Greenwich", "Griffith", "Hades", "Haiti", "Hammond", "Hampshire",
    "Hampton", "Hanson", "Harlem", "Harold", "Harrington", "Hartley", "Harvard", "Hastings", "Hawkins", "Hawks",
    "Hayden", "Hendrix", "Henri", "Hercules", "Herman", "Hernandez", "Hilton", "Illinois", "Indiana", "Iowa",
    "Iran", "Irving", "Islam", "Istanbul", "Jacques", "Jameson", "Jared", "Jerome", "Jerusalem", "Joaquin",
    "Johns", "Jorge", "Jose", "Juan", "Judd", "Jude", "Jules", "Julio", "Jupiter", "Kenny", "Kentucky",
    "Korea", "Korn", "Krishna", "Kyoto", "Lafayette", "Laurence", "Laurent", "Lenny", "Leonardo", "Leroy",
    "Lester", "Linus", "Lionel", "Liverpool", "Locke", "Lopez", "Lorenzo", "Louisiana", "Lowell", "Luis",
    "Luna", "Luther", "Lyon", "Mackenzie", "Madam", "Madame", "Madrid", "Maine", "Malibu", "Manchester",
    "March", "Marcos", "Marines", "Marlboro", "Marvin", "Maryland", "Massachusetts", "Maurice", "Melbourne",
    "Melvin", "Memphis", "Mexico", "Michaels", "Michigan", "Miguel", "Milan", "Milton", "Milwaukee", "Ming",
    "Minnesota", "Mississippi", "Missouri", "Mister", "Moby", "Mohammed", "Monaco", "Montana", "Monte",
    "Montreal", "Moslem", "Napoleon", "Nathaniel", "Nebraska", "Nevada", "Neville", "Newark", "Nigel", "Nobel",
    "Norfolk", "Nottingham", "Oakland", "Ohio", "Oklahoma", "Olivier", "Omaha", "Omar", "Oprah", "Oregon",
    "Orion", "Orlando", "Oslo", "Pablo", "Pakistan", "Panama", "Paolo", "Paulo", "Pedro", "Pegasus",
    "Pennsylvania", "Peru", "Petersburg", "Picasso", "Pierre", "Pitt", "Pittsburgh", "Pole", "Portland",
    "Portugal", "Prescott", "Princeton", "Rafael", "Ramon", "Raphael", "Reagan", "Remington", "Reno", "Ricardo",
    "Richie", "Ripley", "Ritchie", "Roberto", "Rodney", "Roosevelt", "Rossi", "Royce", "Rudolph", "Rudy",
    "Rupert", "Ryder", "Sacramento", "Salem", "Salvador", "Samson", "Santa", "Saul", "Scotland", "Seoul",
    "Seymour", "Shakespeare", "Sheldon", "Sheridan", "Sherlock", "Sherwood", "Shrek", "Sidney", "Simpsons",
    "Sinatra", "Sinclair", "Singh", "Skye", "Springfield", "Stan", "Stanford", "Stargate", "Stevie",
    "Stockholm", "Tahiti", "Taiwan", "Talbot", "Taliban", "Tennessee", "Thai", "Thailand", "Theodore", "Thor",
    "Tibet", "Timothy", "Titus", "Tokyo", "Toronto", "Torres", "Trent", "Trevor", "Tristan", "Troy", "Truman",
    "Trump", "Tucson", "Tyson", "Ukraine", "Utah", "Vance", "Vega", "Venezuela", "Vermont", "Viagra", "Vince",
    "Vinci", "Vladimir", "Walden", "Wales", "Walsh", "Walt", "Walters", "Walton", "Watson", "Watts", "Webb",
    "Webster", "Wellington", "Wesley", "Weston", "Whitman", "Wilkes", "Wilkins", "Willard", "Willis",
    "Winchester", "Windsor", "Wisconsin", "Wolfe", "Wood", "Wyatt", "Wyoming", "Xavier", "Yale", "Yankee",
    "Yates", "Yorkshire", "Zach"
)
foreach ($n in $targetedEnglishNames) { [void]$namesSet.Add($n) }

# Add obvious English noise and custom words the user pointed out
$englishNoise = @(
    "after", "again", "agent", "agency", "agencies", "agenten", "agents", "never", "ever", "always", 
    "almost", "alright", "anyone", "anything", "anyway", "awesome", "baby", "babys", "bullshit", "bye", 
    "cops", "detective", "detectives", "did", "doc", "dude", "everybody", "everyone", "everything", 
    "fact", "fake", "friends", "fuck", "fucking", "guy", "guys", "hello", "honey", "idea", "jesus", 
    "joke", "kids", "killer", "look", "maybe", "mission", "mom", "mommy", "money", "movie", "nobody", 
    "nothing", "okay", "party", "people", "please", "problem", "problems", "ready", "really", "relax", 
    "right", "safe", "shit", "sir", "someone", "something", "sometimes", "somewhere", "sorry", "story", 
    "sure", "system", "team", "teams", "today", "tomorrow", "town", "wait", "yeah", "yes", "al", "aj", 
    "cj", "dj", "dj", "mac", "mc", "mr", "mrs", "miss", "aunt", "uncle", "brother", "sister"
)
foreach ($e in $englishNoise) { [void]$namesSet.Add($e) }

# Let's also add some typical subtitle last names manually observed if it helps
$manualNames = @("Abbott", "Alaric", "Adalind", "Adama", "Allie", "Alois", "Ames", "Andrews", "Bates", "Benton", "Bishop", "Blair", "Booth", "Bowman", "Bradley", "Brody", "Burke", "Callahan", "Carmichael", "Castle", "Chandler", "Cisco", "Clark", "Clarke", "Cole", "Collins", "Cooper", "Crawford", "Cullen", "Dawson", "Dixon", "Donovan", "Doyle", "Drake", "Dunbar", "Duncan", "Evans", "Fisher", "Fletcher", "Forbes", "Ford", "Foster", "Gallagher", "Garcia", "Garrison", "Gates", "Gibson", "Gordon", "Graham", "Griffin", "Hamilton", "Harding", "Harper", "Harrison", "Harvey", "Hayes", "Henderson", "Higgins", "Hobbs", "Hodges", "Hogan", "Hooper", "Hoover", "Hopkins", "Howe", "Hubbard", "Hudson", "Hughes", "Humphrey", "Hunter", "Hutchinson", "Hyde", "Ingram", "Irwin", "Jackson", "Jacobs", "Jacobson", "Jarvis", "Jefferson", "Jenkins", "Jennings", "Jensen", "Johnson", "Johnston", "Jones", "Jordan", "Joseph", "Joyce", "Kane", "Kaufman", "Keith", "Keller", "Kelley", "Kelly", "Kemp", "Kendall", "Kennedy", "Kent", "Kerr", "Keyes", "Kidd", "Kimball", "Kinney", "Kirby", "Kirk", "Klein", "Kline", "Knapp", "Knight", "Knowles", "Knox", "Koch", "Kramer", "Lamb", "Lambert", "Lancaster", "Landry", "Lane", "Lang", "Larsen", "Larson", "Lawrence", "Lawson", "Leach", "Leal", "Levine", "Lewis", "Little", "Lloyd", "Logan", "Lowe", "Lucas", "Lynch", "Lynn", "Lyons", "Macdonald", "Macias", "Mack", "Madden", "Maddox", "Maldonado", "Malone", "Mann", "Manning", "Marks", "Marquez", "Marsh", "Marshall", "Martin", "Martinez", "Mason", "Massey", "Mathews", "Mathis", "Matthews", "Maxwell", "May", "Mayer", "Maynard", "Mayo", "Mays", "Mcbride", "Mccall", "Mccarthy", "Mccarty", "Mcclain", "Mcclure", "Mcconnell", "Mccormick", "Mccoy", "Mccullough", "Mcdaniel", "Mcdonald", "Mcdowell", "Mcfadden", "Mcfarland", "Mcgee", "Mcgowan", "Mcguire", "Mcintosh", "Mcintyre", "Mckay", "Mckee", "Mckenzie", "Mckinney", "Mcknight", "Mclaughlin", "Mclean", "Mcleod", "Mcmahon", "Mcmillan", "Mcneil", "Mcpherson", "Meadows", "Medina", "Mejia", "Melendez", "Melton", "Mendez", "Mendoza", "Mercado", "Mercer", "Merrill", "Merritt", "Meyer", "Meyers", "Michael", "Middleton", "Miles", "Miller", "Mills", "Miranda", "Mitchell", "Molina", "Monroe", "Montgomery", "Montoya", "Moody", "Moon", "Moore", "Mora", "Morales", "Moran", "Moreno", "Morgan", "Morin", "Morris", "Morrison", "Morrow", "Morse", "Morton", "Moses", "Mosley", "Moss", "Mueller", "Mullen", "Mullins", "Munoz", "Murillo", "Murphy", "Murray", "Myers", "Nash", "Navarro", "Neal", "Nelson", "Newman", "Newton", "Nguyen", "Nichols", "Nicholson", "Nielsen", "Nieves", "Nixon", "Noble", "Noel", "Nolan", "Norman", "Norris", "Norton", "Nunez", "OBrien", "Ochoa", "Oconnor", "Odom", "Odonnell", "Oliver", "Olsen", "Olson", "Oneal", "Oneill", "Orr", "Ortega", "Ortiz", "Osborn", "Osborne", "Owen", "Owens", "Pace", "Pacheco", "Padilla", "Page", "Palmer", "Park", "Parker", "Parks", "Parrish", "Parsons", "Pate", "Patel", "Patrick", "Patterson", "Patton", "Paul", "Payne", "Paz", "Pearson", "Peck", "Pena", "Penn", "Pennington", "Perez", "Perkins", "Perry", "Peters", "Petersen", "Peterson", "Petty", "Phelps", "Phillips", "Pickett", "Pierce", "Pittman", "Pitts", "Pollard", "Poole", "Pope", "Porter", "Potter", "Potts", "Powell", "Powers", "Pratt", "Preston", "Price", "Prince", "Pruitt", "Pugh", "Quinn", "Ramirez", "Ramos", "Ramsey", "Randall", "Randolph", "Rasmussen", "Ratliff", "Ray", "Raymond", "Reed", "Reese", "Reeves", "Reid", "Reilly", "Reyes", "Reynolds", "Rhodes", "Richard", "Richards", "Richardson", "Richmond", "Riddle", "Riggs", "Riley", "Rios", "Rivas", "Rivera", "Rivers", "Roach", "Robbins", "Roberson", "Roberts", "Robertson", "Robinson", "Robles", "Rocha", "Rodgers", "Rodriguez", "Rodriquez", "Rogers", "Rojas", "Rollins", "Roman", "Romero", "Rosa", "Rosales", "Rosario", "Rose", "Ross", "Roth", "Rowe", "Rowland", "Roy", "Ruiz", "Rush", "Russell", "Russo", "Rutledge", "Ryan", "Salas", "Salazar", "Salinas", "Sampson", "Sanchez", "Sanders", "Sandoval", "Sanford", "Santana", "Santiago", "Santos", "Sargent", "Saunders", "Savage", "Sawyer", "Schmidt", "Schmitt", "Schneider", "Schroeder", "Schultz", "Schwartz", "Scott", "Sears", "Sellers", "Serrano", "Sexton", "Shaffer", "Shannon", "Sharp", "Sharpe", "Shaw", "Shelton", "Shepard", "Shepherd", "Sheppard", "Sherman", "Shields", "Short", "Silva", "Simmons", "Simon", "Simpson", "Sims", "Singleton", "Skinner", "Slater", "Sloan", "Small", "Smith", "Snider", "Snow", "Snyder", "Solis", "Solomon", "Sosa", "Soto", "Sparks", "Spears", "Spence", "Spencer", "Stafford", "Stanley", "Stanton", "Stark", "Steele", "Stephens", "Stephenson", "Stevens", "Stevenson", "Stewart", "Stokes", "Stone", "Stout", "Strickland", "Strong", "Stuart", "Suarez", "Sullivan", "Summers", "Sutton", "Swanson", "Sweeney", "Sweet", "Sykes", "Talley", "Tanner", "Tate", "Taylor", "Terrell", "Terry", "Thomas", "Thompson", "Thornton", "Tillman", "Todd", "Townsend", "Tran", "Travis", "Trevino", "Tucker")
foreach ($m in $manualNames) { [void]$namesSet.Add($m) }

$lines = [System.IO.File]::ReadAllLines($extDictPath, [System.Text.Encoding]::UTF8)

$removedCount = 0
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
    
    if ($namesSet.Contains($word)) {
        $removedCount++
        continue
    }

    $entries += [PSCustomObject]@{ Word = $word; Code = $parts[1]; Weight = [int]$parts[2] }
}

$sortedEntries = $entries | Sort-Object @{Expression={$_.Word}; Descending=$false}, @{Expression={$_.Code}; Descending=$false}

$finalLines = New-Object System.Collections.Generic.List[string]
foreach ($h in $header) { $finalLines.Add($h) }
foreach ($e in $sortedEntries) { $finalLines.Add("$($e.Word)`t$($e.Code)`t$($e.Weight)") }

$utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($extDictPath, $finalLines, $utf8NoBom)

Write-Host "Removed $removedCount potential names and English words."
Write-Host "Total entries remaining: $($sortedEntries.Count)"
