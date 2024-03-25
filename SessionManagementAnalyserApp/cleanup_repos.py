from pathlib import Path
import csv
import os
import shutil
import sys

maxInt = sys.maxsize
while True:
    # decrease the maxInt value by factor 10 
    # as long as the OverflowError occurs.
    try:
        csv.field_size_limit(maxInt)
        break
    except OverflowError:
        maxInt = int(maxInt/10)

csv_path = Path(__file__).parent / '../new_lists/django_filtered.csv'
repos_path = Path(__file__).parent / './repositories/Django_READMEs'
repos = []
# temp = 0

with csv_path.open() as csv_file:
    reader = csv.DictReader(csv_file)
    for row in reader:
        repo = row["repo_url"].split("/")[4]
        owner = row["repo_url"].split("/")[3]
        repos.append(owner + "_" + repo)

repos_dir = os.listdir(repos_path.absolute())
for dir_name in repos_dir:
    if dir_name not in repos:
        # temp += 1
        print(str(repos_path.absolute()) + "/" + dir_name)
        shutil.rmtree(str(repos_path.absolute()) + "/" + dir_name)

# print(temp)
