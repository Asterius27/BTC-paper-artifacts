import csv
import sys
from pathlib import Path

blacklist_terms = ["tutorial", "docs", "ctf", "test", "challenge", "demo", "example", "sample", "bootcamp", "assignment", "workshop", "homework", "course", "exercise", "hack", "vulnerable", "snippet", "internship", "programming", "flask", "book", "python", "django", "cybersecurity", "100daysofcode", "vulnerability", "vulnerabilities"] # "esercizi"
# blacklist_term_groups = [["learn", "python"], ["learn", "flask"], ["learn", "django"], ["youtube", "code"], ["python", "code"], ["python", "100", "days"]]
# blacklist_users = ["PacktPublishing", "rithmschool", "UCLComputerScience", "easyctf", "JustDoPython"]
path = Path(__file__).parent / '../flask_q2.csv'
path_o = Path(__file__).parent / '../flask_q2_filtered.csv'
log_path = Path(__file__).parent / './filter_logs/flask_q2_filtered.txt'
filtered_repos = 0
number_of_repos = 0

maxInt = sys.maxsize
while True:
    try:
        csv.field_size_limit(maxInt)
        break
    except OverflowError:
        maxInt = int(maxInt/10)

with path.open(encoding="utf8") as csv_file:
    reader = csv.DictReader(csv_file)
    with path_o.open("w", newline='', encoding="utf8") as csv_filtered:
        writer = csv.writer(csv_filtered)
        writer.writerow(["repo_name", "repo_url", "stars", "contributors", "commits", "last_commit_date", "forks", "jsonb_agg_lang", "homepage", "desc_url", "last_committer", "homepage_status", "desc_url_status", "python", "html", "css", "readme", "description", "readme_j"])
        # writer.writerow(["repo_name", "repo_url", "stars", "contributors", "commits", "last_commit_date", "forks", "jsonb_agg_lang", "homepage", "desc_url", "last_committer", "homepage_status", "desc_url_status", "css", "python", "html", "description", "readme", "readme_j"])
        for row in reader:
            if int(row["stars"]) >= 1:
                number_of_repos += 1
                repo = row["repo_url"].split("/")[4].lower()
                owner = row["repo_url"].split("/")[3].lower()
                """
                if any(user.lower() == owner for user in blacklist_users):
                    # print(owner + " " + repo)
                    filtered_repos += 1
                else:
                """
                if any(term.lower() in repo for term in blacklist_terms):
                    # print(repo)
                    filtered_repos += 1
                else:
                    """
                    if any(all(term.lower() in repo for term in groups) for groups in blacklist_term_groups):
                        # print(repo)
                        filtered_repos += 1
                    else:
                    """
                    writer.writerow(list(row.values()))

print("Number of repos: " + str(number_of_repos))
print("Of which " + str(filtered_repos) + " (" + str(round(filtered_repos * 100 / number_of_repos, 2)) + "%) where filtered out")
with log_path.open("a") as file:
    file.write("Number of repos: " + str(number_of_repos) + "\n")
    file.write("Of which " + str(filtered_repos) + " (" + str(round(filtered_repos * 100 / number_of_repos, 2)) + "%) where filtered out\n")
