from pathlib import Path
import os
import csv
import re

path = Path(__file__).parent / './paper_reports_flask/paper_report'
path.mkdir(exist_ok=True)

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

def extractValues(reposDir, queryDir, queryName, queryString, result):
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
                                if queryString in output_str:
                                    output_results[repo] = set()
                                    output_str_values = output_str.splitlines()
                                    for line in output_str_values:
                                        substrings = line.split(queryString)
                                        if len(substrings) > 1:
                                            output_results[repo].add(int(substrings[1].split(" ")[0]))
                            output.seek(0)
                            if len(output.readlines()) > 2 and result:
                                output.seek(0)
                                output_str = output.read()
                                if queryString in output_str:
                                    output_results[repo] = set()
                                    output_str_values = output_str.splitlines()
                                    for line in output_str_values:
                                        substrings = line.split(queryString)
                                        if len(substrings) > 1:
                                            output_results[repo].add(int(substrings[1].split(" ")[0]))
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

def saveDistributionsToFile(fileNames, sets, dicts, flags):
    for i, set in enumerate(sets):
        with open(str(path.absolute()) + "/" + fileNames[i] + '.txt', 'w', encoding='UTF8') as file:
            for key in set:
                for dct in dicts[i]:
                    if key in dct:
                        if flags[i]:
                            file.write(str(max(dct[key])) + ", ")
                        else:
                            file.write(str(min(dct[key])) + ", ")

def getPercentage(value, total):
    if total == 0:
        return 0
    return round((value / total) * 100, 2)

csv_dict = loadCSV(Path(__file__).parent / '../flask_whitelist_filtered_v2.csv')
flask_login_usage = extractResults("Flask", ".", "flask_library_used_check", True, csv_dict)
flask_login_required_usage = extractResults("Flask", "Login-restrictions", "un_no_authentication_checks_general", False, csv_dict)
flask_custom_session_interface = extractResults("Flask", "Explorative-queries", "un_custom_session_interface", False, csv_dict)
flask_wtf_account_creation = extractResults("Flask", "Password-strength", "un_form_with_password_field_is_signup", True, csv_dict)
session_protection_potential_false_positives = extractFalsePositives("Flask", "Explorative-queries", "un_potential_false_positives", "sf_session_protection sf_session_protection_strong uf_session_protection_basic un_session_protection_basic_is_used ", True, csv_dict)
session_protection_none = extractResults("Flask", "Flask-login-session-protection", "sf_session_protection", True, csv_dict)
no_fresh_login = extractResults("Flask", "Flask-login-session-protection", "uf_session_protection_basic", True, csv_dict)
session_protection_strong = extractResults("Flask", "Flask-login-session-protection", "sf_session_protection_strong", True, csv_dict)
session_protection_basic = extractResults("Flask", "Flask-login-session-protection", "un_session_protection_basic_is_used", True, csv_dict)
hardcoded_secret_key = extractResults("Flask", "Secret-key", "un_secret_key", True, csv_dict)
hardcoded_secret_key_potential_false_positives = extractFalsePositives("Flask", "Explorative-queries", "un_potential_false_positives", "un_secret_key ", True, csv_dict)
hardcoded_secret_key_too_short = extractFalsePositives("Flask", "Secret-key", "un_secret_key", " and it's too short", True, csv_dict)
custom_password_validators = extractResults("Flask", "Password-strength", "un_password_custom_checks", True, csv_dict)
length_password_validators = extractResults("Flask", "Password-strength", "un_password_length_check", True, csv_dict)
regexp_password_validators = extractResults("Flask", "Password-strength", "un_password_regexp_check", True, csv_dict)
signup_form_not_validated = extractResults("Flask", "Password-strength", "un_form_with_password_field_is_validated", True, csv_dict)
min_lengths_password_validation = extractValues("Flask", "Password-strength", "un_password_length_check", "min value: ", True)
max_lengths_password_validation = extractValues("Flask", "Password-strength", "un_password_length_check", "max value: ", True)
csrf_enabled_globally = extractResults("Flask", "CSRF", "un_using_flaskwtf_csrf_protection", True, csv_dict)
using_csrf_exempt = extractResults("Flask", "CSRF", "un_using_csrf_exempt", True, csv_dict)
using_csrf_protect = extractResults("Flask", "CSRF", "un_using_csrf_protect", True, csv_dict)
using_flaskform_csrf = extractResults("Flask", "CSRF", "un_using_flaskform", True, csv_dict)
using_flaskform_with_csrf_disabled = extractResults("Flask", "CSRF", "un_using_flaskform_with_csrf_disabled", True, csv_dict)
disabled_flask_wtf_csrf_protection = extractResults("Flask", "CSRF", "un_disabled_wtf_csrf_check", True, csv_dict)
disabled_flask_wtf_csrf_global_protection = extractResults("Flask", "CSRF", "un_disabled_wtf_csrf", True, csv_dict)
using_wtforms_csrf_protection = extractResults("Flask", "CSRF", "un_using_wtforms_csrf_protection", True, csv_dict)
using_flask_wtf = extractResults("Flask", "Password-strength", "un_flask_wtf_is_used", True, csv_dict)
using_wtforms = extractResults("Flask", "Password-strength", "un_wtforms_is_used", True, csv_dict)
argon2_is_used = extractResults("Flask", "Password-hashing", "un_argon2_is_used", True, csv_dict)
argon2_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_argon2_is_owasp_compliant", True, csv_dict)
bcrypt_is_used = extractResults("Flask", "Password-hashing", "un_bcrypt_is_used", True, csv_dict)
bcrypt_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_bcrypt_is_owasp_compliant", True, csv_dict)
flask_bcrypt_is_used = extractResults("Flask", "Password-hashing", "un_flask_bcrypt_is_used", True, csv_dict)
flask_bcrypt_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_flask_bcrypt_is_owasp_compliant", True, csv_dict)
flask_bcrypt_is_owasp_compliant_false_positives = extractFalsePositives("Flask", "Explorative-queries", "un_potential_false_positives", "un_flask_bcrypt_is_owasp_compliant ", True, csv_dict)
passlib_is_used = extractResults("Flask", "Password-hashing", "un_passlib_is_used", True, csv_dict)
passlib_argon2_is_used = extractResults("Flask", "Password-hashing", "un_passlib_argon2_is_used", True, csv_dict)
passlib_argon2_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_passlib_argon2_is_owasp_compliant", True, csv_dict)
passlib_bcrypt_is_used = extractResults("Flask", "Password-hashing", "un_passlib_bcrypt_is_used", True, csv_dict)
passlib_bcrypt_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_passlib_bcrypt_is_owasp_compliant", True, csv_dict)
passlib_pbkdf2_is_used = extractResults("Flask", "Password-hashing", "un_passlib_pbkdf2_is_used", True, csv_dict)
passlib_pbkdf2_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_passlib_pbkdf2_is_owasp_compliant", True, csv_dict)
passlib_scrypt_is_used = extractResults("Flask", "Password-hashing", "un_passlib_scrypt_is_used", True, csv_dict)
passlib_scrypt_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_passlib_scrypt_is_owasp_compliant", True, csv_dict)
werkzeug_is_used = extractResults("Flask", "Password-hashing", "un_werkzeug_is_used", True, csv_dict)
werkzeug_pbkdf2_is_used = extractResults("Flask", "Password-hashing", "un_werkzeug_pbkdf2_is_used", True, csv_dict)
werkzeug_pbkdf2_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_werkzeug_pbkdf2_is_owasp_compliant", True, csv_dict)
werkzeug_scrypt_is_used = extractResults("Flask", "Password-hashing", "un_werkzeug_scrypt_is_used", True, csv_dict)
werkzeug_scrypt_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_werkzeug_scrypt_is_owasp_compliant", True, csv_dict)
hashlib_is_used = extractResults("Flask", "Password-hashing", "un_hashlib_is_used", True, csv_dict)
hashlib_pbkdf2_is_used = extractResults("Flask", "Password-hashing", "un_hashlib_pbkdf2_is_used", True, csv_dict)
hashlib_pbkdf2_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_hashlib_pbkdf2_is_owasp_compliant", True, csv_dict)
hashlib_scrypt_is_used = extractResults("Flask", "Password-hashing", "un_hashlib_scrypt_is_used", True, csv_dict)
hashlib_scrypt_is_owasp_compliant = extractResults("Flask", "Password-hashing", "un_hashlib_scrypt_is_owasp_compliant", True, csv_dict)

keys_flask_login_usages = set(flask_login_usage)
keys_flask_login_required_usages = set(flask_login_required_usage)
keys_flask_custom_session_interface = set(flask_custom_session_interface)
repos = keys_flask_login_usages.intersection(keys_flask_login_required_usages).intersection(keys_flask_custom_session_interface)
keys_account_creation = set(flask_wtf_account_creation).intersection(keys_flask_login_required_usages).intersection(keys_flask_custom_session_interface)

keys_session_protection_none = set(session_protection_none)
keys_no_fresh_login = set(no_fresh_login)
keys_session_protection_strong = set(session_protection_strong)
keys_session_protection_basic = set(session_protection_basic)
keys_session_protection_potential_false_positives = set(session_protection_potential_false_positives)
repos_session_protection = repos.difference(keys_session_protection_potential_false_positives)
not_using_session_protection = keys_session_protection_none.union(keys_no_fresh_login)
temp = keys_session_protection_strong.union(not_using_session_protection)
no_session_protection = repos_session_protection.intersection(not_using_session_protection)
session_protection_basic_set = repos_session_protection.intersection(keys_session_protection_basic)
session_protection_strong_set = repos_session_protection.intersection(keys_session_protection_strong)
uncategorized_session_protection = repos_session_protection.difference(no_session_protection.union(session_protection_basic_set).union(session_protection_strong_set).union())

keys_hardcoded_secret_key = set(hardcoded_secret_key)
keys_hardcoded_secret_key_potential_false_positives = set(hardcoded_secret_key_potential_false_positives)
keys_hardcoded_secret_key_too_short = set(hardcoded_secret_key_too_short)
repos_hardcoded_secret_key = repos.intersection(keys_hardcoded_secret_key)
hardcoded_secret_key_false_positives = repos_hardcoded_secret_key.intersection(keys_hardcoded_secret_key_potential_false_positives)
hardcoded_secret_key_true_positives = repos_hardcoded_secret_key.difference(keys_hardcoded_secret_key_potential_false_positives)
hardcoded_secret_key_too_short_true_positives = hardcoded_secret_key_true_positives.intersection(keys_hardcoded_secret_key_too_short)

keys_custom_password_validators = keys_account_creation.intersection(set(custom_password_validators))
keys_length_password_validators = keys_account_creation.intersection(set(length_password_validators))
keys_regexp_password_validators = keys_account_creation.intersection(set(regexp_password_validators))
keys_signup_form_not_validated = keys_account_creation.intersection(set(signup_form_not_validated))
keys_min_length_password_validation = keys_account_creation.intersection(set(min_lengths_password_validation))
keys_max_length_password_validation = keys_account_creation.intersection(set(max_lengths_password_validation))
length_and_regexp_password_validators = keys_account_creation.intersection(keys_length_password_validators.intersection(keys_regexp_password_validators))
performing_password_validation = keys_account_creation.intersection(keys_custom_password_validators.union(keys_length_password_validators).union(keys_regexp_password_validators))
not_performing_password_validation = keys_account_creation.difference(performing_password_validation)
not_validating_password_fields_with_validators = performing_password_validation.intersection(keys_signup_form_not_validated)

keys_csrf_enabled_globally = set(csrf_enabled_globally)
keys_using_csrf_exempt = set(using_csrf_exempt)
keys_using_csrf_protect = set(using_csrf_protect)
keys_using_flaskform_csrf = set(using_flaskform_csrf)
keys_using_flaskform_with_csrf_disabled = set(using_flaskform_with_csrf_disabled)
keys_disabled_flask_wtf_csrf_protection = set(disabled_flask_wtf_csrf_protection)
keys_disabled_flask_wtf_csrf_global_protection = set(disabled_flask_wtf_csrf_global_protection)
keys_using_wtforms_csrf_protection = set(using_wtforms_csrf_protection)
keys_using_flask_wtf = repos.intersection(set(using_flask_wtf))
keys_using_wtforms = repos.intersection(set(using_wtforms))
repos_using_csrf_library = keys_using_flask_wtf.union(keys_using_wtforms).union(repos.intersection(keys_csrf_enabled_globally)).difference(keys_disabled_flask_wtf_csrf_global_protection)
repos_with_csrf_disabled = keys_using_flask_wtf.union(keys_using_wtforms).union(repos.intersection(keys_csrf_enabled_globally)).intersection(keys_disabled_flask_wtf_csrf_global_protection)
csrf_protection_global = repos_using_csrf_library.intersection(keys_csrf_enabled_globally.difference(keys_using_csrf_exempt).difference(keys_disabled_flask_wtf_csrf_protection))
csrf_protection_global_selectively_disabled = repos_using_csrf_library.intersection(keys_csrf_enabled_globally).intersection(keys_using_csrf_exempt.union(keys_disabled_flask_wtf_csrf_protection))
csrf_protection_selectively_disabled = repos_using_csrf_library.intersection(keys_using_flaskform_with_csrf_disabled).difference(keys_csrf_enabled_globally.difference(keys_disabled_flask_wtf_csrf_protection))
csrf_protection_selectively_activated = repos_using_csrf_library.difference(keys_disabled_flask_wtf_csrf_global_protection).difference(keys_csrf_enabled_globally.difference(keys_disabled_flask_wtf_csrf_protection)).difference(keys_using_flaskform_with_csrf_disabled).intersection(keys_using_flaskform_csrf.union(keys_using_csrf_protect).union(keys_using_wtforms_csrf_protection))
csrf_protection_disabled = repos_using_csrf_library.difference(keys_csrf_enabled_globally).difference(keys_using_flaskform_csrf.union(keys_using_wtforms_csrf_protection).union(keys_using_csrf_protect)).union(repos_using_csrf_library.intersection(keys_disabled_flask_wtf_csrf_global_protection))
not_using_csrf_library = repos.difference(repos_using_csrf_library).difference(repos_with_csrf_disabled)

""" csrf_categories_union = csrf_protection_global.union(csrf_protection_global_selectively_disabled).union(csrf_protection_selectively_activated).union(csrf_protection_disabled).union(csrf_protection_selectively_disabled)
not_in_any_csrf_category = repos_using_csrf_library.difference(csrf_protection_global).difference(csrf_protection_global_selectively_disabled).difference(csrf_protection_selectively_activated).difference(csrf_protection_disabled).difference(csrf_protection_selectively_disabled)
all_elements = list(csrf_protection_global) + list(csrf_protection_global_selectively_disabled) + list(csrf_protection_selectively_activated) + list(csrf_protection_disabled) + list(csrf_protection_selectively_disabled)
repos_in_more_than_one_category = set()
unique_elements = set()
for element in csrf_categories_union:
    if element in unique_elements:
        repos_in_more_than_one_category.add(element)
    else:
        unique_elements.add(element) """

keys_argon2_is_used = keys_account_creation.intersection(set(argon2_is_used).union(set(passlib_argon2_is_used)))
keys_bcrypt_is_used = keys_account_creation.intersection(set(bcrypt_is_used).union(set(flask_bcrypt_is_used)).union(set(passlib_bcrypt_is_used)))
keys_scrypt_is_used = keys_account_creation.intersection(set(hashlib_scrypt_is_used).union(set(passlib_scrypt_is_used)).union(set(werkzeug_scrypt_is_used)))
keys_pbkdf2_is_used = keys_account_creation.intersection(set(hashlib_pbkdf2_is_used).union(set(passlib_pbkdf2_is_used)).union(set(werkzeug_pbkdf2_is_used)))
keys_bcrypt_is_owasp_compliant_false_positives = keys_account_creation.intersection(set(flask_bcrypt_is_owasp_compliant_false_positives))
keys_argon2_is_owasp_compliant = keys_account_creation.intersection(set(argon2_is_owasp_compliant).union(set(passlib_argon2_is_owasp_compliant)))
keys_bcrypt_is_owasp_compliant = keys_account_creation.intersection(set(bcrypt_is_owasp_compliant).union(set(flask_bcrypt_is_owasp_compliant)).union(set(passlib_bcrypt_is_owasp_compliant))).difference(keys_bcrypt_is_owasp_compliant_false_positives)
keys_scrypt_is_owasp_compliant = keys_account_creation.intersection(set(hashlib_scrypt_is_owasp_compliant).union(set(passlib_scrypt_is_owasp_compliant)).union(set(werkzeug_scrypt_is_owasp_compliant)))
keys_pbkdf2_is_owasp_compliant = keys_account_creation.intersection(set(hashlib_pbkdf2_is_owasp_compliant).union(set(passlib_pbkdf2_is_owasp_compliant)).union(set(werkzeug_pbkdf2_is_owasp_compliant)))
repos_with_password_hashing = keys_account_creation.intersection(set(argon2_is_used).union(set(bcrypt_is_used)).union(set(flask_bcrypt_is_used)).union(set(passlib_is_used)).union(set(werkzeug_is_used)).union(set(hashlib_is_used)))
repos_using_argon2_not_owasp_compliant = keys_argon2_is_used.difference(keys_argon2_is_owasp_compliant)
repos_using_bcrypt_not_owasp_compliant = keys_bcrypt_is_used.difference(keys_bcrypt_is_owasp_compliant).difference(keys_bcrypt_is_owasp_compliant_false_positives)
repos_using_scrypt_not_owasp_compliant = keys_scrypt_is_used.difference(keys_scrypt_is_owasp_compliant)
repos_using_pbkdf2_not_owasp_compliant = keys_pbkdf2_is_used.difference(keys_pbkdf2_is_owasp_compliant)
not_using_a_recommended_algorithm = repos_with_password_hashing.difference(keys_argon2_is_used.union(keys_bcrypt_is_used).union(keys_scrypt_is_used).union(keys_pbkdf2_is_used))
not_using_supported_libraries = keys_account_creation.difference(repos_with_password_hashing)

print("argon2_is_used: " + str(len(set(argon2_is_used))))
print("bcrypt_is_used: " + str(len(set(bcrypt_is_used))))
print("flask_bcrypt_is_used: " + str(len(set(flask_bcrypt_is_used))))
print("passlib_is_used: " + str(len(set(passlib_is_used))))
print("werkzeug_is_used: " + str(len(set(werkzeug_is_used))))
print("hashlib_is_used: " + str(len(set(hashlib_is_used))))

counter_flask = len(repos)
counter_account_creation = len(keys_account_creation)

counter_no_session_protection = len(no_session_protection)
counter_session_protection_basic = len(session_protection_basic_set)
counter_session_protection_strong = len(session_protection_strong_set)
counter_session_protection_false_positives = len(keys_session_protection_potential_false_positives)
counter_uncategorized_session_protection = len(uncategorized_session_protection)

counter_hardcoded_secret_keys = len(repos_hardcoded_secret_key)
counter_hardcoded_secret_keys_false_positives = len(hardcoded_secret_key_false_positives)
counter_hardcoded_secret_key_true_positives = len(hardcoded_secret_key_true_positives)
counter_hardcoded_secret_key_too_short_true_positives = len(hardcoded_secret_key_too_short_true_positives)

counter_custom_password_validators = len(keys_custom_password_validators)
counter_length_password_validators = len(keys_length_password_validators)
counter_regexp_password_validators = len(keys_regexp_password_validators)
counter_length_and_regexp_password_validators = len(length_and_regexp_password_validators)
counter_performing_password_validation = len(performing_password_validation)
counter_not_performing_password_validation = len(not_performing_password_validation)
counter_not_validating_password_fields_with_validators = len(not_validating_password_fields_with_validators)
counter_min_length_password_validation = len(keys_min_length_password_validation)
counter_max_length_password_validation = len(keys_max_length_password_validation)

counter_csrf_activated = len(csrf_protection_global)
counter_csrf_deactivated_selectively = len(csrf_protection_global_selectively_disabled)
counter_csrf_activated_selectively = len(csrf_protection_selectively_activated)
counter_csrf_deactivated_selectively_disabled = len(csrf_protection_selectively_disabled)
counter_csrf_deactivated = len(csrf_protection_disabled)
counter_repos_using_csrf_library = len(repos_using_csrf_library) + len(repos_with_csrf_disabled)
counter_not_using_csrf_library = len(not_using_csrf_library)
counter_repos_with_csrf_disabled = len(repos_with_csrf_disabled)

""" counter_csrf_categories_union = len(csrf_categories_union)
counter_not_in_any_csrf_category = len(not_in_any_csrf_category)
counter_repos_in_more_than_one_category = len(repos_in_more_than_one_category) """

counter_repos_with_password_hashing = len(repos_with_password_hashing)
counter_not_using_a_recommended_algorithm = len(not_using_a_recommended_algorithm)
counter_not_using_supported_libraries = len(not_using_supported_libraries)
counter_keys_argon2_is_used = len(keys_argon2_is_used)
counter_keys_scrypt_is_used = len(keys_scrypt_is_used)
counter_keys_bcrypt_is_used = len(keys_bcrypt_is_used)
counter_keys_pbkdf2_is_used = len(keys_pbkdf2_is_used)
counter_keys_argon2_is_owasp_compliant = len(keys_argon2_is_owasp_compliant)
counter_keys_scrypt_is_owasp_compliant = len(keys_scrypt_is_owasp_compliant)
counter_keys_bcrypt_is_owasp_compliant = len(keys_bcrypt_is_owasp_compliant)
counter_bcrypt_is_owasp_compliant_false_positives = len(keys_bcrypt_is_owasp_compliant_false_positives)
counter_keys_pbkdf2_is_owasp_compliant = len(keys_pbkdf2_is_owasp_compliant)
counter_argon2_not_owasp_compliant = len(repos_using_argon2_not_owasp_compliant)
counter_scrypt_not_owasp_compliant = len(repos_using_scrypt_not_owasp_compliant)
counter_bcrypt_not_owasp_compliant = len(repos_using_bcrypt_not_owasp_compliant)
counter_pbkdf2_not_owasp_compliant = len(repos_using_pbkdf2_not_owasp_compliant)

saveDictsToFile(["session_management", "account_creation"], [repos, keys_account_creation], [[flask_login_usage], [flask_wtf_account_creation]])
saveDictsToFile(["no_session_protection", "session_protection_basic", "session_protection_strong", "potential_false_positives_session_protection", "uncategorized_session_protection"],
                [no_session_protection, session_protection_basic_set, session_protection_strong_set, keys_session_protection_potential_false_positives, uncategorized_session_protection],
                [[session_protection_none, no_fresh_login], [flask_login_usage], [session_protection_strong], [session_protection_potential_false_positives], [flask_login_usage]])
saveDictsToFile(["hardcoded_secret_keys", "potential_false_positives_hardcoded_secret_keys", "true_positives_hardcoded_secret_keys", "hardcoded_secret_key_too_short_true_positives"],
                [repos_hardcoded_secret_key, hardcoded_secret_key_false_positives, hardcoded_secret_key_true_positives, hardcoded_secret_key_too_short_true_positives],
                [[hardcoded_secret_key], [hardcoded_secret_key_potential_false_positives], [hardcoded_secret_key], [hardcoded_secret_key]])
saveDictsToFile(["not_performing_password_validation", "custom_password_validators", "length_password_validators", "regexp_password_validators", "length_and_regexp_password_validators", "not_validating_password_fields_with_validators"],
                [not_performing_password_validation, keys_custom_password_validators, keys_length_password_validators, keys_regexp_password_validators, length_and_regexp_password_validators, not_validating_password_fields_with_validators],
               [[flask_wtf_account_creation], [custom_password_validators], [length_password_validators], [regexp_password_validators], [length_password_validators, regexp_password_validators], [signup_form_not_validated]])
saveDictsToFile(["csrf_activated_globally", "csrf_deactivated_selectively", "csrf_activated_selectively", "csrf_deactivated_globally", "not_using_csrf_library", "using_csrf_library", "disabling_csrf", "csrf_disabled_and_selectively_disabled"],
                [csrf_protection_global, csrf_protection_global_selectively_disabled, csrf_protection_selectively_activated, csrf_protection_disabled, not_using_csrf_library, repos_using_csrf_library, repos_with_csrf_disabled, csrf_protection_selectively_disabled],
                [[csrf_enabled_globally], [using_csrf_exempt, disabled_flask_wtf_csrf_protection, using_flaskform_with_csrf_disabled], [using_flaskform_csrf, using_csrf_protect, using_wtforms_csrf_protection], [flask_login_usage], [flask_login_usage], [using_wtforms, using_flask_wtf], [disabled_flask_wtf_csrf_global_protection], [using_flaskform_with_csrf_disabled]])
saveDictsToFile(["using_password_hashing", "not_using_recommended_algorithm", "not_using_supported_library", "using_argon2", "using_scrypt", "using_bcrypt", "using_pbkdf2"],
                [repos_with_password_hashing, not_using_a_recommended_algorithm, not_using_supported_libraries, keys_argon2_is_used, keys_scrypt_is_used, keys_bcrypt_is_used, keys_pbkdf2_is_used],
                [[argon2_is_used, bcrypt_is_used, flask_bcrypt_is_used, passlib_is_used, werkzeug_is_used, hashlib_is_used], [argon2_is_used, bcrypt_is_used, flask_bcrypt_is_used, passlib_is_used, werkzeug_is_used, hashlib_is_used],
                 [flask_wtf_account_creation], [argon2_is_used, passlib_argon2_is_used], [hashlib_scrypt_is_used, passlib_scrypt_is_used, werkzeug_scrypt_is_used], [bcrypt_is_used, flask_bcrypt_is_used, passlib_bcrypt_is_used],
                 [hashlib_pbkdf2_is_used, passlib_pbkdf2_is_used, werkzeug_pbkdf2_is_used]])
saveDictsToFile(["argon2_owasp_compliant", "scrypt_owasp_compliant", "bcrypt_owasp_compliant", "pbkdf2_owasp_compliant", "argon2_not_owasp_compliant", "scrypt_not_owasp_compliant", "bcrypt_not_owasp_compliant", "pbkdf2_not_owasp_compliant"],
                [keys_argon2_is_owasp_compliant, keys_scrypt_is_owasp_compliant, keys_bcrypt_is_owasp_compliant, keys_pbkdf2_is_owasp_compliant, repos_using_argon2_not_owasp_compliant, repos_using_scrypt_not_owasp_compliant, repos_using_bcrypt_not_owasp_compliant, repos_using_pbkdf2_not_owasp_compliant],
                [[argon2_is_owasp_compliant, passlib_argon2_is_owasp_compliant], [hashlib_scrypt_is_owasp_compliant, passlib_scrypt_is_owasp_compliant, werkzeug_scrypt_is_owasp_compliant], [bcrypt_is_owasp_compliant, flask_bcrypt_is_owasp_compliant, passlib_bcrypt_is_owasp_compliant], 
                 [hashlib_pbkdf2_is_owasp_compliant, passlib_pbkdf2_is_owasp_compliant, werkzeug_pbkdf2_is_owasp_compliant], [argon2_is_used, passlib_argon2_is_used], [hashlib_scrypt_is_used, passlib_scrypt_is_used, werkzeug_scrypt_is_used], [bcrypt_is_used, flask_bcrypt_is_used, passlib_bcrypt_is_used],
                 [hashlib_pbkdf2_is_used, passlib_pbkdf2_is_used, werkzeug_pbkdf2_is_used]])
saveDictsToFile(["bcrypt_owasp_compliant_false_positives"], [keys_bcrypt_is_owasp_compliant_false_positives], [[flask_bcrypt_is_owasp_compliant_false_positives]])
saveDistributionsToFile(["password_validation_min_lengths", "password_validation_max_lengths"], [keys_min_length_password_validation, keys_max_length_password_validation], [[min_lengths_password_validation], [max_lengths_password_validation]], [True, False])
""" saveDictsToFile(["csrf_categories_union", "not_in_any_csrf_category", "in_more_than_one_category"], 
                [csrf_categories_union, not_in_any_csrf_category, repos_in_more_than_one_category], 
                [[using_wtforms, using_flask_wtf, csrf_enabled_globally], 
                [csrf_enabled_globally, using_csrf_exempt, using_csrf_protect, using_flaskform_csrf, using_flaskform_with_csrf_disabled, disabled_flask_wtf_csrf_protection, disabled_flask_wtf_csrf_global_protection, using_wtforms_csrf_protection, using_flask_wtf, using_wtforms], 
                [csrf_enabled_globally, using_csrf_exempt, using_csrf_protect, using_flaskform_csrf, using_flaskform_with_csrf_disabled, disabled_flask_wtf_csrf_protection, disabled_flask_wtf_csrf_global_protection, using_wtforms_csrf_protection, using_flask_wtf, using_wtforms]]) """

report = """
<p>There are <a href="{}" target="_blank">{}</a> flask repos for Session Management and <a href="{}" target="_blank">{}</a> flask repos for Account Creation<br></p>
<h2>Account Creation</h2>
<h3>Password Policies</h3>
<p>{} perform some validation on its password fields ({} %)<br>
<a href="{}" target="_blank">{}</a> do not validate the signup form that has some validators associated with its password field(s), so it's a false positive potentially ({} %)<br>
<a href="{}" target="_blank">{}</a> do not perform validation on the password fields ({} %)<br>
<a href="{}" target="_blank">{}</a> enforce a specific password length ({} %)<br>
<a href="{}" target="_blank">{}</a> enforce a minimum length ({} %)<br>
<a href="{}" target="_blank">{}</a> enforce a maximum length ({} %)<br>
<a href="{}" target="_blank">{}</a> check the password against a regexp ({} %)<br>
<a href="{}" target="_blank">{}</a> combine length checks and regular expression checks ({} %)<br>
<a href="{}" target="_blank">{}</a> use a custom validator ({} %)<br></p>
<h3>Password Hashing</h3>
<p><a href="{}" target="_blank">{}</a> applications use some form of (supported) password hashing ({} %)<br>
<a href="{}" target="_blank">{}</a> applications do not use one of the supported password hashing libraries or do not perform password hashing ({} %)<br>
<a href="{}" target="_blank">{}</a> applications use some form of (supported) password hashing but do not use one of the recommended algorithms ({} %)<br>
<a href="{}" target="_blank">{}</a> use argon2id and is owasp compliant (no false positives) ({} %)<br>
<a href="{}" target="_blank">{}</a> use scrypt and is owasp compliant (no false positives) ({} %)<br>
<a href="{}" target="_blank">{}</a> use PBKDF2 and is owasp compliant (no false positives) ({} %)<br>
<a href="{}" target="_blank">{}</a> use bcrypt and is owasp compliant (no false positives) ({} %)<br>
<a href="{}" target="_blank">{}</a> use argon2id and is not owasp compliant (no false positives) ({} %)<br>
<a href="{}" target="_blank">{}</a> use scrypt and is not owasp compliant (no false positives) ({} %)<br>
<a href="{}" target="_blank">{}</a> use PBKDF2 and is not owasp compliant (no false positives) ({} %)<br>
<a href="{}" target="_blank">{}</a> use bcrypt and is not owasp compliant (no false positives) ({} %)<br>
<a href="{}" target="_blank">{}</a> bcrypt owasp compliance is potentially a false positive ({} %)<br></p>
<h2>Session Management</h2>
<h3>Cryptographic Keys</h3>
<p><a href="{}" target="_blank">{}</a> had a hardcoded secret key ({} %)<br>
<a href="{}" target="_blank">{}</a> set the secret key more than once (and it's hardcoded at least once), so it's a false positive potentially ({} %)<br>
<a href="{}" target="_blank">{}</a> set the secret key to a hardcoded string every time, so it's a true positive ({} %)<br>
<a href="{}" target="_blank">{}</a> set the secret key to a hardcoded string every time, so it's a true positive and it's too short ({} %)<br></p>
<h3>CSRF</h3>
<p><a href="{}" target="_blank">{}</a> Not using CSRF library, so either they don't have csrf protection or use some other way to protect against CSRF ({} %)<br>
<a href="{}" target="_blank">{}</a> use a csrf library, either flask_wtf or wtforms ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF global protection is always active ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF global protection is activated, but it is deactivated on some views ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF global protection is deactivated, but it is activated on some views or forms ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF global protection is deactivated, and the default FlaskForm CSRF protection is also selectively deactivated (so either it is fully deactivated or some forms are still protected) ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF protection is deactivated everywhere, so either the app is doing something custom or it's vulnerable ({} %)<br>
<a href="{}" target="_blank">{}</a> manually disable CSRF (likely) for testing purposes (CSRF protection deactivated potential false positives) ({} %)<br></p>
<h3>Session Protection</h3>
<p><a href="{}" target="_blank">{}</a> didn't use session protection ({} %)<br>
<a href="{}" target="_blank">{}</a> used basic session protection ({} %)<br>
<a href="{}" target="_blank">{}</a> used strong session protection ({} %)<br>
<a href="{}" target="_blank">{}</a> set session protection more than once, so it's a false positive potentially ({} %)<br>
<a href="{}" target="_blank">{}</a> are not in any session protection category ({} %)<br></p>
<h3>Logout Security</h3>
<p></p>
"""

""" <a href="{}" target="_blank">{}</a> CSRF categories union ({} %)<br>
<a href="{}" target="_blank">{}</a> are in more than one CSRF category ({} %)<br>
<a href="{}" target="_blank">{}</a> are not in any CSRF category but use a csrf library ({} %)<br> """

""" "./csrf_categories_union.txt", str(counter_csrf_categories_union), str(getPercentage(counter_csrf_categories_union, counter_repos_using_csrf_library)),
"./in_more_than_one_category.txt", str(counter_repos_in_more_than_one_category), str(getPercentage(counter_repos_in_more_than_one_category, counter_repos_using_csrf_library)),
"./not_in_any_csrf_category.txt", str(counter_not_in_any_csrf_category), str(getPercentage(counter_not_in_any_csrf_category, counter_repos_using_csrf_library)), """

report_html = report.format("./session_management.txt", str(counter_flask), "./account_creation.txt", str(counter_account_creation),
                            str(counter_performing_password_validation), str(getPercentage(counter_performing_password_validation, counter_account_creation)),
                            "./not_validating_password_fields_with_validators.txt", str(counter_not_validating_password_fields_with_validators), str(getPercentage(counter_not_validating_password_fields_with_validators, counter_performing_password_validation)),
                            "./not_performing_password_validation.txt", str(counter_not_performing_password_validation), str(getPercentage(counter_not_performing_password_validation, counter_account_creation)),
                            "./length_password_validators.txt", str(counter_length_password_validators), str(getPercentage(counter_length_password_validators, counter_account_creation)),
                            "./password_validation_min_lengths.txt", str(counter_min_length_password_validation), str(getPercentage(counter_min_length_password_validation, counter_account_creation)),
                            "./password_validation_max_lengths.txt", str(counter_max_length_password_validation), str(getPercentage(counter_max_length_password_validation, counter_account_creation)),
                            "./regexp_password_validators.txt", str(counter_regexp_password_validators), str(getPercentage(counter_regexp_password_validators, counter_account_creation)),
                            "./length_and_regexp_password_validators.txt", str(counter_length_and_regexp_password_validators), str(getPercentage(counter_length_and_regexp_password_validators, counter_account_creation)),
                            "./custom_password_validators.txt", str(counter_custom_password_validators), str(getPercentage(counter_custom_password_validators, counter_account_creation)),
                            "./using_password_hashing.txt", str(counter_repos_with_password_hashing), str(getPercentage(counter_repos_with_password_hashing, counter_account_creation)),
                            "./not_using_supported_library.txt", str(counter_not_using_supported_libraries), str(getPercentage(counter_not_using_supported_libraries, counter_account_creation)),
                            "./not_using_recommended_algorithm.txt", str(counter_not_using_a_recommended_algorithm), str(getPercentage(counter_not_using_a_recommended_algorithm, counter_account_creation)),
                            "./argon2_owasp_compliant.txt", str(counter_keys_argon2_is_owasp_compliant), str(getPercentage(counter_keys_argon2_is_owasp_compliant, counter_account_creation)),
                            "./scrypt_owasp_compliant.txt", str(counter_keys_scrypt_is_owasp_compliant), str(getPercentage(counter_keys_scrypt_is_owasp_compliant, counter_account_creation)),
                            "./pbkdf2_owasp_compliant.txt", str(counter_keys_pbkdf2_is_owasp_compliant), str(getPercentage(counter_keys_pbkdf2_is_owasp_compliant, counter_account_creation)),
                            "./bcrypt_owasp_compliant.txt", str(counter_keys_bcrypt_is_owasp_compliant), str(getPercentage(counter_keys_bcrypt_is_owasp_compliant, counter_account_creation)),
                            "./argon2_not_owasp_compliant.txt", str(counter_argon2_not_owasp_compliant), str(getPercentage(counter_argon2_not_owasp_compliant, counter_account_creation)),
                            "./scrypt_not_owasp_compliant.txt", str(counter_scrypt_not_owasp_compliant), str(getPercentage(counter_scrypt_not_owasp_compliant, counter_account_creation)),
                            "./pbkdf2_not_owasp_compliant.txt", str(counter_pbkdf2_not_owasp_compliant), str(getPercentage(counter_pbkdf2_not_owasp_compliant, counter_account_creation)),
                            "./bcrypt_not_owasp_compliant.txt", str(counter_bcrypt_not_owasp_compliant), str(getPercentage(counter_bcrypt_not_owasp_compliant, counter_account_creation)),
                            "./bcrypt_owasp_compliant_false_positives.txt", str(counter_bcrypt_is_owasp_compliant_false_positives), str(getPercentage(counter_bcrypt_is_owasp_compliant_false_positives, counter_account_creation)),
                            "./hardcoded_secret_keys.txt", str(counter_hardcoded_secret_keys), str(getPercentage(counter_hardcoded_secret_keys, counter_flask)),
                            "./potential_false_positives_hardcoded_secret_keys.txt", str(counter_hardcoded_secret_keys_false_positives), str(getPercentage(counter_hardcoded_secret_keys_false_positives, counter_hardcoded_secret_keys)), 
                            "./true_positives_hardcoded_secret_keys.txt", str(counter_hardcoded_secret_key_true_positives), str(getPercentage(counter_hardcoded_secret_key_true_positives, counter_hardcoded_secret_keys)),
                            "./hardcoded_secret_key_too_short_true_positives.txt", str(counter_hardcoded_secret_key_too_short_true_positives), str(getPercentage(counter_hardcoded_secret_key_too_short_true_positives, counter_hardcoded_secret_keys)),
                            ".not_using_csrf_library/.txt", str(counter_not_using_csrf_library), str(getPercentage(counter_not_using_csrf_library, counter_flask)),
                            "./using_csrf_library.txt", str(counter_repos_using_csrf_library), str(getPercentage(counter_repos_using_csrf_library, counter_flask)),
                            "./csrf_activated_globally.txt", str(counter_csrf_activated), str(getPercentage(counter_csrf_activated, counter_repos_using_csrf_library)),
                            "./csrf_deactivated_selectively.txt", str(counter_csrf_deactivated_selectively), str(getPercentage(counter_csrf_deactivated_selectively, counter_repos_using_csrf_library)),
                            "./csrf_activated_selectively.txt", str(counter_csrf_activated_selectively), str(getPercentage(counter_csrf_activated_selectively, counter_repos_using_csrf_library)),
                            "./csrf_disabled_and_selectively_disabled.txt", str(counter_csrf_deactivated_selectively_disabled), str(getPercentage(counter_csrf_deactivated_selectively_disabled, counter_repos_using_csrf_library)),
                            "./csrf_deactivated_globally.txt", str(counter_csrf_deactivated), str(getPercentage(counter_csrf_deactivated, counter_repos_using_csrf_library)),
                            "./disabling_csrf.txt", str(counter_repos_with_csrf_disabled), str(getPercentage(counter_repos_with_csrf_disabled, counter_repos_using_csrf_library)),
                            "./no_session_protection.txt", str(counter_no_session_protection), str(getPercentage(counter_no_session_protection, counter_flask)),
                            "./session_protection_basic.txt", str(counter_session_protection_basic), str(getPercentage(counter_session_protection_basic, counter_flask)), 
                            "./session_protection_strong.txt", str(counter_session_protection_strong), str(getPercentage(counter_session_protection_strong, counter_flask)),
                            "./potential_false_positives_session_protection.txt", str(counter_session_protection_false_positives), str(getPercentage(counter_session_protection_false_positives, counter_flask)),
                            "./uncategorized_session_protection.txt", str(counter_uncategorized_session_protection), str(getPercentage(counter_uncategorized_session_protection, counter_flask)))

with open(str(path.absolute()) + "/report.html", "w") as file:
    file.write(report_html)
