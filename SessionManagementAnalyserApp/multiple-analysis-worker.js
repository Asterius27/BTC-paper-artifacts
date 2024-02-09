import * as fs from 'fs';
import { execSync } from "child_process";
import csvParser from 'csv-parser';

const SUPPORTED_LANGUAGES = ["python"];
let root_dir = "./";
let lang = "";
let threads = 0;
let starsl = 0;
let starsu = Number.MAX_VALUE;
let csv_file = '../django_filtered_list_final_v2.csv';
let current_thread = 0;

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

// Number of threads, if not specified defaults to 1 per core
if (process.argv.some(str => str.startsWith("-t="))) {
    threads = parseInt(process.argv.filter(str => str.startsWith("-t="))[0].slice(3));
    console.log(threads + "\n");
}

// Lower Bound on number of stars for each repository, if not specified defaults to 0
if (process.argv.some(str => str.startsWith("-sl="))) {
    starsl = parseInt(process.argv.filter(str => str.startsWith("-sl="))[0].slice(4));
    console.log(starsl + "\n");
}

// Upper Bound on number of stars for each repository, if not specified defaults to Number.MAX_VALUE
if (process.argv.some(str => str.startsWith("-su="))) {
    starsu = parseInt(process.argv.filter(str => str.startsWith("-su="))[0].slice(4));
    console.log(starsu + "\n");
}

// Current thread id, if not specified defaults to 0 (running single threaded)
if (process.argv.some(str => str.startsWith("-ct="))) {
    current_thread = parseInt(process.argv.filter(str => str.startsWith("-ct="))[0].slice(4));
    console.log(current_thread + "\n");
}

if (!SUPPORTED_LANGUAGES.some(str => str.toLowerCase() === lang.toLowerCase()) && lang !== "") {
    throw new Error("The language specified is not supported");
}

let repos = fs.readdirSync(root_dir);
let failed = [];
let startTime = new Date();
let csv = {};
await new Promise((resolve, reject) => {
    fs.createReadStream(csv_file)
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
    // if (csv[repos[i]] >= starsl && csv[repos[i]] <= starsu) {
        let dir = root_dir + "/" + repos[i];
        let repo_subdir = fs.readdirSync(dir);
        let repo = "";
        /*
        if (repo.length === 3) {
            for (let j = 0; j < repo.length; j++) {
                if (repo[j].endsWith("-database")) {
                    fs.rmSync(dir + "/" + repo[j], { recursive: true, force: true });
                }
            }
        }
        */
        for (let j = 0; j < repo_subdir.length; j++) {
            if (!repo_subdir[j].endsWith("-results") && !repo_subdir[j].endsWith("-database")) {
                repo = repo_subdir[j];
            }
        }
        // if (repo.length === 1) {
            console.log("Starting analysis for: " + dir + "/" + repo);
            let repoStartTime = new Date();
            if (fs.existsSync(dir + "/" + repo + "-database")) {
                try {
                    fs.rmSync(dir + "/" + repo + "-database", { recursive: true, force: true });
                } catch(e) {}
            }
            try {
                if (lang === "") {
                    throw new Error("Please specify a language, language detection is disabled for now"); // TODO
                    execSync("npm start -- -s=" + dir + "/" + repo, { timeout: 1800000 });
                } else {
                    execSync("codeql database create " + dir + "/" + repo + "-database --language=" + lang.toLowerCase() + " --source-root " + dir + "/" + repo + " --threads=" + threads, {timeout: 1800000});
                    execSync("npm start -- -s=" + dir + "/" + repo + " -l=" + lang + " -t=" + threads + " -ct=" + current_thread); // , { timeout: 1800000 }
                }
            } catch (e) {
                console.log("Analysis failed for: " + dir + "/" + repo + "\nReason: " + e + "\nPlease retry the analysis manually using the main app");
                fs.appendFileSync('./log' + current_thread + '.txt', "Analysis failed for: " + dir + "/" + repo + " Reason: " + e + "\n");
                // failed.push(dir + "/" + repo);
            }
            if (fs.existsSync(dir + "/" + repo + "-database")) {
                try {
                    fs.rmSync(dir + "/" + repo + "-database", { recursive: true, force: true });
                } catch(e) {
                    fs.appendFileSync('./log' + current_thread + '.txt', "Could not delete database for: " + dir + "/" + repo + " Reason: " + e + "\n");
                }
            }
            let repoEndTime = new Date();
            let repoTimeElapsed = (repoEndTime - repoStartTime)/1000;
            fs.appendFileSync('./log' + current_thread + '.txt', "Time taken to run the queries on " + dir + "/" + repo + ": " + repoTimeElapsed + " seconds.\n");
        // }
    // }
}
/*
if (failed.length > 0) {
    console.log("Analysis failed for the following applications/repositories: " + failed + "\nPlease manually rerun the analysis for these applications (using the main app) before rerunning the stats app")
} else {
} 
*/

let endTime = new Date();
let timeElapsed = (endTime - startTime)/1000;
console.log("Done!");
fs.appendFileSync('./log' + current_thread + '.txt', "Time taken to run the queries and generate the statistics: " + timeElapsed + " seconds.\n");
