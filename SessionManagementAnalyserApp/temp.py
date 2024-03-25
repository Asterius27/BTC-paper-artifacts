import csv
from pathlib import Path

path1 = Path(__file__).parent / '../old_lists_with_whitelist_filtering/django_final_whitelist_filtered_list.csv'
path2 = Path(__file__).parent / '../old_lists_with_whitelist_filtering/django_final_whitelist_filtered_list_v2.csv'

def loadCSV(csvFile):
    repos = []
    with csvFile.open(encoding="utf8") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            repos.append(row["repo_url"])
    return set(repos)

old_list = loadCSV(path1)
new_list = loadCSV(path2)
print(len(old_list.intersection(new_list)))
print(len(new_list.difference(old_list)))
print(len(old_list.difference(new_list)))
