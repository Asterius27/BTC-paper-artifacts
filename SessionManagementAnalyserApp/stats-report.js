import * as fs from 'fs';
import { countRepos, generateStatsPage, initializeCounter } from './python-generate-statistics.js';
import csvParser from 'csv-parser';

const SUPPORTED_LANGUAGES = ["python"];
let root_dir = "./";
let starsl = 0;
let starsu = Number.MAX_VALUE;
let lang = "";
let csv_file = '../flask_login_final_whitelist_filtered_merged_list.csv';
let csv_filter_file = '../flask_login_final_whitelist_filtered_merged_list.csv';

function repoUsesRequiredLibraries(resDir) {
    let filterQueries = {
        "Password-strength": {
            "un_flask_wtf_is_used": true,
            "un_wtforms_is_used": true,
        },
        "Login-restrictions": {
            "un_no_authentication_checks_general": false
        },
        /*
        "Password-hashing": {
            "un_flask_bcrypt_is_used": true,
            "un_argon2_is_used": true,
            "un_bcrypt_is_used": true,
            // "un_hashlib_is_used": true,
            "un_passlib_is_used": true,
            "un_werkzeug_is_used": true
        }
        */
    }
    for (let [dir, files] of Object.entries(filterQueries)) {
        let result = false;
        for (let [query, value] of Object.entries(files)) {
            let lines = [];
            try {
                lines = fs.readFileSync(resDir + "/" + dir + "/" + query + ".txt", 'utf-8').split("\n");
                lines.pop();
                if (lines.length > 2 && value) {
                    result = true;
                }
                if (lines.length <= 2 && !value) {
                    result = true;
                }
            } catch (e) {
                fs.appendFileSync('./log_stats_generator.txt', "Failed to read query results for: " + resDir + "/" + dir + "/" + query + ".txt" + " Reason: " + e + "\n");
            }
        }
        if (!result) {
            return false;
        }
    }
    return true;
}

// TODO filter the repos by repos that use django password hashing and repos that use django password strength to get more precise results for password hashing and password strength separately
function usesDjangoForEverything(resDir) {
    let lines = [];
    let hashing = [];
    let strength = [];
    let auth = [];
    let login = [];
    let passfield = [];
    try {
        /*
        auth = fs.readFileSync(resDir + "/Account-deactivation/un_custom_auth_backends.txt", 'utf-8').split("\n");
        auth.pop();
        if (auth.length > 2) {
            return false;
        }
        login = fs.readFileSync(resDir + "/Login-restrictions/un_no_authentication_checks_general.txt", 'utf-8').split("\n");
        login.pop();
        if (login.length > 2) {
            return false;
        }
        */
        lines = fs.readFileSync(resDir + "/Password-strength/un_using_django_built_in_forms.txt", 'utf-8').split("\n");
        lines.pop();
        if (lines.length > 2) {
            return true;
        }
        passfield = fs.readFileSync(resDir + "/Password-strength/un_using_django_password_field.txt", 'utf-8').split("\n");
        passfield.pop();
        if (passfield.length > 2) {
            return true;
        }
        /*
        hashing = fs.readFileSync(resDir + "/Password-hashing/un_hash_password_function_is_used.txt", 'utf-8').split("\n");
        strength = fs.readFileSync(resDir + "/Password-strength/un_using_custom_forms_with_validators.txt", 'utf-8').split("\n");
        hashing.pop();
        strength.pop();
        if (hashing.length > 2 && strength.length > 2) {
            return true;
        }
        */
    } catch (e) {
        fs.appendFileSync('./log_stats_generator.txt', "Failed to read query results for: " + resDir + " Reason: " + e + "\n");
    }
    return false;
}

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
let whitelist = []
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
await new Promise((resolve, reject) => {
    fs.createReadStream(csv_filter_file)
        .pipe(csvParser())
        .on('data', (data) => {
            let owner = data.repo_url.split("/")[3];
            let repoName = data.repo_url.split("/")[4];
            whitelist.push(owner + "_" + repoName)
        }).on('end', () => {
            console.log("Finished reading the filter csv")
            resolve("Done!");
        });
});
let repos = fs.readdirSync(root_dir);

console.log("Now generating the statistics...");
let flask_counter = {}
let flask_error_counter = {}
let django_counter = {}
let django_error_counter = {}
let false_positives_counter_flask = {}
let false_positives_counter_django = {}
let flask_repos = 0;
let django_repos = 0;
let failed_repos = 0;
let custom_session_engine_repos = 0;
let number_of_repos = 0;
for (let i = 0; i < repos.length; i++) {
    if (whitelist.includes(repos[i])) { // csv[repos[i]] >= starsl && csv[repos[i]] <= starsu
        number_of_repos++;
        let dir = root_dir + "/" + repos[i];
        let res = "";
        let info = [];
        let failed = false;
        try {
            res = fs.readdirSync(dir).filter(str => str.endsWith("-results"))[0];
        } catch(e) {
            failed_repos++;
            fs.appendFileSync('./log_stats_generator.txt', "Failed to read the results directory for: " + dir + " Reason: " + e + "\n");
            failed = true;
        }
        if (!failed) {
            try {
                info = fs.readFileSync(dir + "/" + res + "/info.txt", { encoding: 'utf-8' }).split(",");
                if (info[0] === "python") {
                    if (info.some(str => str.includes("flask"))) {
                        if (repoUsesRequiredLibraries(dir + "/" + res)) {
                            flask_repos++;
                            [flask_counter, flask_error_counter, false_positives_counter_flask] = countRepos(flask_counter, flask_error_counter, false_positives_counter_flask, "flask", dir + "/" + res);
                        }
                    }
                    if (info.some(str => str.includes("django"))) {
                        if (usesDjangoForEverything(dir + "/" + res) && !info.some(str => str.includes("customsessionengine"))) {
                            django_repos++;
                            [django_counter, django_error_counter, false_positives_counter_django] = countRepos(django_counter, django_error_counter, false_positives_counter_django, "django", dir + "/" + res);
                        }
                        if (info.some(str => str.includes("customsessionengine"))) {
                            custom_session_engine_repos++;
                            failed_repos++;
                        }
                    }
                    if (!info.some(str => str.includes("flask")) && !info.some(str => str.includes("django"))) {
                        fs.appendFileSync('./log_stats_generator.txt', "Read info file, but it doesn't contain either flask nor django, repo directory: " + dir + "\n");
                    }
                } else {
                    fs.appendFileSync('./log_stats_generator.txt', "Read info file, but it doesn't contain python, repo directory: " + dir + "\n");
                }
            } catch(e) {
                failed_repos++;
                fs.appendFileSync('./log_stats_generator.txt', "Failed to read the results for: " + dir + " Reason: " + e + "\n");
                /*
                if (fs.existsSync(dir + "/" + res + "/info.txt")) {
                    if (info.some(str => str.includes("customsessionengine"))) {
                        custom_session_engine_repos++;
                    }
                }
                */
            }
        }
    }
}
if (flask_repos === 0) {
    [flask_counter, flask_error_counter, false_positives_counter_flask] = initializeCounter(flask_counter, flask_error_counter, false_positives_counter_flask, "flask");
}
if (django_repos === 0) {
    [django_counter, django_error_counter, false_positives_counter_django] = initializeCounter(django_counter, django_error_counter, false_positives_counter_django, "django");
}
generateStatsPage(flask_counter, flask_error_counter, false_positives_counter_flask, django_counter, django_error_counter, false_positives_counter_django, number_of_repos, flask_repos, django_repos, failed_repos, custom_session_engine_repos, root_dir);
