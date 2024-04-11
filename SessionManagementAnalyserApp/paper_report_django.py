from pathlib import Path
import os
import csv

path = Path(__file__).parent / './paper_reports_django/paper_report'
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

csv_dict = loadCSV(Path(__file__).parent / '../django_whitelist_filtered_v2.csv')
django_login_usage = extractResults("Django", ".", "django_library_used_check", True, csv_dict)
django_login_required_usage = extractResults("Django", "Login-restrictions", "un_no_authentication_checks_general", False, csv_dict)
django_custom_session_engine = extractResults("Django", ".", "custom_session_engine", False, csv_dict)
django_account_creation = extractResults("Django", "Password-strength", "un_using_django_built_in_forms", True, csv_dict)
hardcoded_secret_key = extractResults("Django", "Secret-key", "un_secret_key", True, csv_dict)
hardcoded_secret_key_potential_false_positives = extractFalsePositives("Django", "Explorative-queries", "un_potential_false_positives", "un_secret_key ", True, csv_dict)
custom_password_validators = extractResults("Django", "Password-strength", "un_using_custom_validators", True, csv_dict)
length_password_validators = extractResults("Django", "Password-strength", "un_using_length_validator", True, csv_dict)
numeric_password_validators = extractResults("Django", "Password-strength", "un_using_numeric_password_validator", True, csv_dict)
common_password_validators = extractResults("Django", "Password-strength", "un_using_common_password_validator", True, csv_dict)
similarity_password_validators = extractResults("Django", "Password-strength", "un_using_similarity_validator", True, csv_dict)
password_validators_potential_false_positives = extractFalsePositives("Django", "Explorative-queries", "un_potential_false_positives", "un_using_password_validators ", True, csv_dict)
csrf_disabled_globally = extractResults("Django", "CSRF", "un_csrf_protection_is_disabled", True, csv_dict)
using_csrf_exempt = extractResults("Django", "CSRF", "un_csrf_exempt_is_used", True, csv_dict)
using_csrf_protect = extractResults("Django", "CSRF", "un_csrf_protect_is_used", True, csv_dict)
using_csrf_requires = extractResults("Django", "CSRF", "un_requires_csrf_token_is_used", True, csv_dict) # csrf protection still active, but you are not rejecting request that do not adhere, so it's like selectively disabling csrf
overriding_csrf_middleware = extractResults("Django", "CSRF", "un_using_custom_csrf_middleware", True, csv_dict)
argon2_is_used = extractResults("Django", "Password-hashing", "un_argon2_is_used", True, csv_dict)
argon2_is_owasp_compliant = extractResults("Django", "Password-hashing", "un_argon2_is_owasp_compliant", True, csv_dict)
bcrypt_is_used = extractResults("Django", "Password-hashing", "un_bcrypt_is_used", True, csv_dict)
bcrypt_is_owasp_compliant = extractResults("Django", "Password-hashing", "un_bcrypt_is_owasp_compliant", True, csv_dict)
pbkdf2_is_used = extractResults("Django", "Password-hashing", "un_pbkdf2_is_used", True, csv_dict)
pbkdf2_is_owasp_compliant = extractResults("Django", "Password-hashing", "un_pbkdf2_is_owasp_compliant", True, csv_dict)
scrypt_is_used = extractResults("Django", "Password-hashing", "un_scrypt_is_used", True, csv_dict)
scrypt_is_owasp_compliant = extractResults("Django", "Password-hashing", "un_scrypt_is_owasp_compliant", True, csv_dict)
md5_is_used = extractResults("Django", "Password-hashing", "un_md5_is_used", True, csv_dict)
custom_password_hasher_is_used = extractResults("Django", "Password-hashing", "un_using_custom_password_hasher", True, csv_dict)
middleware_potential_false_positives = extractFalsePositives("Django", "Explorative-queries", "un_potential_false_positives", "un_csrf_protection_is_disabled ", True, csv_dict)
password_hashers_potential_false_positives = extractFalsePositives("Django", "Explorative-queries", "un_potential_false_positives", "un_manually_set_password_hashers ", True, csv_dict)
logout_function_is_not_called = extractResults("Django", "Logout-function-is-called", "un_logout_function_is_called", False, csv_dict)
using_client_side_sessions = extractResults("Django", "Logout-session-invalidation", "un_client_side_session", True, csv_dict)
allauth_is_used = extractResults("Django", "Explorative-queries", "un_allauth_is_used", True, csv_dict)
dj_rest_auth_is_used = extractResults("Django", "Explorative-queries", "un_dj_rest_auth_is_used", True, csv_dict)
django_registration_macropin_is_used = extractResults("Django", "Explorative-queries", "un_django_registration_macropin_is_used", True, csv_dict)
django_registration_ubernostrum_is_used = extractResults("Django", "Explorative-queries", "un_django_registration_ubernostrum_is_used", True, csv_dict)
django_rest_framework_is_used = extractResults("Django", "Explorative-queries", "un_django_rest_framework_is_used", True, csv_dict)
django_rest_registration_is_used = extractResults("Django", "Explorative-queries", "un_django_rest_registration_is_used", True, csv_dict)
django_user_accounts_is_used = extractResults("Django", "Explorative-queries", "un_django_user_accounts_is_used", True, csv_dict)
django_xadmin_is_used = extractResults("Django", "Explorative-queries", "un_django_xadmin_is_used", True, csv_dict)
djoser_is_used = extractResults("Django", "Explorative-queries", "un_djoser_is_used", True, csv_dict)
knox_is_used = extractResults("Django", "Explorative-queries", "un_knox_is_used", True, csv_dict)

keys_django_login_usages = set(django_login_usage)
keys_django_login_required_usages = set(django_login_required_usage)
keys_django_custom_session_engine = set(django_custom_session_engine)
repos = keys_django_login_usages.intersection(keys_django_login_required_usages).intersection(keys_django_custom_session_engine)
keys_account_creation = set(django_account_creation).intersection(keys_django_login_required_usages).intersection(keys_django_custom_session_engine)

keys_hardcoded_secret_key = set(hardcoded_secret_key)
keys_hardcoded_secret_key_potential_false_positives = set(hardcoded_secret_key_potential_false_positives)
repos_hardcoded_secret_key = repos.intersection(keys_hardcoded_secret_key)
hardcoded_secret_key_false_positives = repos_hardcoded_secret_key.intersection(keys_hardcoded_secret_key_potential_false_positives)
hardcoded_secret_key_true_positives = repos_hardcoded_secret_key.difference(keys_hardcoded_secret_key_potential_false_positives)

keys_custom_password_validators = keys_account_creation.intersection(set(custom_password_validators))
keys_length_password_validators = keys_account_creation.intersection(set(length_password_validators))
keys_numeric_password_validators = keys_account_creation.intersection(set(numeric_password_validators))
keys_common_password_validators = keys_account_creation.intersection(set(common_password_validators))
keys_similarity_password_validators = keys_account_creation.intersection(set(similarity_password_validators))
keys_password_validators_potential_false_positives = keys_account_creation.intersection(set(password_validators_potential_false_positives))
using_all_password_validators = keys_account_creation.intersection(keys_length_password_validators.intersection(keys_numeric_password_validators).intersection(keys_common_password_validators).intersection(keys_similarity_password_validators))
performing_password_validation = keys_account_creation.intersection(keys_custom_password_validators.union(keys_length_password_validators).union(keys_numeric_password_validators).union(keys_common_password_validators).union(keys_similarity_password_validators))
not_performing_password_validation = keys_account_creation.difference(performing_password_validation)

keys_overriding_csrf_middleware = repos.intersection(set(overriding_csrf_middleware))
keys_csrf_disabled_globally = set(csrf_disabled_globally)
keys_using_csrf_exempt = set(using_csrf_exempt)
keys_using_csrf_protect = set(using_csrf_protect)
keys_using_csrf_requires = set(using_csrf_requires)
keys_middleware_potential_false_positives = repos.intersection(set(middleware_potential_false_positives))
csrf_protection_global = repos.difference(keys_overriding_csrf_middleware).difference(keys_csrf_disabled_globally.union(keys_using_csrf_exempt).union(keys_using_csrf_requires))
csrf_protection_global_selectively_disabled = repos.difference(keys_overriding_csrf_middleware).difference(keys_csrf_disabled_globally).intersection(keys_using_csrf_exempt.union(keys_using_csrf_requires))
csrf_protection_selectively_activated = repos.difference(keys_overriding_csrf_middleware).intersection(keys_csrf_disabled_globally).intersection(keys_using_csrf_protect)
csrf_protection_disabled = repos.difference(keys_overriding_csrf_middleware).intersection(keys_csrf_disabled_globally).difference(keys_using_csrf_protect)

keys_argon2_is_used = keys_account_creation.intersection(set(argon2_is_used))
keys_bcrypt_is_used = keys_account_creation.intersection(set(bcrypt_is_used))
keys_scrypt_is_used = keys_account_creation.intersection(set(scrypt_is_used))
keys_pbkdf2_is_used = keys_account_creation.intersection(set(pbkdf2_is_used))
keys_password_hashers_potential_false_positives = keys_account_creation.intersection(set(password_hashers_potential_false_positives))
keys_argon2_is_owasp_compliant = keys_account_creation.intersection(set(argon2_is_owasp_compliant))
keys_bcrypt_is_owasp_compliant = keys_account_creation.intersection(set(bcrypt_is_owasp_compliant))
keys_scrypt_is_owasp_compliant = keys_account_creation.intersection(set(scrypt_is_owasp_compliant))
keys_pbkdf2_is_owasp_compliant = keys_account_creation.intersection(set(pbkdf2_is_owasp_compliant))
repos_with_password_hashing = keys_account_creation.intersection(set(argon2_is_used).union(set(bcrypt_is_used)).union(set(scrypt_is_used)).union(set(pbkdf2_is_used)).union(set(md5_is_used)).union(set(custom_password_hasher_is_used)))
repos_using_argon2_not_owasp_compliant = keys_argon2_is_used.difference(keys_argon2_is_owasp_compliant)
repos_using_bcrypt_not_owasp_compliant = keys_bcrypt_is_used.difference(keys_bcrypt_is_owasp_compliant)
repos_using_scrypt_not_owasp_compliant = keys_scrypt_is_used.difference(keys_scrypt_is_owasp_compliant)
repos_using_pbkdf2_not_owasp_compliant = keys_pbkdf2_is_used.difference(keys_pbkdf2_is_owasp_compliant)
not_using_a_recommended_algorithm = repos_with_password_hashing.difference(keys_argon2_is_used.union(keys_bcrypt_is_used).union(keys_scrypt_is_used).union(keys_pbkdf2_is_used)) # don't know if this works, I probably need to use custom password hasher + md5 is used
not_using_supported_libraries = keys_account_creation.difference(repos_with_password_hashing)

keys_logout_function_is_not_called = repos.intersection(set(logout_function_is_not_called))
keys_using_client_side_sessions = repos.intersection(set(using_client_side_sessions))
repos_without_auth_libraries = repos.difference(set(allauth_is_used).union(set(dj_rest_auth_is_used).union(set(django_registration_macropin_is_used).union(set(django_registration_ubernostrum_is_used).union(set(django_rest_framework_is_used).union(set(django_rest_registration_is_used).union(set(django_user_accounts_is_used).union(set(django_xadmin_is_used).union(set(djoser_is_used).union(set(knox_is_used)))))))))))
not_calling_logout_server_side_sessions = keys_logout_function_is_not_called.difference(keys_using_client_side_sessions)
not_calling_logout_server_side_sessions_without_auth_libraries = repos_without_auth_libraries.intersection(not_calling_logout_server_side_sessions)

counter_django = len(repos)
counter_account_creation = len(keys_account_creation)

counter_hardcoded_secret_keys = len(repos_hardcoded_secret_key)
counter_hardcoded_secret_keys_false_positives = len(hardcoded_secret_key_false_positives)
counter_hardcoded_secret_key_true_positives = len(hardcoded_secret_key_true_positives)

counter_custom_password_validators = len(keys_custom_password_validators)
counter_length_password_validators = len(keys_length_password_validators)
counter_numeric_password_validators = len(keys_numeric_password_validators)
counter_common_password_validators = len(keys_common_password_validators)
counter_similarity_password_validators = len(keys_similarity_password_validators)
counter_using_all_password_validators = len(using_all_password_validators)
counter_performing_password_validation = len(performing_password_validation)
counter_not_performing_password_validation = len(not_performing_password_validation)
counter_password_validators_potential_false_positives = len(keys_password_validators_potential_false_positives)

counter_csrf_activated = len(csrf_protection_global)
counter_csrf_deactivated_selectively = len(csrf_protection_global_selectively_disabled)
counter_csrf_activated_selectively = len(csrf_protection_selectively_activated)
counter_csrf_deactivated = len(csrf_protection_disabled)
counter_overriding_csrf_middleware = len(keys_overriding_csrf_middleware)
counter_middleware_potential_false_positives = len(keys_middleware_potential_false_positives)

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
counter_keys_pbkdf2_is_owasp_compliant = len(keys_pbkdf2_is_owasp_compliant)
counter_argon2_not_owasp_compliant = len(repos_using_argon2_not_owasp_compliant)
counter_scrypt_not_owasp_compliant = len(repos_using_scrypt_not_owasp_compliant)
counter_bcrypt_not_owasp_compliant = len(repos_using_bcrypt_not_owasp_compliant)
counter_pbkdf2_not_owasp_compliant = len(repos_using_pbkdf2_not_owasp_compliant)
counter_password_hashers_potential_false_positives = len(keys_password_hashers_potential_false_positives)

counter_not_calling_logout_server_side_sessions = len(not_calling_logout_server_side_sessions)
counter_repos_without_auth_libraries = len(repos_without_auth_libraries)
counter_not_calling_logout_server_side_sessions_without_auth_libraries = len(not_calling_logout_server_side_sessions_without_auth_libraries)

saveDictsToFile(["session_management", "account_creation"], [repos, keys_account_creation], [[django_login_usage], [django_account_creation]])
saveDictsToFile(["hardcoded_secret_keys", "potential_false_positives_hardcoded_secret_keys", "true_positives_hardcoded_secret_keys"],
                [repos_hardcoded_secret_key, hardcoded_secret_key_false_positives, hardcoded_secret_key_true_positives],
                [[hardcoded_secret_key], [hardcoded_secret_key_potential_false_positives], [hardcoded_secret_key]])
saveDictsToFile(["not_performing_password_validation", "custom_password_validators", "length_password_validators", "numeric_password_validators", "common_password_validators", "similarity_password_validators", "using_all_password_validators"],
                [not_performing_password_validation, keys_custom_password_validators, keys_length_password_validators, keys_numeric_password_validators, keys_common_password_validators, keys_similarity_password_validators, using_all_password_validators],
               [[django_account_creation], [custom_password_validators], [length_password_validators], [numeric_password_validators], [common_password_validators], [similarity_password_validators],
                [length_password_validators, numeric_password_validators, common_password_validators, similarity_password_validators]])
saveDictsToFile(["csrf_activated_globally", "csrf_deactivated_selectively", "csrf_activated_selectively", "csrf_deactivated_globally", "overriding_default_csrf_middleware"],
                [csrf_protection_global, csrf_protection_global_selectively_disabled, csrf_protection_selectively_activated, csrf_protection_disabled, keys_overriding_csrf_middleware],
                [[django_login_usage], [using_csrf_exempt, using_csrf_requires], [using_csrf_protect], [csrf_disabled_globally], [overriding_csrf_middleware]])
saveDictsToFile(["using_password_hashing", "not_using_recommended_algorithm", "not_using_supported_library", "using_argon2", "using_scrypt", "using_bcrypt", "using_pbkdf2"],
                [repos_with_password_hashing, not_using_a_recommended_algorithm, not_using_supported_libraries, keys_argon2_is_used, keys_scrypt_is_used, keys_bcrypt_is_used, keys_pbkdf2_is_used],
                [[argon2_is_used, bcrypt_is_used, scrypt_is_used, pbkdf2_is_used, md5_is_used, custom_password_hasher_is_used], [md5_is_used, custom_password_hasher_is_used],
                 [django_account_creation], [argon2_is_used], [scrypt_is_used], [bcrypt_is_used], [pbkdf2_is_used]])
saveDictsToFile(["argon2_owasp_compliant", "scrypt_owasp_compliant", "bcrypt_owasp_compliant", "pbkdf2_owasp_compliant", "argon2_not_owasp_compliant", "scrypt_not_owasp_compliant", "bcrypt_not_owasp_compliant", "pbkdf2_not_owasp_compliant"],
                [keys_argon2_is_owasp_compliant, keys_scrypt_is_owasp_compliant, keys_bcrypt_is_owasp_compliant, keys_pbkdf2_is_owasp_compliant, repos_using_argon2_not_owasp_compliant, repos_using_scrypt_not_owasp_compliant, repos_using_bcrypt_not_owasp_compliant, repos_using_pbkdf2_not_owasp_compliant],
                [[argon2_is_owasp_compliant], [scrypt_is_owasp_compliant], [bcrypt_is_owasp_compliant], [pbkdf2_is_owasp_compliant], [argon2_is_used], [scrypt_is_used], [bcrypt_is_used], [pbkdf2_is_used]])
saveDictsToFile(["not_calling_logout_and_session_set_to_server_side", "repos_without_auth_libraries", "not_calling_logout_server_side_sessions_without_auth_libraries"],
                [not_calling_logout_server_side_sessions, repos_without_auth_libraries, not_calling_logout_server_side_sessions_without_auth_libraries],
                [[logout_function_is_not_called], [django_login_usage], [logout_function_is_not_called]])
saveDictsToFile(["potential_false_positives_password_hashers", "potential_false_positives_password_validators", "potential_false_positives_middleware"],
                [keys_password_hashers_potential_false_positives, keys_password_validators_potential_false_positives, keys_middleware_potential_false_positives],
                [[password_hashers_potential_false_positives], [password_validators_potential_false_positives], [middleware_potential_false_positives]])

report = """
<p>There are <a href="{}" target="_blank">{}</a> django repos for Session Management and <a href="{}" target="_blank">{}</a> django repos for Account Creation<br></p>
<h2>Account Creation</h2>
<h3>Password Policies</h3>
<p>{} perform some validation on its password fields ({} %)<br>
<a href="{}" target="_blank">{}</a> do not perform validation on the password fields ({} %)<br>
<a href="{}" target="_blank">{}</a> enforce a minimum password length ({} %)<br>
<a href="{}" target="_blank">{}</a> check the similarity between the password and a set of attributes of the user ({} %)<br>
<a href="{}" target="_blank">{}</a> check whether the password occurs in a list of common passwords ({} %)<br>
<a href="{}" target="_blank">{}</a> check whether the password is not entirely numeric ({} %)<br>
<a href="{}" target="_blank">{}</a> combine all validators ({} %)<br>
<a href="{}" target="_blank">{}</a> use a custom validator ({} %)<br>
<a href="{}" target="_blank">{}</a> set PASSWORD_VALIDATORS more than once ({} %)<br></p>
<h3>Password Hashing</h3>
<p><a href="{}" target="_blank">{}</a> applications use some form of (supported) password hashing ({} %)<br>
<a href="{}" target="_blank">{}</a> applications do not use one of the supported password hashing libraries or do not perform password hashing ({} %)<br>
<a href="{}" target="_blank">{}</a> applications use some form of (supported) password hashing but do not use one of the recommended algorithms ({} %)<br>
<a href="{}" target="_blank">{}</a> use argon2id and is owasp compliant ({} %)<br>
<a href="{}" target="_blank">{}</a> use scrypt and is owasp compliant ({} %)<br>
<a href="{}" target="_blank">{}</a> use PBKDF2 and is owasp compliant ({} %)<br>
<a href="{}" target="_blank">{}</a> use bcrypt and is owasp compliant ({} %)<br>
<a href="{}" target="_blank">{}</a> use argon2id and is not owasp compliant ({} %)<br>
<a href="{}" target="_blank">{}</a> use scrypt and is not owasp compliant ({} %)<br>
<a href="{}" target="_blank">{}</a> use PBKDF2 and is not owasp compliant ({} %)<br>
<a href="{}" target="_blank">{}</a> use bcrypt and is not owasp compliant ({} %)<br>
<a href="{}" target="_blank">{}</a> set PASSWORD_HASHERS more than once ({} %)<br></p>
<h2>Session Management</h2>
<h3>Cryptographic Keys</h3>
<p><a href="{}" target="_blank">{}</a> had a hardcoded secret key ({} %)<br>
<a href="{}" target="_blank">{}</a> set the secret key more than once (and it's hardcoded at least once), so it's a false positive potentially ({} %)<br>
<a href="{}" target="_blank">{}</a> set the secret key only once (and it's hardcoded), so it's a true positive ({} %)<br></p>
<h3>CSRF</h3>
<p><a href="{}" target="_blank">{}</a> CSRF global protection is always active ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF global protection is activated, but it is deactivated on some views ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF global protection is deactivated, but it is activated on some views or forms ({} %)<br>
<a href="{}" target="_blank">{}</a> CSRF protection is deactivated everywhere or they are using something else to protect against csrf ({} %)<br>
<a href="{}" target="_blank">{}</a> override the default csrf middleware, so they were not included in the above classification ({} %)<br>
<a href="{}" target="_blank">{}</a> set MIDDLEWARE more than once ({} %)<br></p>
<h3>Session Protection</h3>
<p></p>
<h3>Logout Security</h3>
<p><a href="{}" target="_blank">{}</a> logout function is never called and the application is using server side sessions ({} %)<br>
<a href="{}" target="_blank">{}</a> repos do not use some other authentication library ({} %)<br>
<a href="{}" target="_blank">{}</a> logout function is never called, the application is using server side sessions and it's not using some other authentication library ({} %)<br></p>
"""

report_html = report.format("./session_management.txt", str(counter_django), "./account_creation.txt", str(counter_account_creation),
                            str(counter_performing_password_validation), str(getPercentage(counter_performing_password_validation, counter_account_creation)),
                            "./not_performing_password_validation.txt", str(counter_not_performing_password_validation), str(getPercentage(counter_not_performing_password_validation, counter_account_creation)),
                            "./length_password_validators.txt", str(counter_length_password_validators), str(getPercentage(counter_length_password_validators, counter_account_creation)),
                            "./similarity_password_validators.txt", str(counter_similarity_password_validators), str(getPercentage(counter_similarity_password_validators, counter_account_creation)),
                            "./common_password_validators.txt", str(counter_common_password_validators), str(getPercentage(counter_common_password_validators, counter_account_creation)),
                            "./numeric_password_validators.txt", str(counter_numeric_password_validators), str(getPercentage(counter_numeric_password_validators, counter_account_creation)),
                            "./using_all_password_validators.txt", str(counter_using_all_password_validators), str(getPercentage(counter_using_all_password_validators, counter_account_creation)),
                            "./custom_password_validators.txt", str(counter_custom_password_validators), str(getPercentage(counter_custom_password_validators, counter_account_creation)),
                            "./potential_false_positives_password_validators.txt", str(counter_password_validators_potential_false_positives), str(getPercentage(counter_password_validators_potential_false_positives, counter_account_creation)),
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
                            "./potential_false_positives_password_hashers.txt", str(counter_password_hashers_potential_false_positives), str(getPercentage(counter_password_hashers_potential_false_positives, counter_account_creation)),
                            "./hardcoded_secret_keys.txt", str(counter_hardcoded_secret_keys), str(getPercentage(counter_hardcoded_secret_keys, counter_django)),
                            "./potential_false_positives_hardcoded_secret_keys.txt", str(counter_hardcoded_secret_keys_false_positives), str(getPercentage(counter_hardcoded_secret_keys_false_positives, counter_hardcoded_secret_keys)), 
                            "./true_positives_hardcoded_secret_keys.txt", str(counter_hardcoded_secret_key_true_positives),  str(getPercentage(counter_hardcoded_secret_key_true_positives, counter_hardcoded_secret_keys)),
                            "./csrf_activated_globally.txt", str(counter_csrf_activated), str(getPercentage(counter_csrf_activated, counter_django)),
                            "./csrf_deactivated_selectively.txt", str(counter_csrf_deactivated_selectively), str(getPercentage(counter_csrf_deactivated_selectively, counter_django)),
                            "./csrf_activated_selectively.txt", str(counter_csrf_activated_selectively), str(getPercentage(counter_csrf_activated_selectively, counter_django)),
                            "./csrf_deactivated_globally.txt", str(counter_csrf_deactivated), str(getPercentage(counter_csrf_deactivated, counter_django)),
                            "./overriding_default_csrf_middleware.txt", str(counter_overriding_csrf_middleware), str(getPercentage(counter_overriding_csrf_middleware, counter_django)),
                            "./potential_false_positives_middleware.txt", str(counter_middleware_potential_false_positives), str(getPercentage(counter_middleware_potential_false_positives, counter_django)),
                            "./not_calling_logout_and_session_set_to_server_side.txt", str(counter_not_calling_logout_server_side_sessions), str(getPercentage(counter_not_calling_logout_server_side_sessions, counter_django)),
                            "./repos_without_auth_libraries.txt", str(counter_repos_without_auth_libraries), str(getPercentage(counter_repos_without_auth_libraries, counter_django)),
                            "./not_calling_logout_server_side_sessions_without_auth_libraries.txt", str(counter_not_calling_logout_server_side_sessions_without_auth_libraries), str(getPercentage(counter_not_calling_logout_server_side_sessions_without_auth_libraries, counter_repos_without_auth_libraries)))

with open(str(path.absolute()) + "/report.html", "w") as file:
    file.write(report_html)
