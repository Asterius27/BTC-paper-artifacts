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

csv_dict = loadCSV(Path(__file__).parent / '../flask_login_final_whitelist_filtered_merged_list.csv')
flask_login_usage = extractResults("Flask", ".", "flask_library_used_check", True, csv_dict)
bcrypt_usage = extractResults("Flask", "Password-hashing", "un_bcrypt_is_used", True, csv_dict)
bcrypt_owasp_compliant = extractResults("Flask", "Password-hashing", "un_bcrypt_is_owasp_compliant", True, csv_dict)
keys1 = set(flask_login_usage)
keys2 = set(bcrypt_usage)
keys3 = set(bcrypt_owasp_compliant)
# intersect = keys1.intersection(keys2)
# results = buildResultsDict(union, [resultDict1, resultDict2, resultDict3])
counter_flask = len(flask_login_usage)
counter_bcrypt = len(bcrypt_usage)
counter_bcrypt_owasp = len(bcrypt_owasp_compliant)
# TODO test the following
saveDictsToFile(["bcrypt_usages", "bcrypt_owasp_compliant_usages"], [bcrypt_usage, bcrypt_owasp_compliant])
report = """
<p>There were <a href="{}">{}</a> bcrypt usages ({} %)<br>
Among which <a href="{}">{}</a> bcrypt usages were compliant with owasp guidelines ({} %)</p>
"""
report_html = report.format("./bcrypt_usages.txt", str(counter_bcrypt), str(getPercentage(counter_bcrypt, counter_flask)), "./bcrypt_owasp_compliant_usages.txt", str(counter_bcrypt_owasp), str(getPercentage(counter_bcrypt_owasp, counter_bcrypt)))
with open("report.html", "w") as file:
    file.write(report_html)
