import statistics
import csv
import os
from pathlib import Path
import sys

# TODO add number of failures (and reasons) per query type
path = Path(__file__).parent / './old_logs/27 - log_repos_flask_login_whitelist_filtered_list'
output = Path(__file__).parent / './old_logs/27 - log_repos_flask_login_whitelist_filtered_list/log_analysis_merged.txt'
csv_path = Path(__file__).parent / '../flask_login_final_filtered_merged_list_w_lang_and_readme_and_desc.csv'
times = []
thread_times = []
failed_repos = []
failed_queries = []
csv_dict = {}
query_dict = {}
unsupported_library = 0
query_timeouts = 0
query_command_failed = 0
database_timeouts = 0
analysis_buffer_error = 0
database_deletion_error = 0

maxInt = sys.maxsize
while True:
    # decrease the maxInt value by factor 10 
    # as long as the OverflowError occurs.
    try:
        csv.field_size_limit(maxInt)
        break
    except OverflowError:
        maxInt = int(maxInt/10)

with csv_path.open() as csv_file:
    reader = csv.DictReader(csv_file)
    for row in reader:
        repo = row["repo_url"].split("/")[4]
        owner = row["repo_url"].split("/")[3]
        csv_dict[owner + "_" + repo] = int(row["stars"])

log_dir = os.listdir(path.absolute())
for file_name in log_dir:
    if file_name.endswith("_queries.txt"):
        with open(str(path.absolute()) + "/" + file_name, encoding="utf-8") as file:
            for line in file:
                try:
                    # query_dir = line.split(" ")[6]
                    query_name = line.split(" ")[8]
                    time_elapsed = line.split(" ")[10]
                    if query_name in query_dict:
                        query_dict[query_name].append(float(time_elapsed))
                    else:
                        query_dict[query_name] = []
                        query_dict[query_name].append(float(time_elapsed))
                except:
                    print("Could not read line...")
    if len(file_name.split("_")) == 1:
        # print(file_name)
        with open(str(path.absolute()) + "/" + file_name, encoding="utf-8") as file:
            for line in file:
                try:
                    if line.startswith("Failed to execute the query: "):
                        item = []
                        if line.endswith("ETIMEDOUT\n"):
                            item.append(line.split(" ")[5])
                            item.append("Repo: " + line.split(" ")[8])
                            item.append("Reason: Timedout")
                            query_timeouts += 1
                        if "Error: Command failed:" in line:
                            item.append(line.split(" ")[5])
                            item.append("Repo: " + line.split(" ")[8])
                            item.append("Reason: Command failed")
                            query_command_failed += 1
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
                            database_timeouts += 1
                        if line.endswith("ENOBUFS\n"):
                            item.append("Stars: " + str(csv_dict[line.split(" ")[3].split("/")[4]]))
                            item.append(line.split(" ")[3])
                            item.append("Reason: Filled up buffer space")
                            analysis_buffer_error += 1
                        if not line.endswith("ENOBUFS\n") and not line.endswith("ETIMEDOUT\n"):
                            item.append("Stars: " + str(csv_dict[line.split(" ")[3].split("/")[4]]))
                            item.append(line.split(" ")[3])
                            item.append("Reason: Repo doesn't use the login function from the flask login library or the built in django auth system")
                        failed_repos.append(item)
                    if line == "Error: None of the supported libraries/frameworks is used\n":
                        unsupported_library += 1
                    if line.startswith("Could not delete database for: "):
                        database_deletion_error += 1
                except:
                    print("Could not read line...")

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
    file.write("\n\n")
    for query in query_dict:
        try:
            file.write("The " + query + " 's execution times had an average of " + str(round(statistics.fmean(query_dict[query]), 2)) + " seconds and a standard deviation of " + str(round(statistics.stdev(query_dict[query]), 2)) + " seconds\n")
        except Exception:
            file.write("The " + query + " 's execution times had an average of " + str(round(statistics.fmean(query_dict[query]), 2)) + " seconds\n")
    file.write("\n\n")
    file.write("\nNumber of processed repos: " + str(len(times)) + "\n")
    file.write("Average time taken per thread: " + str(round(statistics.fmean(thread_times) / 3600.0, 2)) + " hours\n")
    file.write("Standard Deviation: " + str(round(statistics.stdev(thread_times) / 3600.0, 2)) + " hours\n")
    file.write("Average time taken per repository: " + str(round(statistics.fmean(times) / 60.0, 2)) + " minutes\n")
    file.write("Standard Deviation: " + str(round(statistics.stdev(times) / 60.0, 2)) + " minutes\n")
    file.write("Total false positives (not actually using flask_login): " + str(unsupported_library) + " (" + str(round(unsupported_library * 100 / len(times), 2)) + " %)\n")
    file.write("Total query errors because of timeouts: " + str(query_timeouts) + " (" + str(round(query_timeouts * 100 / (len(times) * len(query_dict)), 2)) + " %)\n")
    file.write("Total query errors because the command failed: " + str(query_command_failed) + " (" + str(round(query_command_failed * 100 / (len(times) * len(query_dict)), 2)) + " %)\n")
    file.write("Total analysis errors because of database creation timeouts: " + str(database_timeouts) + " (" + str(round(database_timeouts * 100 / len(times), 2)) + " %)\n")
    file.write("Total analysis errors because of buffer errors: " + str(analysis_buffer_error) + " (" + str(round(analysis_buffer_error * 100 / len(times), 2)) + " %)\n")
    file.write("Total repos where the database could not be deleted: " + str(database_deletion_error) + " (" + str(round(database_deletion_error * 100 / len(times), 2)) + " %)\n")
