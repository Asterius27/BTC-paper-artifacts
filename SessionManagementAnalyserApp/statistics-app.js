import * as fs from 'fs';
import { execSync } from "child_process";
import { countRepos, generateStatsPage, initializeCounter } from './python-generate-statistics.js';
import csvParser from 'csv-parser';

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
let startTime = new Date();
let csv = {};
let stars = 200;
await new Promise((resolve, reject) => {
    fs.createReadStream('../flask_login_list.csv')
        .pipe(csvParser())
        .on('data', (data) => {
            let owner = data.repo_url.split("/")[3];
            let repoName = data.repo_url.split("/")[4];
            csv[owner + "_" + repoName] = data.stars
        }).on('end', () => {
            console.log("Finished reading the csv")
            resolve("Done!");
        });
});
for (let i = 0; i < repos.length; i++) {
    if (csv[repos[i]] >= stars) {
        let dir = root_dir + "/" + repos[i];
        let repo = fs.readdirSync(dir);
        /*
        if (repo.length === 3) {
            for (let j = 0; j < repo.length; j++) {
                if (repo[j].endsWith("-database")) {
                    fs.rmSync(dir + "/" + repo[j], { recursive: true, force: true });
                }
            }
        }
        */
        if (repo.length === 1) {
            console.log("Starting analysis for: " + dir + "/" + repo[0]);
            let repoStartTime = new Date();
            try {
                if (lang === "") {
                    throw new Error("Please specify a language, language detection is disabled for now"); // TODO
                    execSync("npm start -- -s=" + dir + "/" + repo[0], { timeout: 1800000 });
                } else {
                    execSync("codeql database create " + dir + "/" + repo[0] + "-database --language=" + lang.toLowerCase() + " --source-root " + dir + "/" + repo[0] + " --threads=0", {timeout: 1800000});
                    execSync("npm start -- -s=" + dir + "/" + repo[0] + " -l=" + lang); // , { timeout: 1800000 }
                }
            } catch (e) {
                console.log("Analysis failed for: " + dir + "/" + repo[0] + "\nReason: " + e + "\nPlease retry the analysis manually using the main app");
                fs.appendFileSync('./log.txt', "Analysis failed for: " + dir + "/" + repo[0] + " Reason: " + e + "\n");
                failed.push(dir + "/" + repo[0]);
            }
            if (fs.existsSync(dir + "/" + repo[0] + "-database")) {
                try {
                    fs.rmSync(dir + "/" + repo[0] + "-database", { recursive: true, force: true });
                } catch(e) {
                    fs.appendFileSync('./log.txt', "Could not delete database for: " + dir + "/" + repo[0] + " Reason: " + e + "\n");
                }
            }
            let repoEndTime = new Date();
            let repoTimeElapsed = (repoEndTime - repoStartTime)/1000;
            fs.appendFileSync('./log.txt', "Time taken to run the queries on " + dir + "/" + repo[0] + ": " + repoTimeElapsed + " seconds.\n");
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
    let error_counter = {}
    let flask_repos = 0;
    let django_repos = 0;
    let failed_repos = 0;
    let custom_session_engine_repos = 0;
    for (let i = 0; i < repos.length; i++) {
        if (csv[repos[i]] >= stars) {
            let dir = root_dir + "/" + repos[i];
            let res = "";
            let info = [];
            let failed = false;
            try {
                res = fs.readdirSync(dir).filter(str => str.endsWith("-results"))[0];
            } catch(e) {
                failed_repos++;
                fs.appendFileSync('./log.txt', "Failed to read the results directory for: " + dir + " Reason: " + e + "\n");
                failed = true;
            }
            if (!failed) {
                try {
                    info = fs.readFileSync(dir + "/" + res + "/info.txt", { encoding: 'utf-8' }).split(",");
                    if (info[0] === "python") {
                        if (info[1].includes("flask")) {
                            flask_repos++;
                            [counter, error_counter] = countRepos(counter, error_counter, "flask", dir + "/" + res);
                        }
                        if (info[1].includes("django")) {
                            django_repos++;
                            [counter, error_counter] = countRepos(counter, error_counter, "django", dir + "/" + res);
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
    }
    if (flask_repos === 0) {
        [counter, error_counter] = initializeCounter(counter, error_counter, "flask");
    }
    if (django_repos === 0) {
        [counter, error_counter] = initializeCounter(counter, error_counter, "django");
    }
    generateStatsPage(counter, error_counter, repos.length, flask_repos, django_repos, failed_repos, custom_session_engine_repos, root_dir);
    let endTime = new Date();
    let timeElapsed = (endTime - startTime)/1000;
    console.log("Done!");
    fs.appendFileSync('./log.txt', "Time taken to run the queries and generate the statistics: " + timeElapsed + " seconds.\n");
// }
