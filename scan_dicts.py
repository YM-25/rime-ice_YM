import re
from pathlib import Path
import sys

# Ensure UTF-8 output
if sys.stdout.encoding.lower() != 'utf-8':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def scan_dict(file_path):
    # Non-German characters (common French, Spanish, etc.)
    # We allow standard German: a-z, ä, ö, ü, ß
    # Anything else in the 'Word' column is a match
    non_german_pattern = re.compile(r'[^\sa-zA-ZäöüÄÖÜß\t0-9\-]', re.IGNORECASE)
    results = []
    
    if not Path(file_path).exists():
        print(f"File not found: {file_path}")
        return []

    with open(file_path, 'r', encoding='utf-8') as f:
        line_num = 0
        in_header = True
        for line in f:
            line_num += 1
            if in_header:
                if line.startswith('...'):
                    in_header = False
                continue
            
            parts = line.strip().split('\t')
            if not parts: continue
            word = parts[0]
            
            if non_german_pattern.search(word):
                results.append((line_num, line.strip()))
    
    return results

base_path = Path(r'c:\Users\90589\AppData\Roaming\Rime\de_dicts')
for dict_file in ['de.dict.yaml', 'de_ext.dict.yaml']:
    print(f"--- Scanning {dict_file} ---")
    matches = scan_dict(base_path / dict_file)
    for ln, content in matches:
        print(f"{ln}: {content}")
