# Session-Management-Analyser

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

<br> 2. Run the query/queries (first method is preferred)
```console
codeql query run (--database=<database> | --dataset=<dataset>) [--output=<file.bqrs>] [--threads=<num>] <file.ql>
codeql query run --database=FlaskApp-database --output=example_query_output.bqrs ./example_query.ql
```

<br> 3. Decode the results (first method is preferred, the two commands differ in the output formats they support)
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
