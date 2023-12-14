import nltk
import csv
import re
import json
from nltk.corpus import stopwords
from pathlib import Path
from collections import Counter

# nltk.download('stopwords')
path = Path(__file__).parent / '../django_list_3.csv'
outputk_path = Path(__file__).parent / './various_info_files/most_common_django_repo_keywords.json'
outputo_path = Path(__file__).parent / './various_info_files/most_common_django_users.json'
outputs_path = Path(__file__).parent / './various_info_files/most_common_django_substring_keywords.json'
with path.open() as csv_file:
    reader = csv.DictReader(csv_file)
    owner_counter = Counter()
    keywords_counter = Counter()
    substring_keywords_counter = {}

    for row in reader:
        owner = row["repo_url"].split("/")[3]
        keywords = [x.lower() for x in re.split('-|_', row["repo_url"].split("/")[4])]
        filtered_keywords = list(filter(lambda str: str not in stopwords.words('english'), keywords))
        owner_counter.update([owner])
        keywords_counter.update(filtered_keywords)
        
for substring in list(keywords_counter.keys()):
    if len(substring) > 2:
        substring_keywords_counter[substring] = keywords_counter[substring]
        for key in list(keywords_counter.keys()):
            if substring != key and substring in key:
                substring_keywords_counter[substring] += keywords_counter[key]

with outputk_path.open('w', encoding='utf-8') as f:
    json.dump(keywords_counter.most_common(), f, ensure_ascii=False, indent=4)

with outputo_path.open('w', encoding='utf-8') as f:
    json.dump(owner_counter.most_common(), f, ensure_ascii=False, indent=4)

with outputs_path.open('w', encoding='utf-8') as f:
    json.dump(sorted(substring_keywords_counter.items(), key=lambda x:x[1], reverse=True), f, ensure_ascii=False, indent=4)
