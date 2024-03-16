import csv
import sys
from pathlib import Path

# Number of repos: 1408 (with 10 or more stars), of which 92 (6.53%) where filtered out

blacklist_terms = ["tutorial", "docs", "ctf", "test", "challenge", "demo", "example", "sample", "bootcamp", "assignment", "workshop", "homework", "course", "exercise", "hack", "vulnerable", "snippet", "internship", "programming", "flask", "book", "python", "django"] # "esercizi"
# blacklist_term_groups = [["learn", "python"], ["learn", "flask"], ["learn", "django"], ["youtube", "code"], ["python", "code"], ["python", "100", "days"]]
# blacklist_users = ["PacktPublishing", "rithmschool", "UCLComputerScience", "easyctf", "JustDoPython"]
path = Path(__file__).parent / '../django_contrib_auth_w_lang_and_readme.csv'
path_o = Path(__file__).parent / '../django_final_filtered_list_w_lang_and_readme_and_desc.csv'
log_path = Path(__file__).parent / './filter_logs/django_final_filtered_list_w_lang_and_readme_and_desc.txt'
filtered_repos = 0
number_of_repos = 0

maxInt = sys.maxsize
while True:
    # decrease the maxInt value by factor 10 
    # as long as the OverflowError occurs.
    try:
        csv.field_size_limit(maxInt)
        break
    except OverflowError:
        maxInt = int(maxInt/10)

with path.open(encoding="utf8") as csv_file:
    reader = csv.DictReader(csv_file)
    with path_o.open("w", newline='', encoding="utf8") as csv_filtered:
        writer = csv.writer(csv_filtered)
        writer.writerow(["repo_name", "repo_url", "stars", "contributors", "commits", "update_date", "forks", "jsonb_agg_lang", "jsonb_agg_readme", "description"])
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
