import statistics
import csv
import os
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

# TODO add number of failures (and reasons) per query type
path = Path(__file__).parent / './old_logs/7 - log_1_or_more_stars_flask_login_merged'
output = Path(__file__).parent / './old_logs/7 - log_1_or_more_stars_flask_login_merged/log_analysis_merged.txt'
csv_path = Path(__file__).parent / '../flask_login_merged_list.csv'
times = []
thread_times = []
failed_repos = []
failed_queries = []
csv_dict = {}
query_dict = {}
unsupported_library = 0
analysis_timedout = 0
database_deletion_error = 0

with csv_path.open() as csv_file:
    reader = csv.DictReader(csv_file)
    for row in reader:
        repo = row["repo_url"].split("/")[4]
        owner = row["repo_url"].split("/")[3]
        csv_dict[owner + "_" + repo] = int(row["stars"])

log_dir = os.listdir(path.absolute())
for file_name in log_dir:
    if file_name.endswith("_queries.txt"):
        with open(str(path.absolute()) + "/" + file_name) as file:
            for line in file:
                # query_dir = line.split(" ")[6]
                query_name = line.split(" ")[8]
                time_elapsed = line.split(" ")[10]
                if query_name in query_dict:
                    query_dict[query_name].append(float(time_elapsed))
                else:
                    query_dict[query_name] = []
    if len(file_name.split("_")) == 1:
        # print(file_name)
        with open(str(path.absolute()) + "/" + file_name) as file:
            for line in file:
                if line.startswith("Failed to execute the query: "):
                    item = []
                    if line.endswith("ETIMEDOUT\n"):
                        item.append(line.split(" ")[5])
                        item.append("Repo: " + line.split(" ")[8])
                        item.append("Reason: Timedout")
                    if "Error: Command failed:" in line:
                        item.append(line.split(" ")[5])
                        item.append("Repo: " + line.split(" ")[8])
                        item.append("Reason: Command failed")
                    failed_queries.append(item)
                if line.startswith("Time taken to run the queries and generate the statistics: "):
                    thread_times.append(float(line.split(" ")[-2]))
                if line.startswith("Time taken to run the queries on "):
                    times.append(float(line.split(" ")[-2]))
                if line.startswith("Analysis failed for: "):
                    item = []
                    if line.endswith("ETIMEDOUT\n"):
                        item.append("Stars: " + str(csv_dict[line.split(" ")[3].split("/")[4]]))
                        item.append(line.split(" ")[3])
                        item.append("Reason: Timedout")
                    if line.endswith("ENOBUFS\n"):
                        item.append("Stars: " + str(csv_dict[line.split(" ")[3].split("/")[4]]))
                        item.append(line.split(" ")[3])
                        item.append("Reason: Filled up buffer space")
                    if not line.endswith("ENOBUFS\n") and not line.endswith("ETIMEDOUT\n"):
                        item.append("Stars: " + str(csv_dict[line.split(" ")[3].split("/")[4]]))
                        item.append(line.split(" ")[3])
                        item.append("Reason: Repo doesn't use the login function from the flask login library")
                    failed_repos.append(item)
                if line == "Error: None of the supported libraries/frameworks is used\n":
                    unsupported_library += 1
                if line.endswith("ETIMEDOUT\n"):
                    analysis_timedout += 1
                if line.startswith("Could not delete database for: "):
                    database_deletion_error += 1

"""
print(len(times))
print("Total time taken: " + str(round(sum(times) / 3600.0, 2)) + " hours")
print("On average: " + str(round(statistics.fmean(times) / 60.0, 2)) + " minutes per repository")
print("Standard Deviation: " + str(round(statistics.stdev(times) / 60.0, 2)) + " minutes")
print("Total false positives (not actually using flask_login): " + str(unsupported_library) + " (" + str(round(unsupported_library * 100 / len(times), 2)) + " %)")
print("Total repos that timed out: " + str(analysis_timedout) + " (" + str(round(analysis_timedout * 100 / len(times), 2)) + " %)")
print("Total repos where the database could not be deleted: " + str(database_deletion_error) + " (" + str(round(database_deletion_error * 100 / len(times), 2)) + " %)")
"""

with output.open("a") as file:
    for item in failed_repos:
        file.write(item[0] + ", Failed Repo: " + item[1] + " " + item[2] + "\n")
    file.write("\n\n")
    for item in failed_queries:
        file.write("Failed Query: " + item[0] + " " + item[1] + " " + item[2] + "\n")
    file.write("\nNumber of processed repos: " + str(len(times)) + "\n")
    file.write("Average time taken per thread: " + str(round(statistics.fmean(thread_times) / 3600.0, 2)) + " hours\n")
    file.write("Standard Deviation: " + str(round(statistics.stdev(thread_times) / 3600.0, 2)) + " hours\n")
    file.write("Average time taken per repository: " + str(round(statistics.fmean(times) / 60.0, 2)) + " minutes\n")
    file.write("Standard Deviation: " + str(round(statistics.stdev(times) / 60.0, 2)) + " minutes\n")
    file.write("Total false positives (not actually using flask_login): " + str(unsupported_library) + " (" + str(round(unsupported_library * 100 / len(times), 2)) + " %)\n")
    file.write("Total timeouts (either database creation or query execution): " + str(analysis_timedout) + " (" + str(round(analysis_timedout * 100 / len(times), 2)) + " %)\n")
    file.write("Total repos where the database could not be deleted: " + str(database_deletion_error) + " (" + str(round(database_deletion_error * 100 / len(times), 2)) + " %)\n")
    file.write("\n\n")
    for query in query_dict:
        file.write("The " + query + " 's execution times had an average of " + str(round(statistics.fmean(query_dict[query]), 2)) + " seconds and a standard deviation of " + str(round(statistics.stdev(query_dict[query]), 2)) + " seconds\n")
