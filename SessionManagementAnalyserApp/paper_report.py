from pathlib import Path
import os
import csv

path = Path(__file__).parent / './paper_report'

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

def extractFalsePositives(reposDir, queryDir, queryName, falsePositiveQuery, result, csvDict):
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
                                output_str = output.read()
                                if falsePositiveQuery in output_str:
                                    output_results[repo] = {}
                                    if repo in csvDict:
                                        output_results[repo]["url"] = csvDict[repo]
                                    output_results[repo]["file"] = queryFile
                                    output_results[repo]["result"] = queryName + ":\n"
                                    output_results[repo]["result"] += output_str
                            output.seek(0)
                            if len(output.readlines()) > 2 and result:
                                output.seek(0)
                                output_str = output.read()
                                if falsePositiveQuery in output_str:
                                    output_results[repo] = {}
                                    if repo in csvDict:
                                        output_results[repo]["url"] = csvDict[repo]
                                    output_results[repo]["file"] = queryFile
                                    output_results[repo]["result"] = queryName + ":\n"
                                    output_results[repo]["result"] += output_str
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

def saveDictsToFile(fileNames, sets, dicts):
    for i, set in enumerate(sets):
        with open(str(path.absolute()) + "/" + fileNames[i] + '.txt', 'w', encoding='UTF8') as file:
            for key in set:
                flag = False
                for dct in dicts[i]:
                    if key in dct:
                        if not flag:
                            if "url" in dct[key]:
                                file.write("URL: " + str(dct[key]["url"]) + "\n")
                            file.write("FILE: " + str(dct[key]["file"]) + "\n")
                            flag = True
                        file.write(str(dct[key]["result"]) + "\n")
                file.write("\n\n")

def getPercentage(value, total):
    if total == 0:
        return 0
    return round((value / total) * 100, 2)

csv_dict = loadCSV(Path(__file__).parent / '../flask_whitelist_filtered_v2.csv')
flask_login_usage = extractResults("Flask", ".", "flask_library_used_check", True, csv_dict)
flask_login_required_usage = extractResults("Flask", "Login-restrictions", "un_no_authentication_checks_general", False, csv_dict)
flask_custom_session_interface = extractResults("Flask", "Explorative-queries", "un_custom_session_interface", False, csv_dict)
flask_wtf_account_creation = extractResults("Flask", "Password-strength", "un_form_with_password_field_is_signup", True, csv_dict)
session_protection_potential_false_positives = extractFalsePositives("Flask", "Explorative-queries", "un_potential_false_positives", "sf_session_protection sf_session_protection_strong uf_session_protection_basic ", True, csv_dict)
session_protection_none = extractResults("Flask", "Flask-login-session-protection", "sf_session_protection", True, csv_dict)
no_fresh_login = extractResults("Flask", "Flask-login-session-protection", "uf_session_protection_basic", True, csv_dict)
session_protection_strong = extractResults("Flask", "Flask-login-session-protection", "sf_session_protection_strong", True, csv_dict)
hardcoded_secret_key = extractResults("Flask", "Secret-key", "un_secret_key", True, csv_dict)
hardcoded_secret_key_potential_false_positives = extractFalsePositives("Flask", "Explorative-queries", "un_potential_false_positives", "un_secret_key ", True, csv_dict)
custom_password_validators = extractResults("Flask", "Password-strength", "un_password_custom_checks", True, csv_dict)
length_password_validators = extractResults("Flask", "Password-strength", "un_password_length_check", True, csv_dict)
regexp_password_validators = extractResults("Flask", "Password-strength", "un_password_regexp_check", True, csv_dict)
csrf_enabled_globally = extractResults("Flask", "CSRF", "un_using_flaskwtf_csrf_protection", True, csv_dict)
using_csrf_exempt = extractResults("Flask", "CSRF", "un_using_csrf_exempt", True, csv_dict)
using_csrf_protect = extractResults("Flask", "CSRF", "un_using_csrf_protect", True, csv_dict)
using_flaskform_csrf = extractResults("Flask", "CSRF", "un_using_flaskform", True, csv_dict)
disabled_flask_wtf_csrf_protection = extractResults("Flask", "CSRF", "un_disabled_wtf_csrf_check", True, csv_dict)
using_wtforms_csrf_protection = extractResults("Flask", "CSRF", "un_using_wtforms_csrf_protection", True, csv_dict)

keys_flask_login_usages = set(flask_login_usage)
keys_flask_login_required_usages = set(flask_login_required_usage)
keys_flask_custom_session_interface = set(flask_custom_session_interface)
repos = keys_flask_login_usages.intersection(keys_flask_login_required_usages).intersection(keys_flask_custom_session_interface)
keys_account_creation = set(flask_wtf_account_creation)

keys_session_protection_none = set(session_protection_none)
keys_no_fresh_login = set(no_fresh_login)
keys_session_protection_strong = set(session_protection_strong)
keys_session_protection_potential_false_positives = set(session_protection_potential_false_positives)
repos_session_protection = repos.difference(keys_session_protection_potential_false_positives)
not_using_session_protection = keys_session_protection_none.union(keys_no_fresh_login)
temp = keys_session_protection_strong.union(not_using_session_protection)
no_session_protection = repos_session_protection.intersection(not_using_session_protection)
session_protection_basic = repos_session_protection.difference(temp)
session_protection_strong_set = repos_session_protection.intersection(keys_session_protection_strong)

keys_hardcoded_secret_key = set(hardcoded_secret_key)
keys_hardcoded_secret_key_potential_false_positives = set(hardcoded_secret_key_potential_false_positives)
repos_hardcoded_secret_key = repos.difference(keys_hardcoded_secret_key_potential_false_positives)
hardcoded_secret_key_set = repos_hardcoded_secret_key.intersection(keys_hardcoded_secret_key)

keys_custom_password_validators = keys_account_creation.intersection(set(custom_password_validators))
keys_length_password_validators = keys_account_creation.intersection(set(length_password_validators))
keys_regexp_password_validators = keys_account_creation.intersection(set(regexp_password_validators))
length_and_regexp_password_validators = keys_account_creation.intersection(keys_length_password_validators.intersection(keys_regexp_password_validators))
performing_password_validation = keys_account_creation.intersection(keys_custom_password_validators.union(keys_length_password_validators).union(keys_regexp_password_validators))

keys_csrf_enabled_globally = set(csrf_enabled_globally)
keys_using_csrf_exempt = set(using_csrf_exempt)
keys_using_csrf_protect = set(using_csrf_protect)
keys_using_flaskform_csrf = set(using_flaskform_csrf)
keys_disabled_flask_wtf_csrf_protection = set(disabled_flask_wtf_csrf_protection)
keys_using_wtforms_csrf_protection = set(using_wtforms_csrf_protection)
csrf_protection_global = repos.intersection(keys_csrf_enabled_globally.difference(keys_using_csrf_exempt).difference(keys_disabled_flask_wtf_csrf_protection))
csrf_protection_global_selectively_disabled = repos.intersection(keys_using_csrf_exempt.union(keys_disabled_flask_wtf_csrf_protection))
csrf_protection_selectively_activated = repos.difference(csrf_protection_global).intersection(keys_using_flaskform_csrf.union(keys_using_csrf_protect).union(keys_using_wtforms_csrf_protection))
csrf_protection_disabled = repos.difference(keys_csrf_enabled_globally).difference(keys_using_flaskform_csrf.union(keys_using_wtforms_csrf_protection))

counter_flask = len(repos)
counter_account_creation = len(keys_account_creation)

counter_no_session_protection = len(no_session_protection)
counter_session_protection_basic = len(session_protection_basic)
counter_session_protection_strong = len(session_protection_strong_set)
counter_session_protection_false_positives = len(keys_session_protection_potential_false_positives)

counter_hardcoded_secret_keys = len(hardcoded_secret_key_set)
counter_hardcoded_secret_keys_false_positives = len(keys_hardcoded_secret_key_potential_false_positives)

counter_custom_password_validators = len(keys_custom_password_validators)
counter_length_password_validators = len(keys_length_password_validators)
counter_regexp_password_validators = len(keys_regexp_password_validators)
counter_length_and_regexp_password_validators = len(length_and_regexp_password_validators)
counter_performing_password_validation = len(performing_password_validation)

counter_csrf_activated = len(csrf_protection_global)
counter_csrf_deactivated_selectively = len(csrf_protection_global_selectively_disabled)
counter_csrf_activated_selectively = len(csrf_protection_selectively_activated)
counter_csrf_deactivated = len(csrf_protection_disabled)

saveDictsToFile(["session_management", "account_creation"], [repos, keys_account_creation], [[flask_login_usage], [flask_wtf_account_creation]])
saveDictsToFile(["no_session_protection", "session_protection_basic", "session_protection_strong", "potential_false_positives_session_protection"],
                [no_session_protection, session_protection_basic, session_protection_strong_set, keys_session_protection_potential_false_positives],
                [[session_protection_none, no_fresh_login], [flask_login_usage], [session_protection_strong], [session_protection_potential_false_positives]])
saveDictsToFile(["hardcoded_secret_keys", "potential_false_positives_hardcoded_secret_keys"],
                [hardcoded_secret_key_set, keys_hardcoded_secret_key_potential_false_positives],
                [[hardcoded_secret_key], [hardcoded_secret_key_potential_false_positives]])
saveDictsToFile(["custom_password_validators", "length_password_validators", "regexp_password_validators", "length_and_regexp_password_validators"],
                [keys_custom_password_validators, keys_length_password_validators, keys_regexp_password_validators, length_and_regexp_password_validators],
                [[custom_password_validators], [length_password_validators], [regexp_password_validators], [length_password_validators, regexp_password_validators]])
saveDictsToFile(["csrf_activated_globally", "csrf_deactivated_selectively", "csrf_activated_selectively", "csrf_deactivated_globally"],
                [csrf_protection_global, csrf_protection_global_selectively_disabled, csrf_protection_selectively_activated, csrf_protection_disabled],
                [[csrf_enabled_globally], [using_csrf_exempt, disabled_flask_wtf_csrf_protection], [using_flaskform_csrf, using_csrf_protect, using_wtforms_csrf_protection], [flask_login_usage]])

report = """
<p>There are <a href="{}" target="_blank">{}</a> flask repos for Session Management and <a href="{}" target="_blank">{}</a> flask repos for Account Creation<br></p>
<h2>Account Creation</h2>
<h3>Password Policies</h3>
<p>{} perform some validation on its password fields ({} %)<br>
<a href="{}" target="_blank">{}</a> enforce a minimum length ({} %)<br>
<a href="{}" target="_blank">{}</a> check the password against a regexp ({} %)<br>
<a href="{}" target="_blank">{}</a> combine length checks and regular expression checks ({} %)<br>
<a href="{}" target="_blank">{}</a> use a custom validator ({} %)<br></p>
<h3>Password Hashing</h3>
<p></p>
<h2>Session Management</h2>
<h3>Cryptographic Keys</h3>
<p><a href="{}" target="_blank">{}</a> had a hardcoded secret key ({} %)<br>
<a href="{}" target="_blank">{}</a> set the secret key more than once, so it's a false positive potentially ({} %)<br></p>
<h3>CSRF</h3>
<p><a href="{}" target="_blank">{}</a> CSRF protection is activated everywhere ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF protection is activated by default, but it is deactivated on some views ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF protection is deactivated by default, but it is activated on some views ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF protection is deactivated everywhere ({} %)<br></p>
<h3>Session Protection</h3>
<p><a href="{}" target="_blank">{}</a> didn't use session protection ({} %)<br>
<a href="{}" target="_blank">{}</a> used basic session protection ({} %)<br>
<a href="{}" target="_blank">{}</a> used strong session protection ({} %)<br>
<a href="{}" target="_blank">{}</a> set session protection more than once, so it's a false positive potentially ({} %)<br></p>
<h3>Logout Security</h3>
<p></p>
"""

report_html = report.format("./session_management.txt", str(counter_flask), "./account_creation.txt", str(counter_account_creation),
                            str(counter_performing_password_validation), str(getPercentage(counter_performing_password_validation, counter_account_creation)),
                            "./length_password_validators.txt", str(counter_length_password_validators), str(getPercentage(counter_length_password_validators, counter_account_creation)),
                            "./regexp_password_validators.txt", str(counter_regexp_password_validators), str(getPercentage(counter_regexp_password_validators, counter_account_creation)),
                            "./length_and_regexp_password_validators.txt", str(counter_length_and_regexp_password_validators), str(getPercentage(counter_length_and_regexp_password_validators, counter_account_creation)),
                            "./custom_password_validators.txt", str(counter_custom_password_validators), str(getPercentage(counter_custom_password_validators, counter_account_creation)),
                            "./hardcoded_secret_keys.txt", str(counter_hardcoded_secret_keys), str(getPercentage(counter_hardcoded_secret_keys, counter_flask)),
                            "./potential_false_positives_hardcoded_secret_keys.txt", str(counter_hardcoded_secret_keys_false_positives), str(getPercentage(counter_hardcoded_secret_keys_false_positives, counter_flask)), 
                            "./csrf_activated_globally.txt", str(counter_csrf_activated), str(getPercentage(counter_csrf_activated, counter_flask)),
                            "./csrf_deactivated_selectively.txt", str(counter_csrf_deactivated_selectively), str(getPercentage(counter_csrf_deactivated_selectively, counter_flask)),
                            "./csrf_activated_selectively.txt", str(counter_csrf_activated_selectively), str(getPercentage(counter_csrf_activated_selectively, counter_flask)),
                            "./csrf_deactivated_globally.txt", str(counter_csrf_deactivated), str(getPercentage(counter_csrf_deactivated, counter_flask)),
                            "./no_session_protection.txt", str(counter_no_session_protection), str(getPercentage(counter_no_session_protection, counter_flask)),
                            "./session_protection_basic.txt", str(counter_session_protection_basic), str(getPercentage(counter_session_protection_basic, counter_flask)), 
                            "./session_protection_strong.txt", str(counter_session_protection_strong), str(getPercentage(counter_session_protection_strong, counter_flask)),
                            "./potential_false_positives_session_protection.txt", str(counter_session_protection_false_positives), str(getPercentage(counter_session_protection_false_positives, counter_flask)))
with open(str(path.absolute()) + "/report.html", "w") as file:
    file.write(report_html)
