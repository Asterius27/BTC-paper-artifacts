import * as fs from 'fs';
import { countRepos, generateStatsPage, initializeCounter } from './python-generate-statistics.js';

const SUPPORTED_LANGUAGES = ["python"];
let root_dir = "./";
let starsl = 0;
let starsu = Number.MAX_VALUE;
let lang = "";
let csv_file = '../flask_login_merged_list.csv';

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

if (!SUPPORTED_LANGUAGES.some(str => str.toLowerCase() === lang.toLowerCase()) && lang !== "") {
    throw new Error("The language specified is not supported");
}

if (lang === "") {
    throw new Error("Please specify a language, language detection is disabled for now"); // TODO
}

if (fs.existsSync(root_dir + "/stats.html")) {
    fs.unlinkSync(root_dir + "/stats.html");
}

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
let repos = fs.readdirSync(root_dir);

console.log("Now generating the statistics...");
let flask_counter = {}
let flask_error_counter = {}
let django_counter = {}
let django_error_counter = {}
let flask_repos = 0;
let django_repos = 0;
let failed_repos = 0;
let custom_session_engine_repos = 0;
for (let i = 0; i < repos.length; i++) {
    if (csv[repos[i]] >= starsl && csv[repos[i]] <= starsu) {
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
                        [flask_counter, flask_error_counter] = countRepos(flask_counter, flask_error_counter, "flask", dir + "/" + res);
                    }
                    if (info[1].includes("django")) {
                        django_repos++;
                        [django_counter, django_error_counter] = countRepos(django_counter, django_error_counter, "django", dir + "/" + res);
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
    [flask_counter, flask_error_counter] = initializeCounter(flask_counter, flask_error_counter, "flask");
}
if (django_repos === 0) {
    [django_counter, django_error_counter] = initializeCounter(django_counter, django_error_counter, "django");
}
generateStatsPage(flask_counter, flask_error_counter, django_counter, django_error_counter, repos.length, flask_repos, django_repos, failed_repos, custom_session_engine_repos, root_dir);
