from pathlib import Path
import sys
import csv

maxInt = sys.maxsize
while True:
    # decrease the maxInt value by factor 10 
    # as long as the OverflowError occurs.
    try:
        csv.field_size_limit(maxInt)
        break
    except OverflowError:
        maxInt = int(maxInt/10)

def getPercentage(value, total):
    if total == 0:
        return 0
    return round((value / total) * 100, 2)

def loadGPTCSV(csvFile, answer):
    repos = []
    with csvFile.open(encoding="utf8") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            if row["answer"] == answer:
                repos.append(row["repo_name"])
    return set(repos)

def loadCSV(csvFile):
    repos = []
    with csvFile.open(encoding="utf8") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            repos.append(row["repo_name"])
    return set(repos)

unfiltered_list = loadCSV(Path(__file__).parent / './filtered_lists_to_calculate_accuracy/Session Management Repos - Django.csv')
manual_filtered_list_true_positives = loadCSV(Path(__file__).parent / './filtered_lists_to_calculate_accuracy/Session Management Repos - Django Filtered.csv')
manual_filtered_list_true_negatives = unfiltered_list.difference(manual_filtered_list_true_positives)

gpt_filtered_list_positives = loadGPTCSV(Path(__file__).parent / './filtered_lists_to_calculate_accuracy/Session Management Repos - Django_GPT.csv', "yes")
gpt_filtered_list_negatives = loadGPTCSV(Path(__file__).parent / './filtered_lists_to_calculate_accuracy/Session Management Repos - Django_GPT.csv', "no")

whitelist_filtered_list_positives = unfiltered_list.intersection(loadCSV(Path(__file__).parent / '../new_lists/django_whitelist_filtered.csv'))
whitelist_filtered_list_negatives = unfiltered_list.intersection(loadCSV(Path(__file__).parent / '../new_lists/django.csv')).difference(whitelist_filtered_list_positives)

print(len(unfiltered_list))
print(len(manual_filtered_list_true_positives))
print(len(manual_filtered_list_true_negatives))
print(len(gpt_filtered_list_positives))
print(len(gpt_filtered_list_negatives))
print(len(whitelist_filtered_list_positives))
print(len(whitelist_filtered_list_negatives))
print("\n")
true_positives_gpt = len(gpt_filtered_list_positives.intersection(manual_filtered_list_true_positives))
false_positives_gpt = len(gpt_filtered_list_positives) - true_positives_gpt
true_negatives_gpt = len(gpt_filtered_list_negatives.intersection(manual_filtered_list_true_negatives))
false_negatives_gpt = len(gpt_filtered_list_negatives) - true_negatives_gpt
true_positives_whitelist = len(whitelist_filtered_list_positives.intersection(manual_filtered_list_true_positives))
false_positives_whitelist = len(whitelist_filtered_list_positives) - true_positives_whitelist
true_negatives_whitelist = len(whitelist_filtered_list_negatives.intersection(manual_filtered_list_true_negatives))
false_negatives_whitelist = len(whitelist_filtered_list_negatives) - true_negatives_whitelist
print("List length: " + str(len(unfiltered_list)))
print("Positives (Actual web applications according to manual analysis): " + str(len(manual_filtered_list_true_positives)))
print("Negatives (Not web applications according to manual analysis): " + str(len(manual_filtered_list_true_negatives)))
print("\n")
print("GPT True Positives: " + str(true_positives_gpt))
print("GPT False Positives: " + str(false_positives_gpt))
print("GPT True Negatives: " + str(true_negatives_gpt))
print("GPT False Negatives: " + str(false_negatives_gpt))
print("GPT Accuracy: " + str(getPercentage(true_positives_gpt + true_negatives_gpt, len(unfiltered_list))) + " %")
print("GPT Misclassification: " + str(getPercentage(false_positives_gpt + false_negatives_gpt, len(unfiltered_list))) + " %")
print("GPT True Positive Rate (Sensitivity or Recall): " + str(getPercentage(true_positives_gpt, true_positives_gpt + false_negatives_gpt)) + " %")
print("GPT True Negatives Rate (Specificity): " + str(getPercentage(true_negatives_gpt, true_negatives_gpt + false_positives_gpt)) + " %")
print("GPT Positive Predictive Value (Precision): " + str(getPercentage(true_positives_gpt, true_positives_gpt + false_positives_gpt)) + " %")
print("GPT Negative Predictive Value: " + str(getPercentage(true_negatives_gpt, true_negatives_gpt + false_negatives_gpt)) + " %")
print("GPT F1 Score: " + str(getPercentage(true_positives_gpt, true_positives_gpt + 0.5*(false_positives_gpt + false_negatives_gpt))) + " %")
print("\n")
print("Whitelist True Positives: " + str(true_positives_whitelist))
print("Whitelist False Positives: " + str(false_positives_whitelist))
print("Whitelist True Negatives: " + str(true_negatives_whitelist))
print("Whitelist False Negatives: " + str(false_negatives_whitelist))
print("Whitelist Accuracy: " + str(getPercentage(true_positives_whitelist + true_negatives_whitelist, len(unfiltered_list))) + " %")
print("Whitelist Misclassification: " + str(getPercentage(false_positives_whitelist + false_negatives_whitelist, len(unfiltered_list))) + " %")
print("Whitelist True Positive Rate (Sensitivity or Recall): " + str(getPercentage(true_positives_whitelist, true_positives_whitelist + false_negatives_whitelist)) + " %")
print("Whitelist True Negatives Rate (Specificity): " + str(getPercentage(true_negatives_whitelist, true_negatives_whitelist + false_positives_whitelist)) + " %")
print("Whitelist Positive Predictive Value (Precision): " + str(getPercentage(true_positives_whitelist, true_positives_whitelist + false_positives_whitelist)) + " %")
print("Whitelist Negative Predictive Value: " + str(getPercentage(true_negatives_whitelist, true_negatives_whitelist + false_negatives_whitelist)) + " %")
print("Whitelist F1 Score: " + str(getPercentage(true_positives_whitelist, true_positives_whitelist + 0.5*(false_positives_whitelist + false_negatives_whitelist))) + " %")
print("\n")
"""
print(whitelist_filtered_list_positives.intersection(manual_filtered_list_true_positives))
print("\n")
print(whitelist_filtered_list_negatives.intersection(manual_filtered_list_true_negatives))
print("\n")
print(whitelist_filtered_list_positives.difference(whitelist_filtered_list_positives.intersection(manual_filtered_list_true_positives)))
print("\n")
print(whitelist_filtered_list_negatives.difference(whitelist_filtered_list_negatives.intersection(manual_filtered_list_true_negatives)))
print("\n")
"""
