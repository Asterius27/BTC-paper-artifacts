import csv
from pathlib import Path

path1 = Path(__file__).parent / '../flask_list_final.csv'
path2 = Path(__file__).parent / '../flask_repos.csv'
lst = []
different_repos = 0

# TODO doesn't work, need to compare the two
with path2.open() as csv_file:
    reader = csv.DictReader(csv_file)
    for i, row in enumerate(reader, start=0):
        if i < 10000:
            lst.append(row["repo_url"])

with path1.open() as csv_final_file:
    final_reader = csv.DictReader(csv_final_file)
    for i, row in enumerate(final_reader, start=0):
        if row["repo_url"] not in lst and i < 1000:
            different_repos += 1

print("Number of different repos: " + str(different_repos))
