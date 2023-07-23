# Session-Management-Analyser

## Launch FLask App

flask --app hello run

## CodeQL Commands

codeql database create \<database\> --language=\<language-identifier\><br>
codeql database create ./FlaskApp-database --language=python --source-root ./FlaskApp

(This is not needed, it runs an analysis using the queries provided by codeql)<br>
codeql database analyze \<database\> --format=\<format\> --output=\<output\><br>
codeql database analyze ./FlaskApp-database --format=sarif-latest --output=flaskapp-analysis.sarif

(First one is preferred)<br>
codeql query run (--database=\<database\> | --dataset=\<dataset\>) [--output=<file.bqrs>] \<file.ql\><br>
codeql query run --database=FlaskApp-database --output=example_query_output.bqrs ./example_query.ql
or
codeql database analyze ./FlaskApp-database ./example_query.ql --format=csv --output=results.csv<br>
or you can run all of the ql files contained in a directory (the bqrs output files are saved in the results folder inside the database folder)<br>
codeql database run-queries \<database\> \<query|dir|suite|pack\><br>
codeql database run-queries ./FlaskApp-database ./Flask_Queries

(This is not needed, it just shows metadata info of the bqrs file)<br>
codeql bqrs info \<file\><br>
codeql bqrs info ./example_query_output.bqrs

(First one is preferred, the two commands differ in the output formats they support)<br>
codeql bqrs decode \[--output=\<file\>\] \[--result-set=\<name\>\] \[--sort-key=\<col\>\[,\<col\>...\]\] \<file\><br>
codeql bqrs decode --output=example_query_results.txt --format=text ./example_query_output.bqrs<br>
or (though it is better to use database analyze that does everything automatically)<br>
codeql bqrs interpret --format=\<format\> --output=\<output\> -t=\<String=String\> \<bqrs-file\><br>
codeql bqrs interpret --format=csv --output=example_query_results.csv -t=kind=if -t=id=1 ./example_query_output.bqrs
