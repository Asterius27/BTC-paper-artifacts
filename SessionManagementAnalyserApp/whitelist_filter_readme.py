from deep_translator import GoogleTranslator, MyMemoryTranslator
from nltk.stem import *
from nltk.tokenize import word_tokenize
from bs4 import BeautifulSoup
import markdown
import nltk
from pathlib import Path
import os
import csv

nltk.download('punkt')
whitelist = set(["backend", "frontend", "fullstack", "selfhost", "cloud", "ecommerce"])
group_whitelist = [["web", "application"], ["web", "app"], ["self", "host"]]
stemmer = PorterStemmer()
# csv_dir = Path(__file__).parent / "../django_filtered_list_final_v2.csv"
root_dir = "./repositories/Django"
full_path = Path(__file__).parent / root_dir
repos_dir = os.listdir(full_path.absolute())
csv_dict = {}
output_list = []

with open("../django_filtered_list_final_v2.csv") as csv_file:
    reader = csv.DictReader(csv_file, delimiter=',')
    for row in reader:
        owner = row["repo_url"].split("/")[3]
        repoName = row["repo_url"].split("/")[4]
        csv_dict[owner + "_" + repoName] = row

# to_translate = 'JumpServer 是广受欢迎的开源堡垒机，是符合 4A 规范的专业运维安全审计系统。'
# to_translate = "Hello how is it going?"
# translated = GoogleTranslator(source='auto', target='en').translate(to_translate)
# print(translated)
flag = False

# translated = GoogleTranslator(source='auto', target='english').translate_file('../README_test_translate.md')
# print(translated)

for repo_dir in repos_dir:
    readme_dir = ""
    subdir = os.listdir(str(full_path.absolute()) + "/" + repo_dir)
    repodir = os.listdir(str(full_path.absolute()) + "/" + repo_dir + "/" + subdir[0])
    for file in repodir:
        if "readme." in file.lower():
            readme_dir = str(full_path.absolute()) + "/" + repo_dir + "/" + subdir[0] + "/" + file
    # print(readme_dir)

    with open('log_whitelist_readme_filter.txt', 'r+', encoding='UTF8') as log:
        if readme_dir != "" and readme_dir not in log.read():
            with open(readme_dir, 'r') as f: # '../README_test_translate.md'
                htmlmarkdown = markdown.markdown(f.read())
                texts = [elem.text for elem in BeautifulSoup(htmlmarkdown, features="html.parser").findAll()]
                text = ' '.join(texts)
                split_text = [text[i:i+4000] for i in range(0, len(text), 4000)] # 499 for mymemory translator, 4000 for google translator (4999 gives an error for some reason)
                try:
                    translated = GoogleTranslator(source='auto', target='en').translate_batch(split_text) # TODO there might be an API limit, don't know if we will hit it
                    # translated = MyMemoryTranslator(source='auto', target='english').translate_batch(split_text)
                    # print(translated)
                    # print(text)
                    # print(len(split_text))

                    tokens = word_tokenize(' '.join(translated)) # use text (the variable) to skip translation
                    # stemmed_tokens = [stemmer.stem(token) for token in tokens]
                    # translated = [GoogleTranslator(source='auto', target='en').translate(token) for token in tokens]
                    # translated = GoogleTranslator(source='auto', target='en').translate(htmlmarkdown[:4000])
                    # print(translated)
                    processed_tokens = set([s.replace('-', '').lower() for s in tokens])
                    # print(processed_tokens)
                    stemmed_tokens = set([stemmer.stem(token) for token in processed_tokens])
                    # print(stemmed_tokens)
                    intersection1 = whitelist.intersection(processed_tokens)
                    intersection2 = whitelist.intersection(stemmed_tokens)
                    # print(intersection1)
                    # print(intersection2)
                    # print(len(intersection1))
                    # print(len(intersection2))
                    if len(intersection1) != 0:
                        flag = True
                    if len(intersection2) != 0:
                        flag = True
                    debug_list1 = []
                    debug_list2 = []
                    for whitelst in group_whitelist:
                        set_whitelst = set(whitelst)
                        intersect1 = set_whitelst.intersection(processed_tokens)
                        intersect2 = set_whitelst.intersection(stemmed_tokens)
                        if len(intersect1) == len(set_whitelst):
                            debug_list1.append(intersect1)
                            flag = True
                        if len(intersect2) == len(set_whitelst):
                            debug_list2.append(intersect2)
                            flag = True
                        # print(set_whitelst)
                        # print(len(intersect1))
                        # print(len(intersect2))
                    log.write(readme_dir + "\n")
                    log.write(str(processed_tokens) + "\n")
                    log.write(str(stemmed_tokens) + "\n")
                    log.write(str(intersection1) + "\n")
                    log.write(str(intersection2) + "\n")
                    log.write(str(debug_list1) + "\n")
                    log.write(str(debug_list2) + "\n")
                    log.write(str(flag) + "\n\n\n")
                    # print(flag)
                    if flag:
                        print(readme_dir.split("/")[-3])
                        # print(csv_dict[readme_dir.split("/")[-3]])
                        output_list.append(csv_dict[readme_dir.split("/")[-3]].values())
                except Exception as e:
                    print("Google translate api exception")
                    print(e)
    
with open('whitelist_filtered_repos.csv', 'w', encoding='UTF8') as f:
    writer = csv.writer(f)
    for row in output_list:
        writer.writerow(row)
