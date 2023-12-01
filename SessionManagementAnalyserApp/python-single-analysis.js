import * as fs from 'fs';
import { execSync } from "child_process";
import { getFlaskQueries, getDjangoQueries } from './python-datastructures.js';
import { generateReport } from './python-generate-report.js';

const FLASK_QUERIES_DIR = "../Flask_Queries";
const DJANGO_QUERIES_DIR = "../Django_Queries";

function execBoolQuery(database, outputLocation, queryLocation, queryName, threads, current_thread) {
    let startTime = new Date();
    // comment the following two lines to re-generate the html report without re-running the queries (have to run the queries at least once before generating the html report)
    execSync("codeql query run --database=" + database + " --output=" + outputLocation + "/" + queryName + ".bqrs --threads=" + threads + " " + queryLocation + "/" + queryName + ".ql", { timeout: 1200000 });
    execSync("codeql bqrs decode --output=" + outputLocation + "/" + queryName + ".txt --format=text " + outputLocation + "/" + queryName + ".bqrs"); // TODO change this to JSON
    let endTime = new Date();
    let timeElapsed = (endTime - startTime)/1000;
    fs.appendFileSync('./log' + current_thread + '_queries.txt', "Time taken to run the query " + queryLocation + " - " + queryName + " : " + timeElapsed + " seconds. Repo: " + outputLocation + "\n");
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

export function pythonAnalysis(root_dir, threads, current_thread) {
    if (!fs.existsSync(root_dir + "-results")){
        fs.mkdirSync(root_dir + "-results");
    }
    let flask_lib = [false, ""];
    let django_lib = [false, ""];
    let flask_queries = {};
    let django_queries = {};
    try {
        flask_lib = execBoolQuery(root_dir + "-database", root_dir + "-results", FLASK_QUERIES_DIR + "/Flask-login-is-used-check", "flask_library_used_check", threads, current_thread);
    } catch(e) {
        flask_lib = [false, ""];
    }
    try {
        django_lib = execBoolQuery(root_dir + "-database", root_dir + "-results", DJANGO_QUERIES_DIR + "/Django-auth-is-used-check", "django_library_used_check", threads, current_thread);
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
                    try {
                        let res = execBoolQuery(root_dir + "-database", root_dir + "-results/" + dir, FLASK_QUERIES_DIR + "/" + dir, file, threads, current_thread);
                        flask_queries[key][dir][file] = res;
                    } catch(e) {
                        flask_queries[key][dir][file] = [true, "The query threw an exception error and didn't complete"];
                        fs.appendFileSync('./log' + current_thread + '.txt', "Failed to execute the query: " + dir + "/" + file + " on repository: " + root_dir + " Reason: " + e + "\n");
                    }
                }
            }
        }
        generateReport(flask_queries, "Flask/Flask-login", root_dir + "-results");
        fs.appendFileSync(root_dir + "-results/info.txt", ", flask");
    }
    if (django_lib[0]) {
        let session_engine = execBoolQuery(root_dir + "-database", root_dir + "-results", DJANGO_QUERIES_DIR + "/Custom-session-engine", "custom_session_engine", threads, current_thread);
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
                        let res = execBoolQuery(root_dir + "-database", root_dir + "-results/" + dir, DJANGO_QUERIES_DIR + "/" + dir, file, threads, current_thread);
                        django_queries[key][dir][file] = res;
                    } catch(e) {
                        django_queries[key][dir][file] = [true, "The query threw an exception error and didn't complete"];
                        fs.appendFileSync('./log' + current_thread + '.txt', "Failed to execute the query: " + dir + "/" + file + " on repository: " + root_dir + " Reason: " + e + "\n");
                    }
                }
            }
        }
        generateReport(django_queries, "Django", root_dir + "-results");
        fs.appendFileSync(root_dir + "-results/info.txt", ", django");
    }
}
