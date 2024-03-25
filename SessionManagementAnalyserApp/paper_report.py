from pathlib import Path
import os
import csv

def loadCSV(csvFile):
    repos = {}
    with csvFile.open(encoding="utf8") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            repo = row["repo_url"].split("/")[4]
            owner = row["repo_url"].split("/")[3]
            repos[owner + "_" + repo] = row["repo_url"]
    return repos

def extractResults(reposDir, queryDir, queryName, result, csvDict):
    output_results = {}
    path = Path(__file__).parent / './repositories'
    repos = os.listdir(str(path.absolute()) + "/" + reposDir)
    for repo in repos:
        if os.path.isdir(os.path.join(str(path.absolute()) + "/" + reposDir, repo)):
            dirs = os.listdir(str(path.absolute()) + "/" + reposDir + "/" + repo)
            for dir in dirs:
                if os.path.isdir(os.path.join(str(path.absolute()) + "/" + reposDir + "/" + repo, dir)) and dir.endswith("-results"):
                    queryFile = str(path.absolute()) + "/" + reposDir + "/" + repo + "/" + dir + "/" + queryDir + "/" + queryName + ".txt"
                    if os.path.isfile(queryFile):
                        with open(queryFile, "r") as output:
                            if len(output.readlines()) <= 2 and not result:
                                output.seek(0)
                                output_results[repo] = {}
                                if repo in csvDict:
                                    output_results[repo]["url"] = csvDict[repo]
                                output_results[repo]["file"] = queryFile
                                output_results[repo]["result"] = queryName + ":\n"
                                output_results[repo]["result"] += output.read()
                            output.seek(0)
                            if len(output.readlines()) > 2 and result:
                                output.seek(0)
                                output_results[repo] = {}
                                if repo in csvDict:
                                    output_results[repo]["url"] = csvDict[repo]
                                output_results[repo]["file"] = queryFile
                                output_results[repo]["result"] = queryName + ":\n"
                                output_results[repo]["result"] += output.read()
    return output_results

def buildResultsDict(resultRepos, subDicts):
    result = {}
    for key in resultRepos:
        flag = False
        for resultDict in subDicts:
            if key in resultDict:
                if not flag:
                    flag = True
                    result[key] = {}
                    if "url" in resultDict:
                        result[key]["url"] = resultDict[key]["url"]
                    result[key]["file"] = resultDict[key]["file"]
                    result[key]["result"] = resultDict[key]["result"]
                else:
                    result[key]["result"] += resultDict[key]["result"]
    return result

def saveDictsToFile(fileNames, dicts):
    for i, dct in enumerate(dicts):
        with open(fileNames[i] + '.txt', 'w', encoding='UTF8') as file:
            for key in dct:
                if "url" in dct[key]:
                    file.write("URL: " + str(dct[key]["url"]) + "\n")
                file.write("FILE: " + str(dct[key]["file"]) + "\n")
                file.write(str(dct[key]["result"]) + "\n\n")

def getPercentage(value, total):
    if total == 0:
        return 0
    return (value / total) * 100

# TODO remove potential false positives from results (using the results of the corresponding query)

csv_dict = loadCSV(Path(__file__).parent / '../old_lists_with_whitelist_filtering/flask_login_final_whitelist_filtered_merged_list.csv')
flask_login_usage = extractResults("Flask", ".", "flask_library_used_check", True, csv_dict)
flask_login_required_usage = extractResults("Flask", "Login-restrictions", "un_no_authentication_checks_general", False, csv_dict)
session_protection_none = extractResults("Flask", "Flask-login-session-protection", "sf_session_protection", True, csv_dict)
no_fresh_login = extractResults("Flask", "Flask-login-session-protection", "uf_session_protection_basic", True, csv_dict)
session_protection_strong = extractResults("Flask", "Flask-login-session-protection", "sf_session_protection_strong", True, csv_dict)
keys1 = set(flask_login_usage)
keys2 = set(flask_login_required_usage)
keys3 = set(session_protection_none)
keys4 = set(no_fresh_login)
keys5 = set(session_protection_strong)
repos = keys1.intersection(keys2)
temp = keys3.union(keys4)
tempp = keys5.union(temp)
no_session_protection = repos.intersection(temp)
session_protection_basic = repos.difference(tempp)
session_protection_strong_set = repos.intersection(keys5)
# intersect = keys1.intersection(keys2)
# results = buildResultsDict(union, [resultDict1, resultDict2, resultDict3])
counter_flask = len(repos)
counter_no_session_protection = len(no_session_protection)
counter_session_protection_basic = len(session_protection_basic)
counter_session_protection_strong = len(session_protection_strong_set)
# TODO test the following
# saveDictsToFile(["no_session_protection"], [no_session_protection]) # TODO extract links from sets
report = """
<p>There were {} flask repos, of which {} didn't use session protection ({} %), {} used basic session protection ({} %) and {} used strong sessoin protection ({} %)</p>
"""
report_html = report.format(str(counter_flask), str(counter_no_session_protection), str(getPercentage(counter_no_session_protection, counter_flask)), 
                            str(counter_session_protection_basic), str(getPercentage(counter_session_protection_basic, counter_flask)), 
                            str(counter_session_protection_strong), str(getPercentage(counter_session_protection_strong, counter_flask)))
with open("report.html", "w") as file:
    file.write(report_html)
