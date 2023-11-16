import statistics
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

path = Path(__file__).parent / './log.txt'
times = []
unsupported_library = 0
analysis_timedout = 0
database_deletion_error = 0
total_repos = ""

with path.open() as file:
    for line in file:
        if line.startswith("Time taken to run the queries on "):
            times.append(float(line.split(" ")[-2]))
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
