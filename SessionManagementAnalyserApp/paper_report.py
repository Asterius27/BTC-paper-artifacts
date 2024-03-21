from pathlib import Path
import os
import csv
import pprint

def loadCSV(csvFile):
    repos = {}
    with csvFile.open(encoding="utf8") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            repo = row["repo_url"].split("/")[4]
            owner = row["repo_url"].split("/")[3]
            repos[owner + "_" + repo] = row["repo_url"]
    return repos

def countRepos(reposDir, queryDir, queryName, result, csvDict):
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

def countReposAnd(reposDir, queries, results, csvDict):
    counter = 0
    output_results = ""
    path = Path(__file__).parent / './repositories'
    repos = os.listdir(str(path.absolute()) + "/" + reposDir)
    for repo in repos:
        if os.path.isdir(os.path.join(str(path.absolute()) + "/" + reposDir, repo)):
            dirs = os.listdir(str(path.absolute()) + "/" + reposDir + "/" + repo)
            for dir in dirs:
                if os.path.isdir(os.path.join(str(path.absolute()) + "/" + reposDir + "/" + repo, dir)) and dir.endswith("-results"):
                    flag = True
                    temp_output = ""
                    for i, query in enumerate(queries):
                        queryFile = str(path.absolute()) + "/" + reposDir + "/" + repo + "/" + dir + "/" + query + ".txt"
                        if os.path.isfile(queryFile):
                            with open(queryFile, "r") as output:
                                if len(output.readlines()) <= 2 and results[i]:
                                    flag = False
                                output.seek(0)
                                if len(output.readlines()) > 2 and not results[i]:
                                    flag = False
                                output.seek(0)
                                if flag:
                                    output.seek(0)
                                    temp_output += query.split("/")[1] + ":\n"
                                    temp_output += output.read()
                        else:
                            flag = False
                    if flag:
                        counter += 1
                        if repo in csvDict:
                            output_results += "URL: " + csvDict[repo] + "\n"
                        output_results += "File: " + queryFile + "\n"
                        output_results += temp_output + "\n\n"
    return counter, output_results

def countReposOr(reposDir, queries, results, csvDict):
    counter = 0
    output_results = ""
    path = Path(__file__).parent / './repositories'
    repos = os.listdir(str(path.absolute()) + "/" + reposDir)
    for repo in repos:
        if os.path.isdir(os.path.join(str(path.absolute()) + "/" + reposDir, repo)):
            dirs = os.listdir(str(path.absolute()) + "/" + reposDir + "/" + repo)
            for dir in dirs:
                if os.path.isdir(os.path.join(str(path.absolute()) + "/" + reposDir + "/" + repo, dir)) and dir.endswith("-results"):
                    flag = False
                    temp_output = ""
                    for i, query in enumerate(queries):
                        queryFile = str(path.absolute()) + "/" + reposDir + "/" + repo + "/" + dir + "/" + query + ".txt"
                        if os.path.isfile(queryFile):
                            with open(queryFile, "r") as output:
                                if len(output.readlines()) <= 2 and not results[i]:
                                    flag = True
                                    output.seek(0)
                                    temp_output += query.split("/")[1] + ":\n"
                                    temp_output += output.read()
                                if len(output.readlines()) > 2 and results[i]:
                                    flag = True
                                    output.seek(0)
                                    temp_output += query.split("/")[1] + ":\n"
                                    temp_output += output.read()
                    if flag:
                        counter += 1
                        if repo in csvDict:
                            output_results += "URL: " + csvDict[repo] + "\n"
                        output_results += "File: " + queryFile + "\n"
                        output_results += temp_output + "\n\n"
    return counter, output_results

def saveResults(resultRepos, subDicts):
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

csv_dict = loadCSV(Path(__file__).parent / '../flask_login_final_whitelist_filtered_merged_list.csv')
# counter, results = countReposAnd("Flask", ["Flask-secret-key/secret_key", "Cookie-name-prefixes/name_prefix_session_cookie"], [False, True], csv_dict)
# counter, results = countReposOr("Flask", ["Flask-secret-key/secret_key", "Cookie-name-prefixes/name_prefix_session_cookie"], [False, False], csv_dict)
resultDict1 = countRepos("Flask", "Flask-secret-key", "secret_key", False, csv_dict)
resultDict2 = countRepos("Flask", "Cookie-name-prefixes", "name_prefix_session_cookie", True, csv_dict)
keys1 = set(resultDict1)
keys2 = set(resultDict2)
intersect = keys1.union(keys2)
results = saveResults(intersect, [resultDict1, resultDict2])
pprint.pprint(results)
