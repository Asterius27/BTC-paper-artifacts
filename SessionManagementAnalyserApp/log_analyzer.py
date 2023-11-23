import statistics
import csv
from pathlib import Path

"""
Number of processed repos: 1408. Of which 60 were filtered out.
Total time taken: 177.17 hours
On average: 7.89 minutes per repository
Standard Deviation: 5.55 minutes

Total false positives (not actually using flask_login): 216 (16.04 %)
Total repos that timed out: 15 (1.11 %)
Total repos where the database could not be deleted: 12 (0.89 %)
"""

# TODO merge thread logs and analyse them
path = Path(__file__).parent / './old_logs/4 - log_10_to_12_stars_flask_login_merged.txt'
output = Path(__file__).parent / './old_logs/4 - log_analysis_10_to_12_stars_flask_login_merged.txt'
csv_path = Path(__file__).parent / '../flask_login_merged_list.csv'
times = []
failed_repos = []
csv_dict = {}
unsupported_library = 0
analysis_timedout = 0
database_deletion_error = 0
total_repos = ""

with csv_path.open() as csv_file:
    reader = csv.DictReader(csv_file)
    for row in reader:
        repo = row["repo_url"].split("/")[4]
        owner = row["repo_url"].split("/")[3]
        csv_dict[owner + "_" + repo] = int(row["stars"])

with path.open() as file:
    for line in file:
        if line.startswith("Time taken to run the queries on "):
            times.append(float(line.split(" ")[-2]))
        if line.startswith("Analysis failed for: "):
            item = []
            if line.endswith("ETIMEDOUT\n"):
                item.append("Stars: " + str(csv_dict[line.split(" ")[3].split("/")[3]]))
                item.append(line.split(" ")[3])
                item.append("Reason: Timedout")
            if line.endswith("ENOBUFS\n"):
                item.append("Stars: " + str(csv_dict[line.split(" ")[3].split("/")[3]]))
                item.append(line.split(" ")[3])
                item.append("Reason: Filled up buffer space")
            if not line.endswith("ENOBUFS\n") and not line.endswith("ETIMEDOUT\n"):
                item.append("Stars: " + str(csv_dict[line.split(" ")[3].split("/")[3]]))
                item.append(line.split(" ")[3])
                item.append("Reason: Repo doesn't use the login function from the flask login library")
            failed_repos.append(item)
        if line == "Error: None of the supported libraries/frameworks is used\n":
            unsupported_library += 1
        if line.endswith("ETIMEDOUT\n"):
            analysis_timedout += 1
        if line.startswith("Could not delete database for: "):
            database_deletion_error += 1
        if line.startswith("Number of processed repos: ") and line.endswith("were filtered out.\n"):
            total_repos = line

print(len(times))
print(total_repos[:-1])
print("Total time taken: " + str(round(sum(times) / 3600.0, 2)) + " hours")
print("On average: " + str(round(statistics.fmean(times) / 60.0, 2)) + " minutes per repository")
print("Standard Deviation: " + str(round(statistics.stdev(times) / 60.0, 2)) + " minutes")
print("Total false positives (not actually using flask_login): " + str(unsupported_library) + " (" + str(round(unsupported_library * 100 / len(times), 2)) + " %)")
print("Total repos that timed out: " + str(analysis_timedout) + " (" + str(round(analysis_timedout * 100 / len(times), 2)) + " %)")
print("Total repos where the database could not be deleted: " + str(database_deletion_error) + " (" + str(round(database_deletion_error * 100 / len(times), 2)) + " %)")

with output.open("w") as file:
    for item in failed_repos:
        file.write(item[0] + ", Failed Repo: " + item[1] + " " + item[2] + "\n")
    file.write("\n" + total_repos[:-1] + "\n")
    file.write("Total time taken: " + str(round(sum(times) / 3600.0, 2)) + " hours\n")
    file.write("On average: " + str(round(statistics.fmean(times) / 60.0, 2)) + " minutes per repository\n")
    file.write("Standard Deviation: " + str(round(statistics.stdev(times) / 60.0, 2)) + " minutes\n")
    file.write("Total false positives (not actually using flask_login): " + str(unsupported_library) + " (" + str(round(unsupported_library * 100 / len(times), 2)) + " %)\n")
    file.write("Total repos that timed out: " + str(analysis_timedout) + " (" + str(round(analysis_timedout * 100 / len(times), 2)) + " %)\n")
    file.write("Total repos where the database could not be deleted: " + str(database_deletion_error) + " (" + str(round(database_deletion_error * 100 / len(times), 2)) + " %)\n")
