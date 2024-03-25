import csv
from pathlib import Path
import sys
import random

maxInt = sys.maxsize
while True:
    # decrease the maxInt value by factor 10 
    # as long as the OverflowError occurs.
    try:
        csv.field_size_limit(maxInt)
        break
    except OverflowError:
        maxInt = int(maxInt/10)

path1 = Path(__file__).parent / '../flask.csv'

def loadCSV(csvFile):
    repos = []
    with csvFile.open(encoding="utf8") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            repos.append(row["repo_url"])
    return set(repos)

s = random.sample(loadCSV(path1), 50)

for e in s:
    print(e)
