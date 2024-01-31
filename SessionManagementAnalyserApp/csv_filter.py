import csv
from pathlib import Path

# Number of repos: 1408 (with 10 or more stars), of which 92 (6.53%) where filtered out

blacklist_terms = ["tutorial", "docs", "ctf", "test", "challenge", "demo", "example", "sample", "bootcamp", "assignment", "workshop", "homework", "course", "exercise", "hack", "vulnerable", "snippet", "esercizi", "internship", "programming"]
blacklist_term_groups = [["learn", "python"], ["learn", "flask"], ["learn", "django"], ["youtube", "code"], ["python", "code"], ["python", "100", "days"]]
blacklist_users = ["PacktPublishing", "rithmschool", "UCLComputerScience", "easyctf", "JustDoPython"]
path = Path(__file__).parent / '../django_contrib_auth-1aa45639-2a2e-4f15-97de-31307ec0d221.csv'
path_o = Path(__file__).parent / '../django_filtered_list_final_v2.csv'
log_path = Path(__file__).parent / './filter_logs/django_filtered_list_final_v2.txt'
filtered_repos = 0
number_of_repos = 0

with path.open() as csv_file:
    reader = csv.DictReader(csv_file)
    with path_o.open("w", newline='') as csv_filtered:
        writer = csv.writer(csv_filtered)
        writer.writerow(["repo_name", "repo_url", "stars", "contributors", "commits", "update_date", "forks"])
        for row in reader:
            if int(row["stars"]) >= 1:
                number_of_repos += 1
                repo = row["repo_url"].split("/")[4].lower()
                owner = row["repo_url"].split("/")[3].lower()
                if any(user.lower() == owner for user in blacklist_users):
                    # print(owner + " " + repo)
                    filtered_repos += 1
                else:
                    if any(term.lower() in repo for term in blacklist_terms):
                        # print(repo)
                        filtered_repos += 1
                    else:
                        if any(all(term.lower() in repo for term in groups) for groups in blacklist_term_groups):
                            # print(repo)
                            filtered_repos += 1
                        else:
                            writer.writerow(list(row.values()))

print("Number of repos: " + str(number_of_repos))
print("Of which " + str(filtered_repos) + " (" + str(round(filtered_repos * 100 / number_of_repos, 2)) + "%) where filtered out")
with log_path.open("a") as file:
    file.write("Number of repos: " + str(number_of_repos) + "\n")
    file.write("Of which " + str(filtered_repos) + " (" + str(round(filtered_repos * 100 / number_of_repos, 2)) + "%) where filtered out\n")
