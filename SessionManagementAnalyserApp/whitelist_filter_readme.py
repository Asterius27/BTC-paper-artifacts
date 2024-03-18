from deep_translator import GoogleTranslator, MyMemoryTranslator
from nltk.stem import *
from nltk.tokenize import word_tokenize
from bs4 import BeautifulSoup
import markdown
import nltk
from pathlib import Path
import os
import csv
import time
import sys

# TODO add languages in the filter

maxInt = sys.maxsize
while True:
    # decrease the maxInt value by factor 10 
    # as long as the OverflowError occurs.
    try:
        csv.field_size_limit(maxInt)
        break
    except OverflowError:
        maxInt = int(maxInt/10)

nltk.download('punkt')
whitelist = set(["backend", "frontend", "fullstack", "selfhost", "ecommerce", "cloud", "platform", "cms", "localhost", "forum", "collaborative", "bulletin"])
group_whitelist = [["web", "application"], ["web", "app"], ["self", "host"], ["content", "management", "system"]]
blacklist = set(["library", "tutorial", "docs", "ctf", "test", "challenge", "demo", "example", "sample", "bootcamp", "assignment", "workshop", "homework", "course", "exercise", "hack", "vulnerable", "snippet", "internship", "programming", "book", "cybersecurity", "100daysofcode"]) # "api"
stemmer = PorterStemmer()
# csv_dir = Path(__file__).parent / "../django_filtered_list_final_v2.csv"
root_dir = "./repositories/Flask_READMEs"
full_path = Path(__file__).parent / root_dir
repos_dir = os.listdir(full_path.absolute())
csv_dict = {}
# output_list = []
exceptions = 0

"""
with open("../test_READMEs/README_to_fix_2.md", 'r') as f:
    htmlmarkdown = markdown.markdown(f.read())
    texts = [elem.text for elem in BeautifulSoup(htmlmarkdown, features="html.parser").findAll()]
    text = ' '.join(texts)
    # print(text)
    split_text = [text[i:i+2000] for i in range(0, len(text), 2000)] # 499 for mymemory translator, 2000 for google translator (anything above that you're at risk of getting an api error for unknown reasons)
    # for i in range(len(split_text)):
    #     translated = GoogleTranslator(source='auto', target='en').translate(split_text[i])
    #     print(translated)
    #     print(i)
    #     time.sleep(90)
    # print(split_text[2])
    # translated = GoogleTranslator(source='auto', target='en').translate(split_text[2])
    translated = GoogleTranslator(source='auto', target='en').translate_batch(split_text)
    print(' '.join(translated))
    print(len(split_text))
"""


file = open('log_whitelist_readme_filter.txt', 'a')
file.close()

if not os.path.isfile('./whitelist_filtered_repos.csv'):
    with open('whitelist_filtered_repos.csv', 'a', encoding='UTF8') as output:
        output.write("repo_name,repo_url,stars,contributors,commits,update_date,forks\n") # TODO jsonb_agg_lang,jsonb_agg_readme
"""
if not os.path.isfile('./blacklist_filtered_repos.csv'):
    with open('blacklist_filtered_repos.csv', 'a', encoding='UTF8') as output:
        output.write("repo_url\n") # TODO repo_name,repo_url,stars,contributors,commits,update_date,forks,jsonb_agg_lang,jsonb_agg_readme
if not os.path.isfile('./whitelist_and_blacklist_filtered_repos.csv'):
    with open('whitelist_and_blacklist_filtered_repos.csv', 'a', encoding='UTF8') as output:
        output.write("repo_url\n") # TODO repo_name,repo_url,stars,contributors,commits,update_date,forks,jsonb_agg_lang,jsonb_agg_readme
"""

with open("../flask_login_final_filtered_merged_list_w_lang_and_readme_and_desc.csv", encoding='utf8') as csv_file:
    reader = csv.DictReader(csv_file, delimiter=',')
    for row in reader:
        owner = row["repo_url"].split("/")[3]
        repoName = row["repo_url"].split("/")[4]
        csv_dict[owner + "_" + repoName] = row

# to_translate = 'JumpServer 是广受欢迎的开源堡垒机，是符合 4A 规范的专业运维安全审计系统。'
# to_translate = "Hello how is it going?"
# translated = GoogleTranslator(source='auto', target='en').translate(to_translate)
# print(translated)

# translated = GoogleTranslator(source='auto', target='english').translate_file('../README_test_translate.md')
# print(translated)

for repo_dir in repos_dir:
    flag_whitelist = False
    # flag_blacklist = False
    readme_dir = ""
    subdir = os.listdir(str(full_path.absolute()) + "/" + repo_dir)
    # repodir = os.listdir(str(full_path.absolute()) + "/" + repo_dir + "/" + subdir[0])
    if len(subdir) == 1:
        for file in subdir:
            readme_dir = str(full_path.absolute()) + "/" + repo_dir + "/" + file
    else:
        for file in subdir:
            if "translated" in file:
                readme_dir = str(full_path.absolute()) + "/" + repo_dir + "/" + file
    print(readme_dir)

    with open('log_whitelist_readme_filter.txt', 'r+', encoding='UTF8') as log:
        if readme_dir != "" and readme_dir not in log.read():
            try:
                with open(readme_dir, 'r') as f: # '../README_test_translate.md' , encoding='utf8'
                    if len(f.readlines()) > 3:
                        f.seek(0) # not sure if this is needed
                        if "translated" not in readme_dir.split("/")[-1]:
                            htmlmarkdown = markdown.markdown(f.read()) # TODO test to see if this works even with rst or other non md files
                            texts = [elem.text for elem in BeautifulSoup(htmlmarkdown, features="html.parser").findAll()]
                            text = ' '.join(texts)
                            split_text = [text[i:i+1700] for i in range(0, len(text), 1700)] # 499 for mymemory translator, 2000 for google translator (anything above that you're at risk of getting an api error for unknown reasons)
                            translated = GoogleTranslator(source='auto', target='en').translate_batch(split_text) # TODO there might be an API limit, don't know if we will hit it
                            # translated = MyMemoryTranslator(source='auto', target='english').translate_batch(split_text)
                            # print(translated)
                            # print(text)
                            # print(len(split_text))

                            tokens = word_tokenize(' '.join(translated)) # use text (the variable) to skip translation
                            readme_subdir = readme_dir.split("/")
                            readme_name = readme_subdir.pop(-1).split(".")
                            translated_readme_dir = '/'.join(readme_subdir) + "/" + readme_name[0] + "_translated." + ''.join(readme_name[1:])
                            print(translated_readme_dir)
                            with open(translated_readme_dir, 'w') as translated_file:
                                translated_file.write(' '.join(translated))
                        else:
                            tokens = word_tokenize(f.read())
                        # stemmed_tokens = [stemmer.stem(token) for token in tokens]
                        # translated = [GoogleTranslator(source='auto', target='en').translate(token) for token in tokens]
                        # translated = GoogleTranslator(source='auto', target='en').translate(htmlmarkdown[:4000])
                        # print(translated)
                        about = csv_dict[readme_dir.split("/")[-2]]["description"]
                        tokens_about = word_tokenize(about)
                        processed_tokens_about = set([s.replace('-', '').lower() for s in tokens_about])
                        stemmed_tokens_about = set([stemmer.stem(token) for token in processed_tokens_about])
                        processed_tokens = set([s.replace('-', '').lower() for s in tokens])
                        # print(processed_tokens)
                        stemmed_tokens = set([stemmer.stem(token) for token in processed_tokens])
                        # print(stemmed_tokens)
                        intersection1 = whitelist.intersection(processed_tokens)
                        intersection2 = whitelist.intersection(stemmed_tokens)
                        # intersection3 = blacklist.intersection(processed_tokens)
                        # intersection4 = blacklist.intersection(stemmed_tokens)
                        # print(intersection1)
                        # print(intersection2)
                        # print(len(intersection1))
                        # print(len(intersection2))
                        if len(intersection1) != 0:
                            flag_whitelist = True
                        if len(intersection2) != 0:
                            flag_whitelist = True
                        debug_list1 = []
                        debug_list2 = []
                        for whitelst in group_whitelist:
                            set_whitelst = set(whitelst)
                            intersect1 = set_whitelst.intersection(processed_tokens)
                            intersect2 = set_whitelst.intersection(stemmed_tokens)
                            if len(intersect1) == len(set_whitelst):
                                debug_list1.append(intersect1)
                                flag_whitelist = True
                            if len(intersect2) == len(set_whitelst):
                                debug_list2.append(intersect2)
                                flag_whitelist = True
                            # print(set_whitelst)
                            # print(len(intersect1))
                            # print(len(intersect2))
                        """
                        if len(intersection3) != 0:
                            flag_blacklist = True
                        if len(intersection4) != 0:
                            flag_blacklist = True
                        """
                        log.write(readme_dir + "\n")
                        log.write(str(processed_tokens) + "\n")
                        log.write(str(stemmed_tokens) + "\n")
                        log.write("Whitelist intersection: " + str(intersection1) + "\n")
                        log.write("Whitelist intersection: " + str(intersection2) + "\n")
                        log.write(str(debug_list1) + "\n")
                        log.write(str(debug_list2) + "\n")
                        if not flag_whitelist:
                            intersection1b = whitelist.intersection(processed_tokens_about)
                            intersection2b = whitelist.intersection(stemmed_tokens_about)
                            if len(intersection1b) != 0:
                                flag_whitelist = True
                            if len(intersection2b) != 0:
                                flag_whitelist = True
                            debug_list1b = []
                            debug_list2b = []
                            for whitelst in group_whitelist:
                                set_whitelst = set(whitelst)
                                intersect1b = set_whitelst.intersection(processed_tokens_about)
                                intersect2b = set_whitelst.intersection(stemmed_tokens_about)
                                if len(intersect1b) == len(set_whitelst):
                                    debug_list1b.append(intersect1b)
                                    flag_whitelist = True
                                if len(intersect2b) == len(set_whitelst):
                                    debug_list2b.append(intersect2b)
                                    flag_whitelist = True
                            log.write("About Section: ---------------------------------------\n")
                            log.write(str(processed_tokens_about) + "\n")
                            log.write(str(stemmed_tokens_about) + "\n")
                            log.write("Whitelist intersection: " + str(intersection1b) + "\n")
                            log.write("Whitelist intersection: " + str(intersection2b) + "\n")
                            log.write(str(debug_list1b) + "\n")
                            log.write(str(debug_list2b) + "\n")
                        # log.write("Blacklist intersection: " + str(intersection3) + "\n")
                        # log.write("Blacklist intersection: " + str(intersection4) + "\n")
                        # log.write("Blacklist flag: " + str(flag_blacklist) + "\n\n\n")
                        # print(flag)
                        intersection3b = blacklist.intersection(processed_tokens_about)
                        intersection4b = blacklist.intersection(stemmed_tokens_about)
                        if len(intersection3b) != 0:
                            flag_whitelist = False
                        if len(intersection4b) != 0:
                            flag_whitelist = False
                        log.write("Blacklist intersection in the about section: " + str(intersection3b) + "\n")
                        log.write("Blacklist intersection in the about section: " + str(intersection4b) + "\n")
                        if len(about) == 0:
                            flag_whitelist = False
                            log.write("Description length: " + str(len(about)) + "\n")
                        log.write("Whitelist flag: " + str(flag_whitelist) + "\n\n\n")
                        """
                        if flag_whitelist and not flag_blacklist:
                            print(readme_dir.split("/")[-2])
                            # print(csv_dict[readme_dir.split("/")[-3]])
                            # output_list.append(csv_dict[readme_dir.split("/")[-3]].values())
                            with open('whitelist_and_blacklist_filtered_repos.csv', 'a', encoding='UTF8') as output:
                                writer = csv.writer(output)
                                writer.writerow([csv_dict[readme_dir.split("/")[-2]]["repo_url"]]) # TODO .values()
                        """
                        if flag_whitelist: # elif
                            print(readme_dir.split("/")[-2])
                            with open('whitelist_filtered_repos.csv', 'a', encoding='UTF8') as output:
                                writer = csv.writer(output)
                                """ TODO
                                writer.writerow([csv_dict[readme_dir.split("/")[-2]]["repo_name"],
                                                 csv_dict[readme_dir.split("/")[-2]]["repo_url"],
                                                 csv_dict[readme_dir.split("/")[-2]]["stars"],
                                                 csv_dict[readme_dir.split("/")[-2]]["contributors"],
                                                 csv_dict[readme_dir.split("/")[-2]]["commits"],
                                                 csv_dict[readme_dir.split("/")[-2]]["update_date"],
                                                 csv_dict[readme_dir.split("/")[-2]]["forks"]])
                                """
                                writer.writerow([csv_dict[readme_dir.split("/")[-2]]["repo_url"]])
                        """
                        elif not flag_blacklist:
                            with open('blacklist_filtered_repos.csv', 'a', encoding='UTF8') as output:
                                writer = csv.writer(output)
                                writer.writerow([csv_dict[readme_dir.split("/")[-2]]["repo_url"]]) # TODO .values()
                        """
            except Exception as e:
                exceptions += 1
                print(e)
                with open('log_exceptions_whitelist_readme_filter.txt', 'a', encoding='UTF8') as exception_log:
                    exception_log.write(readme_dir + "\n")
                    exception_log.write(str(e) + "\n")

"""
with open('whitelist_filtered_repos.csv', 'w', encoding='UTF8') as f:
    writer = csv.writer(f)
    for row in output_list:
        writer.writerow(row)
"""

with open('log_exceptions_whitelist_readme_filter.txt', 'a', encoding='UTF8') as exception_log:
    exception_log.write("Total number of exceptions: " + str(exceptions))
