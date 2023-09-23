import 'dotenv/config';
import * as fs from 'fs';
import { execSync } from "child_process";
import * as detect from "language-detect";
import { pythonAnalysis } from "./python.js";

// const octokit = new Octokit({ auth: process.env.TOKEN });
const SUPPORTED_LANGUAGES = ["python"];
let root_dir = "./";
let lang = "";

// Root directory of the project/repository/application, if not specified the current directory will be used
if (process.argv.some(str => str.startsWith("-s="))) {
    root_dir = process.argv.filter(str => str.startsWith("-s="))[0].slice(3);
    console.log(root_dir + "\n");
}

// Language the application was written in, if not specified an attempt will be made to detect it automatically
if (process.argv.some(str => str.startsWith("-l="))) {
    lang = process.argv.filter(str => str.startsWith("-l="))[0].slice(3);
    console.log(lang);
} else {
    let file_count = getLanguage(root_dir, {});
    let max = 0;
    for (let [key, value] of Object.entries(file_count)) {
        if (value > max) {
            max = value;
            lang = key;
        }
    }
    console.log(lang + "\n");
}

if (!SUPPORTED_LANGUAGES.some(str => str.toLowerCase() === lang.toLowerCase())) {
    throw new Error("Either wasn't able to detect the language automatically, so you should try to specify it manually\n or the language is not supported");
}

console.log("Starting the analysis...");
if (!fs.existsSync(root_dir + "-database")) {
    execSync("codeql database create " + root_dir + "-database --language=" + lang.toLowerCase() + " --source-root " + root_dir, {timeout: 480000});
}
if (lang.toLowerCase() === "python") {
    pythonAnalysis(root_dir);
}

// TODO need to try and improve it because right now it tries to detect the language the application was written in based only on the number of files written in that language (maybe try and use this: https://github.com/github-linguist/linguist)
// If the project is big this takes a couple of seconds to compute
function getLanguage(dir, file_count) {
    let files = fs.readdirSync(dir, { withFileTypes: true }).filter(item => item.isFile()).map(item => item.name);
    let sub_dirs = fs.readdirSync(dir, { withFileTypes: true }).filter(item => item.isDirectory()).map(item => item.name);
    if (sub_dirs.length === 0) {
        for (let i = 0; i < files.length; i++) {
            try {
                let lang = detect.sync(String(dir) + "/" + String(files[i]));
                if (lang in file_count) {
                    file_count[lang]++;
                } else {
                    file_count[lang] = 1;
                }
            } catch(e) {}
        }
        return file_count;
    } else {
        for (let i = 0; i < files.length; i++) {
            try {
                let lang = detect.sync(String(dir) + "/" + String(files[i]));
                if (lang in file_count) {
                    file_count[lang]++;
                } else {
                    file_count[lang] = 1;
                }
            } catch(e) {}
        }
        for (let i = 0; i < sub_dirs.length; i++) {
            file_count = getLanguage(dir + "/" + sub_dirs[i], file_count);
        }
        return file_count;
    }
}
