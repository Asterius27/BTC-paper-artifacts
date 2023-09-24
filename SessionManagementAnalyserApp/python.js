import * as fs from 'fs';
import { execSync } from "child_process";
import { getFlaskQueries, getDjangoQueries } from './python-datastructures.js';
import { generateReport } from './python-generate-report.js';

const FLASK_QUERIES_DIR = "../Flask_Queries";
const DJANGO_QUERIES_DIR = "../Django_Queries";

function execBoolQuery(database, outputLocation, queryLocation, queryName) {
    // execSync("codeql query run --database=" + database + " --output=" + outputLocation + "/" + queryName + ".bqrs " + queryLocation + "/" + queryName + ".ql");
    // execSync("codeql bqrs decode --output=" + outputLocation + "/" + queryName + ".txt --format=text " + outputLocation + "/" + queryName + ".bqrs");
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

export function pythonAnalysis(root_dir) {
    if (!fs.existsSync(root_dir + "-results")){
        fs.mkdirSync(root_dir + "-results");
    }
    let flask_lib = [false, ""];
    let django_lib = [false, ""];
    let flask_queries = {};
    let django_queries = {};
    try {
        flask_lib = execBoolQuery(root_dir + "-database", root_dir + "-results", FLASK_QUERIES_DIR + "/Flask-login-is-used-check", "flask_library_used_check");
        django_lib = execBoolQuery(root_dir + "-database", root_dir + "-results", DJANGO_QUERIES_DIR + "/Django-auth-is-used-check", "django_library_used_check");
    } catch(e) {
        throw new Error("None of the supported libraries/frameworks is used");
    }
    if (!flask_lib[0] && !django_lib[0]) {
        throw new Error("None of the supported libraries/frameworks is used");
    }
    if (flask_lib[0]) {
        flask_queries = getFlaskQueries();
        for (let [key, value] of Object.entries(flask_queries)) {
            for (let [dir, files] of Object.entries(value)) {
                if (!fs.existsSync(root_dir + "-results/" + dir)){
                    fs.mkdirSync(root_dir + "-results/" + dir);
                }
                for (let [file, arr] of Object.entries(files)) {
                    try {
                        let res = execBoolQuery(root_dir + "-database", root_dir + "-results/" + dir, FLASK_QUERIES_DIR + "/" + dir, file);
                        flask_queries[key][dir][file] = res;
                    } catch(e) {
                        flask_queries[key][dir][file] = [true, "The query threw an execution error and didn't complete"];
                    }
                }
            }
        }
        generateReport(flask_queries, "Flask/Flask-login", root_dir + "-results");
    }
    if (django_lib[0]) {
        django_queries = getDjangoQueries();
        // TODO
        console.log(django_queries);
        generateReport(django_queries, "Django", root_dir + "-results");
    }
}
