import * as fs from 'fs';
import { execSync } from "child_process";
import { countRepos, generateStatsPage } from './python-generate-statistics.js';

const SUPPORTED_LANGUAGES = ["python"];
let root_dir = "./";
let lang = "";

// Root directory of the projects/repositories/applications, if not specified the current directory will be used
if (process.argv.some(str => str.startsWith("-s="))) {
    root_dir = process.argv.filter(str => str.startsWith("-s="))[0].slice(3);
    console.log(root_dir + "\n");
}

// Language the application was written in, if not specified an attempt will be made to detect it automatically
if (process.argv.some(str => str.startsWith("-l="))) {
    lang = process.argv.filter(str => str.startsWith("-l="))[0].slice(3);
    console.log(lang + "\n");
}

if (!SUPPORTED_LANGUAGES.some(str => str.toLowerCase() === lang.toLowerCase()) && lang !== "") {
    throw new Error("The language specified is not supported");
}

if (fs.existsSync(root_dir + "/stats.html")) {
    fs.unlinkSync(root_dir + "/stats.html");
}
let repos = fs.readdirSync(root_dir);
let failed = [];
for (let i = 0; i < repos.length; i++) {
    let dir = root_dir + "/" + repos[i];
    let repo = fs.readdirSync(dir);
    if (repo.length === 1) {
        try {
            if (lang === "") {
                execSync("npm start -- -s=" + dir + "/" + repo[0]);
            } else {
                execSync("npm start -- -s=" + dir + "/" + repo[0] + " -l=" + lang);
            }
        } catch (e) {
            console.log("Analysis failed for: " + dir + "/" + repo[0] + "\nReason: " + e + "\nPlease retry the analysis manually using the main app");
            failed.push(dir + "/" + repo[0]);
        }
    }
}
if (failed.length > 0) {
    console.log("Analysis failed for the following applications/repositories: " + failed + "\nPlease manually rerun the analysis for these applications (using the main app) before rerunning the stats app")
} else {
    console.log("Analysis completed, now generating the statistics...");
    let counter = {}
    let flask_repos = 0;
    let django_repos = 0;
    for (let i = 0; i < repos.length; i++) {
        let dir = root_dir + "/" + repos[i];
        let res = fs.readdirSync(dir).filter(str => str.endsWith("-results"))[0];
        let info = fs.readFileSync(dir + "/" + res + "/info.txt", { encoding: 'utf-8' }).split(",");
        if (info[0] === "python") {
            if (info[1].includes("flask")) {
                flask_repos++;
                counter = countRepos(counter, "flask", dir + "/" + res);
            }
            if (info[1].includes("django")) {
                django_repos++;
                counter = countRepos(counter, "django", dir + "/" + res);
            }
        }
    }
    generateStatsPage(counter, repos.length, flask_repos, django_repos, root_dir);
}
