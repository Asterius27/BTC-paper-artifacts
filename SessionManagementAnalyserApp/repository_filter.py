import nltk
import csv
import re
import json
from nltk.corpus import stopwords
from pathlib import Path
from collections import Counter

# nltk.download('stopwords')
path = Path(__file__).parent / '../flask_login_list.csv'
outputk_path = Path(__file__).parent / './most_common_repo_keywords.json'
outputo_path = Path(__file__).parent / './most_common_users.json'
with path.open() as csv_file:
    reader = csv.DictReader(csv_file)
    owner_counter = Counter()
    keywords_counter = Counter()

    for row in reader:
        owner = row["repo_url"].split("/")[3]
        keywords = [x.lower() for x in re.split('-|_', row["repo_url"].split("/")[4])]
        filtered_keywords = list(filter(lambda str: str not in stopwords.words('english'), keywords))
        owner_counter.update([owner])
        keywords_counter.update(filtered_keywords)
        
with outputk_path.open('w', encoding='utf-8') as f:
    json.dump(keywords_counter.most_common(), f, ensure_ascii=False, indent=4)

with outputo_path.open('w', encoding='utf-8') as f:
    json.dump(owner_counter.most_common(), f, ensure_ascii=False, indent=4)
