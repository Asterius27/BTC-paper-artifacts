import csv
from pathlib import Path

# Number of repos: 1408 (with 10 or more stars), of which 92 (6.53%) where filtered out

blacklist_terms = ["tutorial", "docs", "ctf", "test", "challenge", "demo", "example", "sample", "bootcamp", "assignment", "workshop", "homework", "course", "exercise", "hackathon"]
blacklist_term_groups = [["learn", "python"], ["learn", "flask"]]
blacklist_users = ["PacktPublishing", "rithmschool", "UCLComputerScience", "easyctf"]
path = Path(__file__).parent / '../flask_login_merged_list.csv'
filtered_repos = 0
number_of_repos = 0

with path.open() as csv_file:
    reader = csv.DictReader(csv_file)

    for row in reader:
        if int(row["stars"]) >= 1:
            number_of_repos += 1
            repo = row["repo_url"].split("/")[4]
            owner = row["repo_url"].split("/")[3]
            if any(user == owner for user in blacklist_users):
                # print(owner + " " + repo)
                filtered_repos += 1
            else:
                if any(term in repo for term in blacklist_terms):
                    filtered_repos += 1
                else:
                    if any(all(term in repo for term in groups) for groups in blacklist_term_groups):
                        # print(repo)
                        filtered_repos += 1

print("Number of repos: " + str(number_of_repos))
print("Of which " + str(filtered_repos) + " (" + str(round(filtered_repos * 100 / number_of_repos, 2)) + "%) where filtered out")
