# Session-Management-Analyser

This repository contains the artifacts for the paper "Behind the Curtain: A Server-Side View of Web Session Security", published at SecDec 2025. It contains all of the CodeQL queries and scripts that were developed and used for the paper. The repository is structured in the following way:
- Inside the directories `Django_Queries`, `Flask_Queries` and `CodeQL_Library` are all the CodeQL queries that were developed for the paper.
- Inside the `GitCommitAnalysis` folder there is the script used to analyze git commits regarding session protection, to see how and if the session protection setting changed over the lifetime of the web application's GitHub repository
- Inside the `GithubCrawlelyzer` folder there are the scripts used to scrape GitHub and build the initial dataset
- Inside the `SessionManagementAnalyserApp` folder there are the scripts used to filter the initial dataset, extract view function names from the CSRF results, and generate the results and numbers presented in the paper
- Inside the root of the repository there are the final datasets of web applications, both before and after (_whitelist_filtered) post-processing

To reproduce the full paper, the workflow would be the following:
1) Run the GithubCrawlelyzer to generate the initial dataset
2) Filter the initial dataset following these steps (post-processing phase):
    - Use the `csv_filter.py` script (inside the `SessionManagementAnalyserApp` folder) to filter the dataset based on repository names and owners
    - After downloading the READMEs for all repositories, use the `whitelist_filter_readme.py` (inside the `SessionManagementAnalyserApp` folder) script to filter the dataset based on README and about section content
    - (OPTIONAL) Execute the `filter_accuracies.py` script (inside the `SessionManagementAnalyserApp` folder) to compare the filters with the manually constructed ground truth, to check how accurate the automatic filters are
3) Run the queries found in the `Django_Queries` and `Flask_Queries` folders
4) Generate the results presented in the paper by running the `paper_report_django.py` and `paper_report_flask.py` scripts (inside the `SessionManagementAnalyserApp` folder)
5) Extract the most common function names for the views that enabled/disabled CSRF protection by running the `extract_unprotected_sensitive_views.py` script (inside the `SessionManagementAnalyserApp` folder)
6) Collect and analyze GitHub commits to see how the session protection setting changed over the history of a web application's repository by running the `main.py` script (inside the `GitCommitAnalysis` folder)

## CodeQL Commands

<br> 0. Install dependencies
```console
codeql pack install
```

<br> 1. Create the database
```console
codeql database create <database> --language=<language-identifier> [--threads=<num>] --source-root <application>
codeql database create ./FlaskApp-database --language=python --source-root ./FlaskApp
```

<br> 2. Run the query/queries
```console
codeql query run (--database=<database> | --dataset=<dataset>) [--output=<file.bqrs>] [--threads=<num>] <file.ql>
codeql query run --database=FlaskApp-database --output=example_query_output.bqrs ./example_query.ql
```

<br> 3. Decode the results
```console
codeql bqrs decode [--output=<file>] [--result-set=<name>] [--sort-key=<col>[,<col>...]] <file>
codeql bqrs decode --output=example_query_results.txt --format=text ./example_query_output.bqrs
```

<br> 4. Extra
<br> Show the metadata info of the bqrs file
```console
codeql bqrs info <file>
codeql bqrs info ./example_query_output.bqrs
```
