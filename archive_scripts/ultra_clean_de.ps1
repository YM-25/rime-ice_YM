$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$basePath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de.dict.yaml"
$extPath = "c:\Users\90589\AppData\Roaming\Rime\de_dicts\de_ext.dict.yaml"
$refPath = "c:\Users\90589\AppData\Roaming\Rime\trash\wortliste_ref.txt"
$enDictPath = "c:\Users\90589\AppData\Roaming\Rime\en_dicts\en.dict.yaml"
$logPath = "c:\Users\90589\AppData\Roaming\Rime\trash\ultra_clean_log.txt"

$utf8NoBom = New-Object System.Text.UTF8Encoding $False

$blacklist = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
$manualNoise = @(
    "After", "Again", "Agent", "Agency", "Agencies", "Access", "Across", "Actually", "Against", "Ahead", "Almost", "Alone", "Already", "Alright", "Always",
    "Among", "Another", "Anyone", "Anything", "Anyway", "Anywhere", "Army", "Archer", "Around", "Arrow", "Awesome", "Baby", "Back", "Because", "Before", "Being",
    "Believe", "Below", "Beside", "Between", "Beyond", "Both", "Call", "Cannot", "Certain", "Change", "Check", "Close", "Come", "Could", "Course", "Does", "Done", "During",
    "Each", "Early", "Either", "Else", "Enough", "Even", "Ever", "Every", "Everybody", "Everyone", "Everything", "Everywhere", "Face", "Fact", "Feel", "Find", "First",
    "Found", "From", "Full", "Further", "Give", "Good", "Great", "Half", "Have", "Hear", "Heard", "Hello", "Help", "Here", "Hope", "However", "Idea", "Into", "Itself",
    "Just", "Keep", "Kind", "Knew", "Know", "Last", "Late", "Later", "Least", "Less", "Let", "Like", "Little", "Live", "Long", "Looked", "Looking", "Love", "Made", "Make", "Many",
    "Maybe", "Mean", "Might", "Mind", "Miss", "More", "Most", "Mother", "Move", "Much", "Must", "Myself", "Near", "Need", "Never", "New", "Next", "Night", "None", "Nothing",
    "Nowhere", "Often", "Once", "Only", "Open", "Other", "Others", "Over", "Part", "People", "Place", "Please", "Point", "Quite", "Rather", "Read", "Real", "Really",
    "Reason", "Right", "Said", "Same", "Several", "Shall", "Short", "Should", "Show", "Side", "Since", "Small", "Some", "Someone", "Something", "Sometime", "Somewhere",
    "Soon", "Sorry", "Still", "Such", "Sure", "Take", "Tell", "Than", "Thank", "Thanks", "That", "The", "Their", "Them", "Themselves", "Then", "There", "Therefore", "These",
    "They", "Thing", "Things", "Think", "This", "Those", "Though", "Thought", "Three", "Through", "Till", "Time", "Together", "Took", "Toward", "Turn", "Two", "Under", "Until",
    "Upon", "Used", "Very", "Wait", "Want", "Wanted", "Whatever", "When", "Where", "Whether", "Which", "While", "Whole", "Whom", "Whose", "World", "Would", "Write", "Year",
    "Years", "Young", "Your", "Yours", "Viagra",
    "Alan", "Alain", "Albert", "Alberto", "Alexandra", "Alexandre", "Alex", "Alexis", "Alfonso", "Alfred", "Alice", "Alicia", "Alison", "Allan", "Allen", "Allison",
    "Alvin", "Amanda", "Amber", "Amy", "Andre", "Andrea", "Andrew", "Andy", "Angela", "Angie", "Anita", "Ann", "Anna", "Anne", "Annette", "Annie", "Anthony", "Antonio",
    "April", "Archibald", "Archie", "Ariana", "Ariel", "Arlene", "Armand", "Arnold", "Arthur", "Ashley", "Audrey", "Austin", "Barbara", "Barry", "Beatrice", "Becky",
    "Belinda", "Ben", "Benjamin", "Bernadette", "Bernard", "Bernice", "Bert", "Bertha", "Bessie", "Beth", "Bethany", "Betsy", "Betty", "Beverly", "Bill", "Billie",
    "Billy", "Blair", "Blake", "Bob", "Bobbie", "Bobby", "Bonnie", "Brad", "Bradley", "Brandon", "Brandy", "Brenda", "Brendan", "Brent", "Brett", "Brian", "Bridget",
    "Britney", "Brittany", "Brooke", "Bruce", "Bryan", "Byron", "Caleb", "Calvin", "Cameron", "Camille", "Candace", "Candice", "Carl", "Carla", "Carlos", "Carlton",
    "Carmen", "Carol", "Carole", "Caroline", "Carolyn", "Carrie", "Carroll", "Cary", "Casey", "Cassandra", "Catherine", "Cathy", "Cecil", "Cecilia", "Celia", "Chad",
    "Charles", "Charlie", "Charlotte", "Charlton", "Chase", "Chelsea", "Cheryl", "Chester", "Chris", "Christian", "Christina", "Christine", "Christopher", "Christy",
    "Cindy", "Claire", "Clara", "Clarence", "Clark", "Claude", "Claudia", "Clay", "Clayton", "Clifford", "Clifton", "Clint", "Clinton", "Clyde", "Cody", "Colby", "Cole",
    "Colin", "Colleen", "Connie", "Connor", "Conrad", "Constance", "Cora", "Corey", "Cornelius", "Cory", "Courtney", "Craig", "Cristina", "Crystal", "Curtis", "Cynthia",
    "Daisy", "Dale", "Dallas", "Dalton", "Damian", "Damien", "Dan", "Dana", "Daniel", "Danielle", "Danny", "Daphne", "Darren", "Darrin", "Daryl", "Dave", "David", "Dawn",
    "Dean", "Deanna", "Debbie", "Deborah", "Debra", "Delores", "Denise", "Dennis", "Derek", "Derrick", "Desiree", "Devin", "Dexter", "Diana", "Diane", "Dianne", "Dick",
    "Diego", "Dillon", "Dolores", "Dominic", "Don", "Donald", "Donna", "Donnie", "Doris", "Dorothy", "Doug", "Douglas", "Drew", "Duane", "Dustin", "Dwayne", "Dwight",
    "Dylan", "Earl", "Earnest", "Ed", "Eddie", "Edgar", "Edith", "Edmond", "Edmund", "Edna", "Edward", "Edwin", "Effie", "Eileen", "Elaine", "Eleanor", "Elena", "Eli",
    "Elias", "Elijah", "Elizabeth", "Ella", "Ellen", "Ellis", "Elmer", "Eloise", "Elsa", "Elsie", "Elva", "Emma", "Emmanuel", "Emmett", "Eric", "Erica", "Erik", "Erika",
    "Erin", "Ernest", "Esther", "Ethel", "Eugene", "Eunice", "Eva", "Evan", "Evelyn", "Everett", "Faith", "Fannie", "Fay", "Felicia", "Felix", "Fernando", "Flora",
    "Florence", "Floyd", "Frances", "Francis", "Francisco", "Frank", "Franklin", "Fred", "Freda", "Freddie", "Frederick", "Gabriel", "Gail", "Garrett", "Gary", "Gavin",
    "Gene", "George", "Georgia", "Gerald", "Geraldine", "Gertrude", "Gilbert", "Gina", "Gladys", "Glen", "Glenda", "Glenn", "Gloria", "Gordon", "Grace", "Greg",
    "Gregory", "Gretchen", "Guy", "Gwen", "Gwendolyn", "Harold", "Harriet", "Harrison", "Harry", "Harvey", "Hazel", "Heather", "Helen", "Henry", "Herbert", "Herman",
    "Hillary", "Holly", "Hope", "Howard", "Hubert", "Hugh", "Ian", "Ida", "Inez", "Ira", "Irene", "Iris", "Irma", "Isaac", "Isabel", "Ivan", "Jack", "Jackie", "Jackson",
    "Jacob", "Jacqueline", "Jacquelyn", "Jake", "James", "Jamie", "Jan", "Jane", "Janet", "Janice", "Janie", "Janis", "Jared", "Jason", "Jasper", "Jay", "Jean",
    "Jeanette", "Jeanne", "Jeannie", "Jeff", "Jefferson", "Jeffrey", "Jenna", "Jennie", "Jennifer", "Jenny", "Jeremy", "Jerome", "Jerry", "Jesse", "Jessica", "Jessie",
    "Jill", "Jim", "Jimmie", "Jimmy", "Jo", "Joan", "Joann", "Joanna", "Joanne", "Jodie", "Joe", "Joel", "Joey", "John", "Johnnie", "Johnny", "Jon", "Jonathan", "Jordan",
    "Joseph", "Josephine", "Joshua", "Joy", "Joyce", "Juan", "Juanita", "Judith", "Judy", "Julia", "Julian", "Julie", "Julius", "June", "Justin", "Karen", "Karl",
    "Katherine", "Kathleen", "Kathryn", "Kathy", "Katie", "Kay", "Keith", "Kelly", "Ken", "Kenneth", "Kent", "Kevin", "Kim", "Kimberly", "Kirk", "Kristin", "Kristina",
    "Kristine", "Kyle", "Lana", "Lance", "Larry", "Laura", "Lauren", "Laurence", "Laurie", "Lawrence", "Leah", "Lee", "Leigh", "Lela", "Lelia", "Lena", "Leo", "Leon",
    "Leona", "Leonard", "Leroy", "Leslie", "Lester", "Leticia", "Letitia", "Lewis", "Liam", "Lila", "Lillian", "Lillie", "Lily", "Linda", "Lindsay", "Lindsey", "Lisa",
    "Lloyd", "Lois", "Lola", "Lonnie", "Lora", "Loren", "Lorena", "Loretta", "Lori", "Lorraine", "Lou", "Louis", "Louisa", "Louise", "Lowell", "Lucille", "Lucy", "Luke",
    "Lula", "Lulu", "Lydia", "Lyle", "Lynn", "Mabel", "Mable", "Mack", "Madeline", "Mae", "Maggie", "Mamie", "Mandy", "Manuel", "Marc", "Marco", "Marcus", "Margaret",
    "Margarita", "Margie", "Marguerite", "Maria", "Marian", "Marianne", "Marie", "Marilyn", "Mario", "Marion", "Marjorie", "Mark", "Marlene", "Marshall", "Martha",
    "Martin", "Marvin", "Mary", "Matt", "Matthew", "Mattie", "Maude", "Maureen", "Maurice", "Max", "Maxine", "May", "Megan", "Melanie", "Melinda", "Melissa", "Melvin",
    "Mercedes", "Meredith", "Michael", "Michelle", "Mickey", "Mike", "Mildred", "Milton", "Minnie", "Miranda", "Miriam", "Misty", "Mitchell", "Molly", "Monica", "Monique",
    "Morgan", "Morris", "Moses", "Muriel", "Myra", "Myrtle", "Nadia", "Nadine", "Nancy", "Naomi", "Natalie", "Natasha", "Nathan", "Nathaniel", "Neil", "Nellie", "Nelson",
    "Nettie", "Nicholas", "Nicole", "Nina", "Noah", "Noel", "Nora", "Norma", "Norman", "Olive", "Oliver", "Olivia", "Ollie", "Opal", "Ora", "Oscar", "Otis", "Owen",
    "Pam", "Pamela", "Pat", "Patricia", "Patrick", "Patsy", "Patti", "Patty", "Paul", "Paula", "Paulette", "Pauline", "Pearl", "Pedro", "Peggy", "Penny", "Percy",
    "Perry", "Pete", "Peter", "Phil", "Philip", "Phillip", "Phyllis", "Priscilla", "Rachel", "Ralph", "Ramon", "Ramona", "Randall", "Randy", "Raphael", "Raul", "Ray",
    "Raymond", "Rebecca", "Regina", "Reginald", "Reid", "Rene", "Renee", "Reuben", "Ricardo", "Richard", "Rick", "Rickey", "Ricky", "Riley", "Rita", "Rob", "Robert",
    "Roberta", "Roberto", "Robin", "Robyn", "Rochelle", "Rocky", "Rodney", "Roger", "Roland", "Ron", "Ronald", "Ronnie", "Roosevelt", "Rory", "Rosa", "Rosalie", "Rose",
    "Rosemarie", "Rosemary", "Rosie", "Ross", "Roy", "Ruben", "Ruby", "Rufus", "Russell", "Ruth", "Ryan", "Sabrina", "Sadie", "Sally", "Salvador", "Sam", "Samantha",
    "Samuel", "Sandra", "Sandy", "Sara", "Sarah", "Sasha", "Saul", "Scott", "Sean", "Sebastian", "Seth", "Shane", "Shannon", "Sharon", "Shaun", "Shawn", "Sheila",
    "Shelia", "Shelley", "Shelly", "Shelton", "Sherri", "Sherry", "Sheryl", "Shirley", "Sidney", "Silvia", "Simon", "Sonia", "Sonya", "Sophia", "Sophie", "Spencer",
    "Stacey", "Stacy", "Stan", "Stanley", "Stella", "Stephan", "Stephanie", "Stephen", "Steve", "Steven", "Stewart", "Stuart", "Sue", "Susan", "Susie", "Suzanne",
    "Sylvester", "Sylvia", "Tabitha", "Tamara", "Tammy", "Tanya", "Tara", "Tasha", "Taylor", "Ted", "Teddy", "Teresa", "Terrence", "Terri", "Terry", "Tessa", "Thelma",
    "Theodore", "Theresa", "Therese", "Thomas", "Tiffany", "Tim", "Timothy", "Tina", "Todd", "Tom", "Tomas", "Tommie", "Tommy", "Tony", "Tracey", "Traci", "Tracy",
    "Travis", "Trent", "Trevor", "Tricia", "Troy", "Tyler", "Valerie", "Vanessa", "Vera", "Verna", "Vernon", "Veronica", "Vic", "Vicki", "Vickie", "Victor", "Victoria",
    "Vincent", "Viola", "Violet", "Virgil", "Virginia", "Vivian", "Wade", "Wallace", "Walter", "Warren", "Wayne", "Wendell", "Wendy", "Wesley", "Whitney", "Will",
    "Willard", "William", "Willie", "Willis", "Wilson", "Winifred", "Winston", "Wyatt", "Xavier", "Yolanda", "Yvette", "Yvonne", "Zachary", "Zoe",
    "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana",
    "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
    "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
    "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming",
    "Albuquerque", "Anchorage", "Atlanta", "Austin", "Baltimore", "Boise", "Boston", "Buffalo", "Charlotte", "Chicago", "Cincinnati", "Cleveland", "Columbus", "Dallas",
    "Denver", "Detroit", "Honolulu", "Houston", "Indianapolis", "Jacksonville", "Las Vegas", "Little Rock", "Los Angeles", "Louisville", "Memphis", "Miami", "Milwaukee",
    "Minneapolis", "Nashville", "New Orleans", "New York", "Newark", "Oakland", "Oklahoma City", "Omaha", "Philadelphia", "Phoenix", "Pittsburgh", "Portland", "Providence",
    "Raleigh", "Richmond", "Sacramento", "Saint Louis", "Salt Lake City", "San Antonio", "San Diego", "San Francisco", "San Jose", "Seattle", "Tampa", "Tucson", "Tulsa",
    "Virginia Beach", "Wichita"
)
foreach ($n in $manualNoise) { [void]$blacklist.Add($n) }

Write-Host "Loading German Reference wordlist..."
$refMap = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([System.StringComparer]::OrdinalIgnoreCase)
if (Test-Path $refPath) {
    $refLines = [System.IO.File]::ReadAllLines($refPath, [System.Text.Encoding]::UTF8)
    foreach ($line in $refLines) {
        $w = $line.Trim(); if ($w -and -not $refMap.ContainsKey($w)) { $refMap[$w] = $w }
    }
}

Write-Host "Loading English Dictionary for Overlap check..."
$enSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
if (Test-Path $enDictPath) {
    $enLines = [System.IO.File]::ReadAllLines($enDictPath, [System.Text.Encoding]::UTF8)
    foreach ($line in $enLines) {
        if ($line -match "^([A-Za-z'-]+)`t") { [void]$enSet.Add($matches[1]) }
    }
}

# Explicit Umlaut characters for regex to avoid encoding issues
$umlauts = "[$( [char]0xE4 )$( [char]0xF6 )$( [char]0xFC )$( [char]0xC4 )$( [char]0xD6 )$( [char]0xDC )$( [char]0xDF )]"

function Clean-DictFile([string]$path) {
    Write-Host "Cleaning $path ..."
    if (-not (Test-Path $path)) { return }
    $lines = [System.IO.File]::ReadAllLines($path, [System.Text.Encoding]::UTF8)
    $finalLines = New-Object System.Collections.Generic.List[string]
    $header = $true
    foreach ($line in $lines) {
        if ($header) {
            $finalLines.Add($line)
            if ($line.StartsWith("...")) { $header = $false }
            continue
        }
        $parts = $line.Split("`t")
        if ($parts.Count -lt 2) { $finalLines.Add($line); continue }
        $word = $parts[0]

        # 1. Blacklist check
        if ($blacklist.Contains($word)) { continue }

        # 2. Case Alignment & Ref Check
        if ($refMap.ContainsKey($word)) {
            $mapped = $refMap[$word]
            if ($word -match $umlauts) {
                 $finalLines.Add($line.Replace($word, $mapped))
            } else {
                 $code = if ($parts.Count -gt 1) { $parts[1] } else { $word }
                 $weight = if ($parts.Count -gt 2) { $parts[2] } else { "100" }
                 $finalLines.Add("$mapped`t$code`t$weight")
            }
            continue
        }

        # 3. EN Overlap Removal (if not in Ref)
        if ($enSet.Contains($word)) { continue }

        # 4. Strict Names cleanup (Capitalized word not in Ref)
        if ($word -cmatch "^[A-Z]") { continue }

        $finalLines.Add($line)
    }
    
    # Sort and Deduplicate
    $headerLines = New-Object System.Collections.Generic.List[string]
    $entries = New-Object System.Collections.Generic.List[PSCustomObject]
    $hdr = $true
    foreach ($l in $lines) {
        if ($hdr) {
            $headerLines.Add($l)
            if ($l.StartsWith("...")) { $hdr = $false }
        } else { break }
    }
    foreach ($fl in $finalLines) {
        $p = $fl.Split("`t")
        if ($p.Count -ge 2) { 
            $w = $p[0]
            $c = $p[1]
            $wt = if ($p.Count -gt 2) { $p[2] } else { "100" }
            $entries.Add([PSCustomObject]@{ Word = $w; Code = $c; Weight = $wt }) 
        }
    }
    $unique = $entries | Sort-Object Word, Code | Group-Object Word, Code | ForEach-Object { $_.Group[0] }
    
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($hl in $headerLines) { $out.Add($hl) }
    foreach ($u in $unique) { $out.Add("$($u.Word)`t$($u.Code)`t$($u.Weight)") }
    
    [System.IO.File]::WriteAllLines($path, $out, $utf8NoBom)
}

Clean-DictFile $basePath
Clean-DictFile $extPath

Write-Host "Cleanup completed for both base and extension dictionaries."
