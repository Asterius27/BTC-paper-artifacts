from pathlib import Path
from collections import Counter
import json

path_exempt = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_deactivated_selectively.txt'
path_protect = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_activated_selectively.txt'
path_views = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/views.txt'
path_generate_csrf_token = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/generate_csrf_token.txt'
path_sensitive_functions = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/views_with_user_access_or_login_required_and_db_writes.txt'
output_path_exempt = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_exempt_keywords.json'
output_path_exempt_tokens = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_exempt_keywords_tokenized.json'
output_path_protect = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_protect_keywords.json'
output_path_protect_tokens = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_protect_keywords_tokenized.json'
output_path_not_protect = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_not_protect_keywords.json'
output_path_not_protect_tokens = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_not_protect_keywords_tokenized.json'
output_path_not_exempt = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_not_exempt_keywords.json'
output_path_not_exempt_tokens = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_not_exempt_keywords_tokenized.json'
output_path_exempt_dict = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_exempt_dict.json'
output_path_not_protect_dict = Path(__file__).parent / './paper_reports_flask/paper_report_q3_v6/csrf_not_protect_dict.json'

""" path_exempt = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_deactivated_selectively.txt'
path_protect = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_activated_selectively.txt'
path_views = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/views.txt'
path_sensitive_functions = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/views_with_user_access_or_login_required_and_db_writes.txt'
output_path_exempt = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_exempt_keywords.json'
output_path_exempt_tokens = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_exempt_keywords_tokenized.json'
output_path_protect = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_protect_keywords.json'
output_path_protect_tokens = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_protect_keywords_tokenized.json'
output_path_not_protect = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_not_protect_keywords.json'
output_path_not_protect_tokens = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_not_protect_keywords_tokenized.json'
output_path_not_exempt = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_not_exempt_keywords.json'
output_path_not_exempt_tokens = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_not_exempt_keywords_tokenized.json'
output_path_exempt_dict = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_exempt_dict.json'
output_path_not_protect_dict = Path(__file__).parent / './paper_reports_django/paper_report_q3_v5/csrf_not_protect_dict.json' """

def readFile(path, n):
    dct = {}
    name = ""
    with path.open(encoding="utf-8") as f:
        lines = f.readlines()
        for line in lines:
            if line.startswith("URL: "):
                dct[line.split(" ")[1].replace("\n", "")] = []
                name = line.split(" ")[1].replace("\n", "")
            else:
                output = line.split("|")
                if len(output) >= n + 1 and len(output[n].split(" ")) >= 6 and len(output[n].split(" ")[5]) >= 1 and output[n].replace(" ", "") != "Noclassorviewfound":
                    dct[name].append(output[n].split(" ")[5] + " " + output[n + 1].replace(" ", ""))
    return dct

def readFileKeysOnly(path):
    lst = []
    with path.open() as f:
        lines = f.readlines()
        for line in lines:
            if line.startswith("URL: "):
                lst.append(line.split(" ")[1].replace("\n", ""))
    return lst

def intersect_views(dict1, dict2):
    result = {}
    for key in dict1:
        if key in dict2:
            lst1 = set(dict1[key])
            lst2 = set(dict2[key])
            inters = lst1.intersection(lst2)
            if len(inters) > 0:
                result[key] = list(inters)
    return result

def difference_views(dict1, dict2):
    result = {}
    for key in dict1:
        if key in dict2:
            lst1 = set(dict1[key])
            lst2 = set(dict2[key])
            inters = lst1.difference(lst2)
            if len(inters) > 0:
                result[key] = list(inters)
    return result

def difference_keys(dct, lst):
    result = {}
    for key in dct:
        if key not in lst:
            result[key] = dct[key]
    return result

def view_names(dct):
    lst = []
    for key in dct:
        for elem in dct[key]:
            lst.append(elem.split(" ")[0])
    return lst

def tokenize(lst):
    subsubwords = []
    subwords = []
    for word in lst:
        subwords += word.split("_")
    for subword in subwords:
        res=""
        for i in subword:
            if(i.isupper()):
                res += "*" + i
            else:
                res += i
        subsubwords += res.lower().split("*")
    return subsubwords

def save_to_file(names, tokens, output_path, output_path_tokens):
    c2 = Counter([x.lower() for x in names])
    del c2["col2"]
    del c2["expr"]
    del c2[""]
    # print(c2)
    c4 = Counter(tokens)
    del c4["col2"]
    del c4["expr"]
    del c4[""]
    # print(c4)
    with output_path.open('w', encoding='utf-8') as f:
        json.dump(c2.most_common(), f, ensure_ascii=False, indent=4)
    with output_path_tokens.open('w', encoding='utf-8') as f:
        json.dump(c4.most_common(), f, ensure_ascii=False, indent=4)

def save_dicts_to_file(dict, output_path):
    with output_path.open('w', encoding='utf-8') as f:
        json.dump(dict, f, ensure_ascii=False, indent=4)

exempt_dict = readFile(path_exempt, 3)

""" protect_dict = readFile(path_protect, 3) """
protect_dict_temp = readFile(path_protect, 4)
generate_csrf_list = readFileKeysOnly(path_generate_csrf_token)
protect_dict = difference_keys(protect_dict_temp, generate_csrf_list)

views_dict = readFile(path_views, 1)
sensitive_views_dict = readFile(path_sensitive_functions, 1)
# print(exempt_dict)

exempt_sensitive_views_dict = intersect_views(exempt_dict, sensitive_views_dict)
protect_sensitive_views_dict = intersect_views(protect_dict, sensitive_views_dict)
not_protect_sensitive_views_dict = intersect_views(difference_views(views_dict, protect_dict), sensitive_views_dict)
not_exempt_sensitive_views_dict = intersect_views(difference_views(views_dict, exempt_dict), sensitive_views_dict)
# print(exempt_sensitive_views_dict)
# print(not_protect_sensitive_views_dict)
print(len(exempt_sensitive_views_dict))
print(len(not_protect_sensitive_views_dict))
# print(len(protect_sensitive_views_dict))
# print(len(not_exempt_sensitive_views_dict))

view_names_exempt = view_names(exempt_sensitive_views_dict)
view_names_protect = view_names(protect_sensitive_views_dict)
view_names_not_protect = view_names(not_protect_sensitive_views_dict)
view_names_not_exempt = view_names(not_exempt_sensitive_views_dict)

exempt_tokens = tokenize(view_names_exempt)
protect_tokens = tokenize(view_names_protect)
not_exempt_tokens = tokenize(view_names_not_exempt)
not_protect_tokens = tokenize(view_names_not_protect)
# print(exempt_names)
# print(protect_names)
# print(exempt_tokens)

save_to_file(view_names_exempt, exempt_tokens, output_path_exempt, output_path_exempt_tokens)
save_to_file(view_names_not_protect, not_protect_tokens, output_path_not_protect, output_path_not_protect_tokens)
# save_to_file(view_names_protect, protect_tokens, output_path_protect, output_path_protect_tokens)
# save_to_file(view_names_not_exempt, not_exempt_tokens, output_path_not_exempt, output_path_not_exempt_tokens)

save_dicts_to_file(exempt_sensitive_views_dict, output_path_exempt_dict)
save_dicts_to_file(not_protect_sensitive_views_dict, output_path_not_protect_dict)
