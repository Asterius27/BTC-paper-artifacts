import * as fs from 'fs';
import { execSync } from "child_process";
import { countRepos, generateStatsPage, initializeCounter } from './python-generate-statistics.js';

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
// TODO make it so that it creates the database on the fly and once the analysis is complete, it deletes the database
let repos = fs.readdirSync(root_dir);
let failed = [];
let startTime = new Date();
for (let i = 0; i < repos.length; i++) {
    let dir = root_dir + "/" + repos[i];
    let repo = fs.readdirSync(dir);
    if (repo.length === 3) {
        for (let j = 0; j < repo.length; j++) {
            if (repo[j].endsWith("-database")) {
                fs.rmSync(dir + "/" + repo[j], { recursive: true, force: true });
            }
        }
    } 
    if (repo.length === 2) { // || repo.length === 3
        for (let j = 0; j < repo.length; j++) {
            if (!repo[j].endsWith("-database") && !repo[j].endsWith("-results")) {
                console.log("Starting analysis for: " + dir + "/" + repo[j]);
                if (fs.existsSync(dir + "/" + repo[j] + "-results")) {
                    fs.rmSync(dir + "/" + repo[j] + "-results", { recursive: true, force: true });
                }
                try {
                    if (lang === "") {
                        execSync("npm start -- -s=" + dir + "/" + repo[j], { timeout: 1200000 });
                    } else {
                        execSync("npm start -- -s=" + dir + "/" + repo[j] + " -l=" + lang, { timeout: 1200000 });
                    }
                } catch (e) {
                    console.log("Analysis failed for: " + dir + "/" + repo[j] + "\nReason: " + e + "\nPlease retry the analysis manually using the main app");
                    fs.appendFileSync('./log.txt', "Analysis failed for: " + dir + "/" + repo[j] + " Reason: " + e + "\n");
                    failed.push(dir + "/" + repo[j]);
                }
            }
        }
    }
}
/*
if (failed.length > 0) {
    console.log("Analysis failed for the following applications/repositories: " + failed + "\nPlease manually rerun the analysis for these applications (using the main app) before rerunning the stats app")
} else {
    */
    console.log("Analysis completed, now generating the statistics...");
    let counter = {}
    let flask_repos = 0;
    let django_repos = 0;
    let failed_repos = 0;
    let custom_session_engine_repos = 0;
    for (let i = 0; i < repos.length; i++) {
        let dir = root_dir + "/" + repos[i];
        let res = "";
        let info = [];
        let failed = false;
        try {
            res = fs.readdirSync(dir).filter(str => str.endsWith("-results"))[0];
        } catch(e) {
            failed_repos++;
            failed = true;
        }
        if (!failed) {
            try {
                info = fs.readFileSync(dir + "/" + res + "/info.txt", { encoding: 'utf-8' }).split(",");
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
            } catch(e) {
                failed_repos++;
                fs.appendFileSync('./log.txt', "Failed to read the results for: " + dir + " Reason: " + e + "\n");
                if (fs.existsSync(dir + "/" + res + "/info.txt")) {
                    if (info.length > 2) {
                        if (info[2].includes("customsessionengine")) {
                            custom_session_engine_repos++;
                        }
                    }
                }
            }
        }
    }
    if (flask_repos === 0) {
        counter = initializeCounter(counter, "flask");
    }
    if (django_repos === 0) {
        counter = initializeCounter(counter, "django");
    }
    generateStatsPage(counter, repos.length, flask_repos, django_repos, failed_repos, custom_session_engine_repos, root_dir);
    let endTime = new Date();
    let timeElapsed = (endTime - startTime)/1000;
    console.log("Done!");
    fs.appendFileSync('./log.txt', "Time taken to run the queries and generate the statistics: " + timeElapsed + " seconds.\n");
// }
