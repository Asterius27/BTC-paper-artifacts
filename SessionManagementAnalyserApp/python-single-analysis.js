import * as fs from 'fs';
import { execSync } from "child_process";
import { getFlaskQueries, getDjangoQueries } from './python-datastructures.js';
import { generateReport } from './python-generate-report.js';

const FLASK_QUERIES_DIR = "../Flask_Queries";
const DJANGO_QUERIES_DIR = "../Django_Queries";

function execBoolQuery(database, outputLocation, queryLocation, queryName, threads) {
    // comment the following two lines to re-generate the html report without re-running the queries (have to run the queries at least once before generating the html report)
    execSync("codeql query run --database=" + database + " --output=" + outputLocation + "/" + queryName + ".bqrs --threads=" + threads + " " + queryLocation + "/" + queryName + ".ql", { timeout: 1200000 });
    execSync("codeql bqrs decode --output=" + outputLocation + "/" + queryName + ".txt --format=text " + outputLocation + "/" + queryName + ".bqrs"); // TODO change this to JSON
    let lines = fs.readFileSync(outputLocation + "/" + queryName + ".txt", 'utf-8').split("\n");
    lines.pop();
    if (lines.length > 2) {
        let res = "";
        for (let i = 2; i < lines.length; i++) {
            res = res + lines[i] + "\n";
        }
        return [true, res];
    } else {
        return [false, ""];
    }
}

// TODO This might break if the query names differ too much (if the shortest name has more than one different word at the end)
function getUnskippableCounterpart(skippableQueryName, queryObj) {
    let actualSkipQueryName = skippableQueryName.slice(2);
    for (let [queryName, arr] of Object.entries(queryObj)) {
        if (queryName.startsWith("u")) {
            let actualQueryName = queryName.slice(3);
            if (actualQueryName.length > actualSkipQueryName.length) {
                if (actualQueryName.includes(actualSkipQueryName)) {
                    fs.appendFileSync('./log.txt', "Skippable Query: " + skippableQueryName + ", Unskippable counterpart: " + queryName + "\n");
                    return queryName;
                }
                let shortSkipQueryName = actualSkipQueryName.substring(0, actualSkipQueryName.lastIndexOf("_"));
                if (actualQueryName.includes(shortSkipQueryName)) {
                    fs.appendFileSync('./log.txt', "Skippable Query: " + skippableQueryName + ", Unskippable counterpart: " + queryName + "\n");
                    return queryName;
                }
            } else {
                if (actualSkipQueryName.includes(actualQueryName)) {
                    fs.appendFileSync('./log.txt', "Skippable Query: " + skippableQueryName + ", Unskippable counterpart: " + queryName + "\n");
                    return queryName;
                }
                let shortQueryName = actualQueryName.substring(0, actualQueryName.lastIndexOf("_"));
                if (actualSkipQueryName.includes(shortQueryName)) {
                    fs.appendFileSync('./log.txt', "Skippable Query: " + skippableQueryName + ", Unskippable counterpart: " + queryName + "\n");
                    return queryName;
                }
            }
        }
    }
    fs.appendFileSync('./log.txt', "Error when trying to find the unskippable counterpart to the query: " + skippableQueryName + "\n");
    throw new Error("Something went wrong when trying to find the unskippable counterpart to a skippable query");
}

export function pythonAnalysis(root_dir, threads) {
    if (!fs.existsSync(root_dir + "-results")){
        fs.mkdirSync(root_dir + "-results");
    }
    let flask_lib = [false, ""];
    let django_lib = [false, ""];
    let flask_queries = {};
    let django_queries = {};
    try {
        flask_lib = execBoolQuery(root_dir + "-database", root_dir + "-results", FLASK_QUERIES_DIR + "/Flask-login-is-used-check", "flask_library_used_check", threads);
    } catch(e) {
        flask_lib = [false, ""];
    }
    try {
        django_lib = execBoolQuery(root_dir + "-database", root_dir + "-results", DJANGO_QUERIES_DIR + "/Django-auth-is-used-check", "django_library_used_check", threads);
    } catch(e) {
        django_lib = [false, ""];
    }
    if (!flask_lib[0] && !django_lib[0]) {
        throw new Error("None of the supported libraries/frameworks is used");
    }
    fs.writeFileSync(root_dir + "-results/info.txt", "python");
    if (flask_lib[0]) {
        flask_queries = getFlaskQueries();
        for (let [key, value] of Object.entries(flask_queries)) {
            for (let [dir, files] of Object.entries(value)) {
                if (!fs.existsSync(root_dir + "-results/" + dir)){
                    fs.mkdirSync(root_dir + "-results/" + dir);
                }
                for (let [file, arr] of Object.entries(files)) {
                    if (file.startsWith("u")) {
                        try {
                            let res = execBoolQuery(root_dir + "-database", root_dir + "-results/" + dir, FLASK_QUERIES_DIR + "/" + dir, file, threads);
                            flask_queries[key][dir][file] = res;
                        } catch(e) {
                            flask_queries[key][dir][file] = [true, "The query threw an exception error and didn't complete"];
                            fs.appendFileSync('./log.txt', "Failed to execute the query: " + dir + "/" + file + " on repository: " + root_dir + " Reason: " + e + "\n");
                        }
                    } else {
                        let twin = getUnskippableCounterpart(file, files);
                        if ((twin.startsWith("uf") && !flask_queries[key][dir][twin][0]) || (twin.startsWith("ut") && flask_queries[key][dir][twin][0])) {
                            try {
                                let res = execBoolQuery(root_dir + "-database", root_dir + "-results/" + dir, FLASK_QUERIES_DIR + "/" + dir, file, threads);
                                flask_queries[key][dir][file] = res;
                            } catch(e) {
                                flask_queries[key][dir][file] = [true, "The query threw an exception error and didn't complete"];
                                fs.appendFileSync('./log.txt', "Failed to execute the query: " + dir + "/" + file + " on repository: " + root_dir + " Reason: " + e + "\n");
                            }
                        } else {
                            // TODO generate the fake/deduced results, both the txt file and the dictionary entry (flask_queries)
                        }
                    }
                }
            }
        }
        generateReport(flask_queries, "Flask/Flask-login", root_dir + "-results");
        fs.appendFileSync(root_dir + "-results/info.txt", ", flask");
    }
    if (django_lib[0]) {
        let session_engine = execBoolQuery(root_dir + "-database", root_dir + "-results", DJANGO_QUERIES_DIR + "/Custom-session-engine", "custom_session_engine", threads);
        if (session_engine[0]) {
            fs.appendFileSync(root_dir + "-results/info.txt", ", django, customsessionengine");
            throw new Error("Using a custom session engine, so the analysis won't be run");
        }
        django_queries = getDjangoQueries();
        for (let [key, value] of Object.entries(django_queries)) {
            for (let [dir, files] of Object.entries(value)) {
                if (!fs.existsSync(root_dir + "-results/" + dir)){
                    fs.mkdirSync(root_dir + "-results/" + dir);
                }
                for (let [file, arr] of Object.entries(files)) {
                    try {
                        let res = execBoolQuery(root_dir + "-database", root_dir + "-results/" + dir, DJANGO_QUERIES_DIR + "/" + dir, file, threads);
                        django_queries[key][dir][file] = res;
                    } catch(e) {
                        django_queries[key][dir][file] = [true, "The query threw an exception error and didn't complete"];
                        fs.appendFileSync('./log.txt', "Failed to execute the query: " + dir + "/" + file + " on repository: " + root_dir + " Reason: " + e + "\n");
                    }
                }
            }
        }
        generateReport(django_queries, "Django", root_dir + "-results");
        fs.appendFileSync(root_dir + "-results/info.txt", ", django");
    }
}
