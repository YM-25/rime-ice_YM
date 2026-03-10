import os
import requests
import pandas as pd
import re
import yaml
import math
from pathlib import Path

class RimeDictionaryManager:
    def __init__(self, base_dir=None):
        self.base_dir = Path(base_dir or os.getcwd())
        self.dict_dir = self.base_dir / "de_dicts"
        self.trash_dir = self.base_dir / "trash"
        self.en_dict_path = self.base_dir / "en_dicts" / "en.dict.yaml"
        self.ref_list_path = self.trash_dir / "wortliste_ref.txt"
        
        self.words_url_5000 = "https://raw.githubusercontent.com/badranX/german-frequency/master/data/5000.txt"
        self.words_url_50k = "https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/de/de_50k.txt"
        self.raw_50k_path = self.base_dir / "de_50k_raw.txt"
        
        # Characters for code generation
        self.umlaut_map_ae = {"ä": "ae", "ö": "oe", "ü": "ue", "ß": "ss"}
        self.umlaut_map_a = {"ä": "a", "ö": "o", "ü": "u", "ß": "s"}
        
        self.extra_words = [
            "Apotheke", "Krankenhaus", "Flughafen", "Feuerwehr", "Polizei", 
            "Bürgersteig", "Zebrastreifen", "Umwelt", "Treibhauseffekt", "Bahnhof", 
            "Mädchen", "Gemüse", "Fußball", "Großvater", "Schüler", 
            "Arzt", "Zahnarzt", "Tschüss", "Zweifel"
        ]

    def get_rime_codes(self, word):
        """Generates two codes for a German word (with and without full umlaut expansion)."""
        w_lower = word.lower()
        
        # Code 1: ae, oe, ue, ss
        c1 = w_lower
        for char, replacement in self.umlaut_map_ae.items():
            c1 = c1.replace(char, replacement)
        c1 = re.sub(r'[^a-z]', '', c1)
        
        # Code 2: a, o, u, s
        c2 = w_lower
        for char, replacement in self.umlaut_map_a.items():
            c2 = c2.replace(char, replacement)
        c2 = re.sub(r'[^a-z]', '', c2)
        
        codes = [c1]
        if c2 and c2 != c1:
            codes.append(c2)
        return codes

    def save_rime_dict(self, filename, dict_name, entries):
        """Saves entries in Rime's tab-separated format with YAML header."""
        out_path = self.dict_dir / filename
        self.dict_dir.mkdir(exist_ok=True)
        
        header = [
            "---",
            f"name: {dict_name}",
            "version: \"2024.03.10\"",
            "sort: by_weight",
            "...",
            ""
        ]
        
        # Deduplicate and sort
        df = pd.DataFrame(entries, columns=['Word', 'Code', 'Weight'])
        df = df.sort_values(by=['Word', 'Code'])
        
        with open(out_path, 'w', encoding='utf-8', newline='\n') as f:
            f.write('\n'.join(header) + '\n')
            for _, row in df.iterrows():
                f.write(f"{row['Word']}\t{row['Code']}\t{row['Weight']}\n")
        
        print(f"Saved {len(df)} entries to {filename}")

    def generate_base(self):
        """Generates the base 'de' dictionary from 5000 word list."""
        print("Fetching 5000 word list...")
        response = requests.get(self.words_url_5000)
        words = [w.strip() for w in response.text.splitlines() if w.strip()]
        
        # Merge with extra words and deduplicate
        all_words = list(dict.fromkeys(words + self.extra_words))
        
        entries = []
        for word in all_words:
            weight = 50 if word in self.extra_words else 100
            for code in self.get_rime_codes(word):
                entries.append({'Word': word, 'Code': code, 'Weight': weight})
        
        self.save_rime_dict("de.dict.yaml", "de", entries)
        return set(all_words)

    def download_50k(self):
        """Downloads the 50k raw list if it's missing."""
        if not self.raw_50k_path.exists():
            print(f"Downloading 50k raw list from {self.words_url_50k}...")
            response = requests.get(self.words_url_50k)
            with open(self.raw_50k_path, 'w', encoding='utf-8') as f:
                f.write(response.text)
            print("Download complete.")

    def generate_ext(self, base_word_set):
        """Generates the 'de_ext' dictionary from 50k raw file."""
        self.download_50k()
        if not self.raw_50k_path.exists():
            print("Raw 50k list missing! Skipping Extension dictionary.")
            return

        print("Generating extension dictionary from 50k list...")
        entries = []
        count = 0
        
        # Blacklist of names (case-insensitive set)
        names_blacklist_raw = {
            "Aaron", "Abby", "Abdul", "Abe", "Abel", "Abraham", "Abram", "Ada", "Adam", "Adams", "Addison", "Adeline", "Adrian", "Adrienne", "Agnes", "Ahmed", "Aidan", "Aileen", "Alan", "Alana", "Albert", "Alberto", "Albrecht", "Alec", "Alejandra", "Alejandro", "Alex", "Alexander", "Alexandra", "Alexandre", "Alexandria", "Alexis", "Alfonso", "Alfred", "Alfredo", "Ali", "Alice", "Alicia", "Alisa", "Alison", "Alix", "Allan", "Allen", "Allison", "Alma", "Alonzo", "Alphonso", "Alvin", "Alyssa", "Amanda", "Amber", "Amelia", "Amos", "Amy", "Andre", "Andrea", "Andreas", "Andrew", "Andy", "Angela", "Angelica", "Angelina", "Angeline", "Angelo", "Angie", "Angus", "Anita", "Ann", "Anna", "Annabel", "Anne", "Annette", "Annie", "Annika", "Anthony", "Antoinette", "Anton", "Antone", "Antonia", "Antonio", "Antony", "April", "Archibald", "Archie", "Ariana", "Ariel", "Arlene", "Armand", "Arnold", "Arthur", "Arturo", "Ashley", "Aubrey", "Audrey", "Augustus", "Austin", "Barbara", "Barry", "Beatrice", "Becky",
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
            "Margarita", "Margie", "Marguerite", "Maria", "Marianne", "Marie", "Marilyn", "Mario", "Marion", "Marjorie", "Mark", "Marlene", "Marshall", "Martha",
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
            "Sheila", "Shelley", "Shelly", "Shelton", "Sherri", "Sherry", "Sheryl", "Shirley", "Sidney", "Silvia", "Simon", "Sonia", "Sonya", "Sophia", "Sophie", "Spencer",
            "Stacey", "Stacy", "Stan", "Stanley", "Stella", "Stephan", "Stephanie", "Stephen", "Steve", "Steven", "Stewart", "Stuart", "Sue", "Susan", "Susie", "Suzanne",
            "Sylvester", "Sylvia", "Tabitha", "Tamara", "Tammy", "Tanya", "Tara", "Tasha", "Taylor", "Ted", "Teddy", "Teresa", "Terrence", "Terri", "Terry", "Tessa", "Thelma",
            "Theodore", "Theresa", "Therese", "Thomas", "Tiffany", "Tim", "Timothy", "Tina", "Todd", "Tom", "Tomas", "Tommie", "Tommy", "Tony", "Tracey", "Traci", "Tracy",
            "Travis", "Trent", "Trevor", "Tricia", "Troy", "Tyler", "Valerie", "Vanessa", "Vera", "Verna", "Vernon", "Veronica", "Vic", "Vicki", "Vickie", "Victor", "Victoria",
            "Vincent", "Viola", "Violet", "Virgil", "Virginia", "Vivian", "Wade", "Wallace", "Walter", "Warren", "Wayne", "Wendell", "Wendy", "Wesley", "Whitney", "Will",
            "Willard", "William", "Willie", "Willis", "Wilson", "Winifred", "Winston", "Wyatt", "Xavier", "Yolanda", "Yvette", "Yvonne", "Zachary", "Zoe",
            "New", "London", "Paris", "Sydney", "Houston", "Chicago", "Boston", "Miami", "Vegas", "Dallas", "Detroit", "Philadelphia", "Baltimore", "Kansas", "Arizona",
            "Hawaii", "England"
        }
        names_blacklist = {n.lower() for n in names_blacklist_raw}
        
        # Exceptions (German cities/countries to keep)
        keep_locations = {"Venedig", "Rom", "Tokio", "Kuba", "Indien", "Afrika", "Griechenland", "Schottland", "Spanien", "Italien", "Frankreich", "Amerika", "Berlin"}
        
        with open(self.raw_50k_path, 'r', encoding='utf-8') as f:
            for line in f:
                if count >= 20000: break
                parts = line.strip().split(' ')
                if len(parts) < 2: continue
                
                word = parts[0]
                try:
                    freq = int(parts[1])
                except: continue
                
                count += 1
                
                # Filtering logic
                word_lower = word.lower()
                if word_lower in base_word_set: continue
                if word_lower in names_blacklist and word not in keep_locations: continue
                
                weight = round(math.log10(freq) * 10)
                for code in self.get_rime_codes(word):
                    entries.append({'Word': word, 'Code': code, 'Weight': weight})
                    
        self.save_rime_dict("de_ext.dict.yaml", "de_ext", entries)

    def clean_dictionaries(self):
        """Ultra clean: removal of EN overlaps and noise."""
        print("Running ultra clean logic...")
        
        # Load English dict for overlap removal
        en_words = set()
        if self.en_dict_path.exists():
            with open(self.en_dict_path, 'r', encoding='utf-8') as f:
                for line in f:
                    m = re.match(r"^([A-Za-z'-]+)\t", line)
                    if m: en_words.add(m.group(1).lower())
        
        # Load Manual Anti-noise list
        manual_noise_raw = {
            "About", "After", "Again", "Agent", "Agency", "Agencies", "Access", "Across", "Actually", "Against", "Ahead", "Almost", "Alone", "Already", "Alright", "Always",
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
            "Years", "Young", "Your", "Yours", "Viagra"
        }
        manual_noise = {n.lower() for n in manual_noise_raw}

        # Reference map for case correction
        ref_map = {}
        if self.ref_list_path.exists():
            with open(self.ref_list_path, 'r', encoding='utf-8') as f:
                for line in f:
                    w = line.strip()
                    if w: ref_map[w.lower()] = w

        for file in ["de.dict.yaml", "de_ext.dict.yaml"]:
            path = self.dict_dir / file
            if not path.exists(): continue
            
            print(f"Cleaning {file}...")
            header_lines = []
            entries = []
            in_header = True
            
            with open(path, 'r', encoding='utf-8') as f:
                for line in f:
                    if in_header:
                        header_lines.append(line.strip())
                        if line.startswith("..."): in_header = False
                        continue
                    
                    parts = line.strip().split('\t')
                    if len(parts) < 2: continue
                    
                    word = parts[0]
                    word_lower = word.lower()
                    weight = parts[2] if len(parts) > 2 else "100"
                    
                    # 1. Noise check (case-insensitive)
                    if word_lower in manual_noise: continue
                    
                    # 2. Case correction via reference
                    if word_lower in ref_map:
                        word = ref_map[word_lower]
                    
                    # 3. EN Overlap (don't remove if it's in Ref map)
                    if word_lower in en_words and word_lower not in ref_map:
                        continue
                        
                    # 4. Filter capitalized words not in reference (mostly names)
                    if word[0].isupper() and word_lower not in ref_map:
                        continue
                    
                    entries.append({'Word': word, 'Code': parts[1], 'Weight': weight})

            # Re-save cleaned entries
            self.save_rime_dict(file, file.replace(".dict.yaml", ""), entries)

if __name__ == "__main__":
    manager = RimeDictionaryManager()
    base_words = manager.generate_base()
    manager.generate_ext(base_words)
    manager.clean_dictionaries()
    print("All tasks completed successfully via Python!")
