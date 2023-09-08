# Session-Management-Analyser

## Launch Session Management Analyser App

```console
npm start
```

## Launch Flask App

```console
(python -m) flask --app app run
```

## Launch Django App

```console
python manage.py runserver
```

## CodeQL Commands

<br> 1. Create the database
```console
codeql database create <database> --language=<language-identifier> [--threads=<num>] --source-root <application>
codeql database create ./FlaskApp-database --language=python --source-root ./FlaskApp
```

<br> 2. Run the query/queries (first method is preferred)
```console
codeql query run (--database=<database> | --dataset=<dataset>) [--output=<file.bqrs>] [--threads=<num>] <file.ql>
codeql query run --database=FlaskApp-database --output=example_query_output.bqrs ./example_query.ql
```
or
```console
codeql database analyze ./FlaskApp-database ./example_query.ql --format=csv --output=results.csv
```
or you can run all of the ql files contained in a directory (the bqrs output files are saved in the results folder inside the database folder)
```console
codeql database run-queries <database> <query|dir|suite|pack>
codeql database run-queries ./FlaskApp-database ./Flask_Queries
```

<br> 3. Decode the results (first method is preferred, the two commands differ in the output formats they support)
```console
codeql bqrs decode [--output=<file>] [--result-set=<name>] [--sort-key=<col>[,<col>...]] <file>
codeql bqrs decode --output=example_query_results.txt --format=text ./example_query_output.bqrs
```
or (though it is better to use database analyze that does everything automatically)
```console
codeql bqrs interpret --format=<format> --output=<output> -t=<String=String> <bqrs-file>
codeql bqrs interpret --format=csv --output=example_query_results.csv -t=kind=if -t=id=1 ./example_query_output.bqrs
```

<br> 4. Extra
<br><br> Run an analysis using the queries provided by codeql
```console
codeql database analyze <database> --format=<format> --output=<output>
codeql database analyze ./FlaskApp-database --format=sarif-latest --output=flaskapp-analysis.sarif
```

<br> Show the metadata info of the bqrs file
```console
codeql bqrs info <file>
codeql bqrs info ./example_query_output.bqrs
```
