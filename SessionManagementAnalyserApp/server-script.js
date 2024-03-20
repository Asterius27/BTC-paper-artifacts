import { Octokit } from "octokit";
import 'dotenv/config';
import * as fs from 'fs';
import decompress from "decompress";
import { exec, execSync } from "child_process";
import csvParser from 'csv-parser';
import axios from "axios";
import extract from "extract-zip";
import { resolve } from "path";
import { pipeline } from "stream/promises";

const octokit = new Octokit({ auth: process.env.TOKEN });
const framework = "Flask"; // "Django"
let lang = "python";
let extensions = [".pyx", ".pxd", ".pxi", ".numpy", ".numpyw", ".numsc", ".py", ".cgi", ".fcgi", ".gyp", ".gypi", ".lmi", ".py3", ".pyde", ".pyi", ".pyp", ".pyt", ".pyw", ".rpy", ".spec", ".tac", ".wsgi", ".xpy", ".pytb"];
let blacklist_terms = ["tutorial", "docs", "ctf", "test", "challenge", "demo", "example", "sample", "bootcamp", "assignment", "workshop", "homework", "course", "exercise", "hackathon"]; // TODO add more, have to make it more precise
let blacklist_term_groups = [["learn", "python"], ["learn", "flask"]]
let blacklist_users = ["PacktPublishing", "rithmschool", "UCLComputerScience", "easyctf"]
let csv = [];
// let skip = [];

if (!fs.existsSync("./repositories")){
    fs.mkdirSync("./repositories");
}
if (!fs.existsSync("./repositories/" + framework)){
    fs.mkdirSync("./repositories/" + framework);
}

/*
process.on('uncaughtException', function (exception) {
    console.log("Error Caught:\n" + exception);
});
*/

function listMostCommonKeywordsAndUsers() {
    fs.createReadStream('../flask_login_list.csv')
    .pipe(csvParser())
    .on('data', (data) => {
        csv.push(data);
    }).on('end', () => {
        let owner_counter = {}
        let repo_counter = {}
        for (let i = 0; i < csv.length; i++) {
            let owner = csv[i].repo_url.split("/")[3];
            let repoName = csv[i].repo_url.split("/")[4];
            if (owner_counter[owner] === undefined) {
                owner_counter[owner] = 1;
            } else {
                owner_counter[owner]++;
            }
            let keywords = repoName.split(/-|_/);
            for (let j = 0; j < keywords.length; j++) {
                if (keywords[j] === "constructor") {
                    if (repo_counter["constructorr"] === undefined) {
                        repo_counter["constructorr"] = 1;
                    } else {
                        repo_counter["constructorr"]++;
                    }
                } else {
                    if (repo_counter[keywords[j]] === undefined) {
                        repo_counter[keywords[j]] = 1;
                    } else {
                        repo_counter[keywords[j]]++;
                    }
                }
            }
        }
        fs.writeFileSync("./most_common_repo_keywords.json", JSON.stringify(repo_counter, null, 4));
        fs.writeFileSync("./most_common_users.json", JSON.stringify(owner_counter, null, 4));
        let owner_entries = Object.entries(owner_counter);
        let repo_entries = Object.entries(repo_counter);
        // TODO sort doesn't work, if the key of the dictionary is composed by only numbers it will be placed on top
        owner_entries.sort((x, y) => y[1] - x[1]);
        repo_entries.sort((x, y) => y[1] - x[1]);
        fs.writeFileSync("./most_common_repo_keywords_sorted.json", JSON.stringify(Object.fromEntries(repo_entries), null, 4));
        fs.writeFileSync("./most_common_users_sorted.json", JSON.stringify(Object.fromEntries(owner_entries), null, 4));
    });
}

async function getSetFromEnvStats(output_path) {
    let dir = './repositories/' + framework;
    let repos = fs.readdirSync(dir);
    let csv = {};
    let csv_urls = {};
    let counter = {
        "un_secret_key": ["SECRET_KEY", 0],
        "ut_secure_attribute_remember_cookie": ["REMEMBER_COOKIE_SECURE", 0],
        "ut_secure_attribute_session_cookie": ["SESSION_COOKIE_SECURE", 0],
        "un_httponly_attribute_session_cookie": ["SESSION_COOKIE_HTTPONLY", 0],
        "un_httponly_attribute_rememeber_cookie": ["REMEMBER_COOKIE_HTTPONLY", 0],
        "uf_domain_attribute_session_cookie": ["SESSION_COOKIE_DOMAIN", 0],
        "uf_domain_attribute_remember_cookie": ["REMEMBER_COOKIE_DOMAIN", 0],
        "st_samesite_attribute_session_cookie": ["SESSION_COOKIE_SAMESITE", 0],
        "st_samesite_attribute_remember_cookie": ["REMEMBER_COOKIE_SAMESITE", 0],
        "st_session_cookie_name_prefix": ["SESSION_COOKIE_NAME", 0],
        "st_remember_cookie_name_prefix": ["REMEMBER_COOKIE_NAME", 0],
        "un_refresh_each_request_remember_cookie": ["REMEMBER_COOKIE_REFRESH_EACH_REQUEST", 0],
        "un_refresh_each_request_session_cookie": ["SESSION_REFRESH_EACH_REQUEST", 0]
    }
    await new Promise((resolve, reject) => {
        fs.createReadStream('../flask_login_final_filtered_merged_list.csv')
            .pipe(csvParser())
            .on('data', (data) => {
                let owner = data.repo_url.split("/")[3];
                let repoName = data.repo_url.split("/")[4];
                csv[owner + "_" + repoName] = data.stars
                csv_urls[owner + "_" + repoName] = data.repo_url
            }).on('end', () => {
                console.log("Finished reading the csv");
                resolve("Done!");
            });
    });
    for (let i = 0; i < repos.length; i++) {
        let repo = fs.readdirSync(dir + "/" + repos[i]);
        for (let j = 0; j < repo.length; j++) {
            if (repo[j].endsWith("-results")) {
                if (fs.existsSync(dir + "/" + repos[i] + "/" + repo[j] + "/Explorative-queries/un_list_config_settings_from_env_var.txt")) {
                    for (let key in counter) {
                        if (fs.readFileSync(dir + "/" + repos[i] + "/" + repo[j] + "/Explorative-queries/un_list_config_settings_from_env_var.txt", 'utf-8').includes(key)) {
                            counter[key][1]++;
                        }
                    }
                }
            }
        }
    }
    fs.appendFileSync(output_path, "Number of times the following config settings were set from an env variable:\n\n");
    for (let key in counter) {
        fs.appendFileSync(output_path, counter[key][0] + ": " + counter[key][1] + "\n");
    }
}

function deleteQueriesResults(queries) {
    let dir = './repositories/' + framework;
    let repos = fs.readdirSync(dir);
    for (let i = 0; i < repos.length; i++) {
        let repo = fs.readdirSync(dir + "/" + repos[i]);
        for (let j = 0; j < repo.length; j++) {
            if (repo[j].endsWith("-results")) {
                for (let queryDirectory in queries) {
                    for (let h = 0; h < queries[queryDirectory].length; h++) {
                        let queryName = queries[queryDirectory][h];
                        if (fs.existsSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName + ".txt")) {
                            fs.rmSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName + ".txt", {force: true});
                        }
                        if (fs.existsSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName + ".bqrs")) {
                            fs.rmSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName + ".bqrs", {force: true});
                        }
                    }
                }
            }
        }
    }
}

async function findOverlappingResultsInRepos(queries, result, output_path) {
    let dir = './repositories/' + framework;
    let repos = fs.readdirSync(dir);
    let csv = {};
    let csv_urls = {};
    await new Promise((resolve, reject) => {
        fs.createReadStream('../flask_login_final_whitelist_filtered_merged_list.csv')
            .pipe(csvParser())
            .on('data', (data) => {
                let owner = data.repo_url.split("/")[3];
                let repoName = data.repo_url.split("/")[4];
                csv[owner + "_" + repoName] = data.stars
                csv_urls[owner + "_" + repoName] = data.repo_url
            }).on('end', () => {
                console.log("Finished reading the csv")
                resolve("Done!");
            });
    });
    for (let i = 0; i < repos.length; i++) {
        let repo = fs.readdirSync(dir + "/" + repos[i]);
        for (let j = 0; j < repo.length; j++) {
            if (repo[j].endsWith("-results")) {
                let flag = true
                let results = []
                let result_counter = 0;
                for (let queryDirectory in queries) {
                    for (let h = 0; h < queries[queryDirectory].length; h++) {
                        let queryName = queries[queryDirectory][h];
                        if (fs.existsSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName)) {
                            let query = fs.readFileSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName, 'utf-8').split("\n");
                            query.pop();
                            if (query.length <= 2 && result[result_counter]) {
                                flag = false;
                            }
                            if (query.length > 2 && !result[result_counter]) {
                                flag = false;
                            }
                            if (flag) {
                                for (let l = 1; l < query.length; l++) {
                                    results.push("Result: " + query[l] + "\n");
                                }
                            }
                        } else {
                            flag = false;
                        }
                        result_counter++;
                    }
                }
                if (flag) {
                    fs.appendFileSync(output_path, "Repo: " + repos[i] + " Stars: " + csv[repos[i]] + "\n");
                    fs.appendFileSync(output_path, "URL: " + csv_urls[repos[i]] + "\n");
                    for (let l = 0; l < results.length; l++) {
                        fs.appendFileSync(output_path, results[l]);
                    }
                    fs.appendFileSync(output_path, "\n");
                }
            }
        }
    }
}

async function findOverlappingResultsInReposOr(queries, result, output_path) {
    let dir = './repositories/' + framework;
    let repos = fs.readdirSync(dir);
    let csv = {};
    let csv_urls = {};
    await new Promise((resolve, reject) => {
        fs.createReadStream('../flask_login_final_whitelist_filtered_merged_list.csv')
            .pipe(csvParser())
            .on('data', (data) => {
                let owner = data.repo_url.split("/")[3];
                let repoName = data.repo_url.split("/")[4];
                csv[owner + "_" + repoName] = data.stars
                csv_urls[owner + "_" + repoName] = data.repo_url
            }).on('end', () => {
                console.log("Finished reading the csv")
                resolve("Done!");
            });
    });
    for (let i = 0; i < repos.length; i++) {
        let repo = fs.readdirSync(dir + "/" + repos[i]);
        for (let j = 0; j < repo.length; j++) {
            if (repo[j].endsWith("-results")) {
                let flag = false
                let overlap = false
                let results = []
                let result_counter = 0;
                for (let queryDirectory in queries) {
                    for (let h = 0; h < queries[queryDirectory].length; h++) {
                        let queryName = queries[queryDirectory][h];
                        if (fs.existsSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName)) {
                            let query = fs.readFileSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName, 'utf-8').split("\n");
                            query.pop();
                            if (query.length <= 2 && !result[result_counter]) {
                                if (flag) {
                                    overlap = true
                                }
                                flag = true;
                            }
                            if (query.length > 2 && result[result_counter]) {
                                if (flag) {
                                    overlap = true
                                }
                                flag = true;
                            }
                            if (flag) {
                                for (let l = 1; l < query.length; l++) {
                                    results.push("Result: " + query[l] + "\n");
                                }
                            }
                        }
                        result_counter++;
                    }
                }
                if (overlap) {
                    fs.appendFileSync(output_path, "Repo: " + repos[i] + " Stars: " + csv[repos[i]] + "\n");
                    fs.appendFileSync(output_path, "URL: " + csv_urls[repos[i]] + "\n");
                    for (let l = 0; l < results.length; l++) {
                        fs.appendFileSync(output_path, results[l]);
                    }
                    fs.appendFileSync(output_path, "\n");
                }
            }
        }
    }
}

async function findInterestingRepos(queryDirectory, queryName, result, starsl, starsu, output_path) {
    let dir = './repositories/' + framework;
    let repos = fs.readdirSync(dir);
    let csv = {};
    let csv_urls = {};
    await new Promise((resolve, reject) => {
        fs.createReadStream('../django_filtered_list_final_v2.csv')
            .pipe(csvParser())
            .on('data', (data) => {
                let owner = data.repo_url.split("/")[3];
                let repoName = data.repo_url.split("/")[4];
                csv[owner + "_" + repoName] = data.stars
                csv_urls[owner + "_" + repoName] = data.repo_url
            }).on('end', () => {
                console.log("Finished reading the csv")
                resolve("Done!");
            });
    });
    for (let i = 0; i < repos.length; i++) {
        // if (csv[repos[i]] >= starsl && csv[repos[i]] <= starsu) { // TODO stars filtering temporarily disabled
            let repo = fs.readdirSync(dir + "/" + repos[i]);
            for (let j = 0; j < repo.length; j++) {
                if (repo[j].endsWith("-results")) {
                    if (fs.existsSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName)) {
                        let query = fs.readFileSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName, 'utf-8').split("\n");
                        let set_from_env = false;
                        let set_from_env_locations = [];
                        if (fs.existsSync(dir + "/" + repos[i] + "/" + repo[j] + "/Explorative-queries/un_list_config_settings_from_env_var.txt")) {
                            let query_name = queryName.split(".")[0];
                            set_from_env = fs.readFileSync(dir + "/" + repos[i] + "/" + repo[j] + "/Explorative-queries/un_list_config_settings_from_env_var.txt", 'utf-8').includes(query_name);
                            if (set_from_env) {
                                let env_results = fs.readFileSync(dir + "/" + repos[i] + "/" + repo[j] + "/Explorative-queries/un_list_config_settings_from_env_var.txt", 'utf-8').split("\n");
                                for (let h = 0; h < env_results.length; h++) {
                                    if (env_results[h].includes(query_name)) {
                                        set_from_env_locations.push(env_results[h]); // .split(" ")[2]
                                    }
                                }
                            }
                        }
                        query.pop();
                        if (query.length > 2 && result) {
                            fs.appendFileSync(output_path, "Query: " + queryDirectory + "/" + queryName + " Repo: " + repos[i] + " Stars: " + csv[repos[i]] + "\n");
                            fs.appendFileSync(output_path, "URL: " + csv_urls[repos[i]] + "\n");
                            for (let h = 1; h < query.length; h++) {
                                fs.appendFileSync(output_path, "Result: " + query[h] + "\n");
                            }
                            if (set_from_env) {
                                fs.appendFileSync(output_path, "And it was also set from an environment variable at the following locations: \n");
                                for (let h = 0; h < set_from_env_locations.length; h++) {
                                    fs.appendFileSync(output_path, set_from_env_locations[h] + "\n");
                                }
                            }
                            fs.appendFileSync(output_path, "\n");
                        }
                        if (query.length <= 2 && !result) {
                            fs.appendFileSync(output_path, "Query: " + queryDirectory + "/" + queryName + " Repo: " + repos[i] + " Stars: " + csv[repos[i]] + "\n");
                            fs.appendFileSync(output_path, "URL: " + csv_urls[repos[i]] + "\n");
                            fs.appendFileSync(output_path, "Result: " + query[query.length - 1] + "\n");
                            if (set_from_env) {
                                fs.appendFileSync(output_path, "And it was also set from an environment variable at the following locations: \n");
                                for (let h = 0; h < set_from_env_locations.length; h++) {
                                    fs.appendFileSync(output_path, set_from_env_locations[h] + "\n");
                                }
                            }
                            fs.appendFileSync(output_path, "\n");
                        }
                    }
                }
            }
        // }
    }
}

function deleteEmptyDirsAndDatabases(dir) {
    let repos = fs.readdirSync(dir);
    for (let i = 0; i < repos.length; i++) {
        let repo = fs.readdirSync(dir + "/" + repos[i]);
        if (repo.length === 0) {
            fs.rmdirSync(dir + "/" + repos[i]);
        } else {
            for (let j = 0; j < repo.length; j++) {
                if (repo[j].endsWith("-database")) {
                    fs.rmSync(dir + "/" + repo[j] + "/" + repo[j], { recursive: true, force: true });
                }
            }
        }
    }
}

// Remove unnecessary files
function cleanUpRepos(dir) {
    let files = fs.readdirSync(dir, { withFileTypes: true }).filter(item => item.isFile()).map(item => item.name);
    let sub_dirs = fs.readdirSync(dir, { withFileTypes: true }).filter(item => item.isDirectory()).map(item => item.name);
    if (sub_dirs.length === 0) {
        for (let i = 0; i < files.length; i++) {
            if (!extensions.some(e => files[i].endsWith(e)) && files[i] !== "requirements.txt") {
                fs.unlinkSync(String(dir) + "/" + String(files[i]))
            }
        }
    } else {
        for (let i = 0; i < files.length; i++) {
            if (!extensions.some(e => files[i].endsWith(e)) && files[i] !== "requirements.txt") {
                fs.unlinkSync(String(dir) + "/" + String(files[i]))
            }
        }
        for (let i = 0; i < sub_dirs.length; i++) {
            cleanUpRepos(dir + "/" + sub_dirs[i]);
        }
    }
}
// cleanUpRepos("repositories/" + framework);

function deleteExtraDirs(repos_list) {
    let repos = fs.readdirSync('./repositories/' + framework + "_READMEs/");
    for (let i = 0; i < repos.length; i++) {
        if (!repos_list.includes(repos[i])) {
            fs.rmSync('./repositories/' + framework + "_READMEs/" + repos[i], { recursive: true, force: true });
        }
    }
}

function downloadREADMEs(csv_file) {
    let startTime = new Date();
    let repo_urls = [];
    // let repo_languages = [];
    let repo_readme_urls = [];
    let limit = 0;
    fs.createReadStream(csv_file)
    .pipe(csvParser())
    .on('data', (data) => {
        // if (limit < 100) {
            try {
                repo_readme_urls.push(JSON.parse(data.jsonb_agg_readme)[0].download_url)
                repo_urls.push(data.repo_url)
                // repo_languages.push(JSON.parse(data.jsonb_agg_lang)[0])
            } catch(e) {
                fs.appendFileSync('./log_READMEs.txt', "Could not parse csv row: " + data + "\n");
            }
            // limit = limit + 1;
        // }
    }).on('end', async () => {
        // console.log(repo_readme_urls.length);
        // console.log(repo_urls.length);
        let temp = {}
        console.log("read " + repo_readme_urls.length + " lines\n");
        let number_of_repos = 0;
        let http_errors = 0;
        let duplicates = 0;
        for (let i = 0; i < repo_readme_urls.length; i++) {
            number_of_repos++;
            let owner = repo_urls[i].split("/")[3];
            let repoName = repo_urls[i].split("/")[4];
            let flag = true;
            if (temp[owner + "_" + repoName] === undefined) {
                temp[owner + "_" + repoName] = 0
            } else {
                duplicates++;
                fs.appendFileSync('./log_READMEs.txt', "Found a duplicate: " + owner + " " + repoName + "\n");
            }
            if (!fs.existsSync('./repositories/' + framework + '_READMEs/' + owner + "_" + repoName)) {
                try {
                    if (!fs.existsSync('./repositories/' + framework + "_READMEs/" + owner + "_" + repoName)){
                        fs.mkdirSync('./repositories/' + framework + "_READMEs/" + owner + "_" + repoName);
                    }
                    let file_name_temp = repo_readme_urls[i].split("/")
                    let file_name = file_name_temp[file_name_temp.length - 1]
                    let response = await axios({
                        method: 'get',
                        url: repo_readme_urls[i],
                        responseType: 'stream'
                    });
                    await pipeline(response.data, fs.createWriteStream("repositories/" + framework + "_READMEs/" + owner + "_" + repoName + "/" + file_name));
                } catch(e) {
                    flag = false;
                    console.log("While trying to download: " + owner + "_" + repoName);
                    console.log("Error caught during download:\n" + e + "\n");
                    fs.appendFileSync('./log_READMEs.txt', "HTTP Error: " + owner + " " + repoName + "\n");
                    http_errors++;
                }
            }
        }
        deleteExtraDirs(Object.keys(temp));
        fs.appendFileSync('./log_READMEs.txt', "Number of processed repos: " + number_of_repos + ". " /*+ "Of which " + filtered_repos + " were filtered out, "*/ + http_errors + " repos weren't downloaded because of an HTTP Error and " + duplicates + " duplicates were found.\n");
        console.log("Finished parsing the csv and downloading all READMEs\n");
        let endTime = new Date();
        let timeElapsed = (endTime - startTime)/1000;
        fs.appendFileSync('./log_READMEs.txt', "Time taken to download and extract the repositories: " + timeElapsed + " seconds.\n");
    })
}

function downloadAndExtractOldCommits(csv_file, commits_file) {
    let startTime = new Date();
    let repo_urls = []
    fs.createReadStream(csv_file)
    .pipe(csvParser())
    .on('data', (data) => {
        repo_urls.push(data.repo_url)
    }).on('end', async () => {
        fs.createReadStream(commits_file)
        .pipe(csvParser())
        .on('data', (dt) => {
            if (repo_urls.includes(dt.repo_url)) {
                try {
                    csv.push({
                        "sha": JSON.parse(dt.data)[0].sha,
                        "repo_url": dt.repo_url
                    });
                } catch(e) {
                    fs.appendFileSync('./log_commits.txt', "No commit found for repo: " + dt.repo_url + "\n");
                }
            }
        }).on('end', async () => {
            let temp = {}
            console.log("read " + csv.length + " lines\n");
            let number_of_repos = 0;
            let http_errors = 0;
            let duplicates = 0;
            for (let i = 0; i < csv.length; i++) {
                // if (csv[i].stars >= 1) {
                    number_of_repos++;
                    let owner = csv[i].repo_url.split("/")[3];
                    let repoName = csv[i].repo_url.split("/")[4];
                    let flag = true;
                    if (temp[owner + "_" + repoName] === undefined) {
                        temp[owner + "_" + repoName] = 0
                    } else {
                        duplicates++;
                        fs.appendFileSync('./log_commits.txt', "Found a duplicate: " + owner + " " + repoName + "\n");
                    }
                    if (!fs.existsSync('./repositories/' + framework + '_old_commits/' + owner + "_" + repoName) && !fs.existsSync('./repositories/' + framework + '_old_commits/' + owner + "_" + repoName + '.zip')) {
                        try {
                            let url = "https://api.github.com/repos/" + owner + "/" + repoName + "/zipball/" + csv[i].sha;
                            let response = await axios({
                                method: 'get',
                                url: url,
                                headers: {
                                    'Accept': 'application/vnd.github+json',
                                    'Authorization': 'Bearer ' + process.env.TOKEN,
                                    'X-GitHub-Api-Version': '2022-11-28'
                                },
                                responseType: 'stream'
                            });
                            await pipeline(response.data, fs.createWriteStream("repositories/" + framework + "_old_commits/" + owner + "_" + repoName + ".zip"));
                        } catch(e) {
                            flag = false;
                            console.log("While trying to download: " + owner + "_" + repoName + "\n");
                            console.log("Error caught during download:\n" + e);
                            fs.appendFileSync('./log_commits.txt', "HTTP Error: " + owner + " " + repoName + "\n");
                            http_errors++;
                        }
                        if (flag) {
                            try {
                                if (!fs.existsSync('./repositories/' + framework + "_old_commits/" + owner + "_" + repoName)){
                                    fs.mkdirSync('./repositories/' + framework + "_old_commits/" + owner + "_" + repoName);
                                }
                                let target = resolve('./repositories/' + framework + "_old_commits/" + owner + "_" + repoName);
                                await extract('./repositories/' + framework + "_old_commits/" + owner + "_" + repoName + '.zip', { dir: target })
                                console.log('Extraction complete of:\n' + './repositories/' + framework + "_old_commits/" + owner + "_" + repoName + '.zip');
                                cleanUpRepos('./repositories/' + framework + "_old_commits/" + owner + "_" + repoName);
                            } catch (err) {
                                console.log('Caught an error:\n' + err);
                                fs.appendFileSync('./log_commits.txt', "Extraction or Cleanup Error: " + owner + "_" + repoName + " " + err + "\n");
                            }
                            fs.unlinkSync('./repositories/' + framework + "_old_commits/" + owner + "_" + repoName + '.zip');
                        }
                    }
                // }
            }
            fs.appendFileSync('./log_commits.txt', "Number of processed repos: " + number_of_repos + ". " + http_errors + " repos weren't downloaded because of an HTTP Error and " + duplicates + " duplicates were found.\n");
            console.log("Finished parsing the csv, downloading the repositories, decompressing them and removing all unnecessary files\n");
            let endTime = new Date();
            let timeElapsed = (endTime - startTime)/1000;
            fs.appendFileSync('./log_commits.txt', "Time taken to download and extract the repositories: " + timeElapsed + " seconds.\n");
        });
    });
}

// Download and extract the repositories
function downloadAndExtractRepos(csv_file) {
    let startTime = new Date();
    fs.createReadStream(csv_file)
    .pipe(csvParser())
    .on('data', (data) => {
        csv.push(data);
    }).on('end', async () => {
        let temp = {}
        console.log("read " + csv.length + " lines\n");
        // deleteEmptyDirsAndDatabases('./repositories/' + framework);
        // let filtered_repos = 0;
        let number_of_repos = 0;
        let http_errors = 0;
        let duplicates = 0;
        for (let i = 0; i < csv.length; i++) {
            // if (csv[i].stars >= 1) {
                number_of_repos++;
                let owner = csv[i].repo_url.split("/")[3];
                let repoName = csv[i].repo_url.split("/")[4];
                let flag = true;
                // let blacklist_flag = true;
                if (temp[owner + "_" + repoName] === undefined) {
                    temp[owner + "_" + repoName] = 0
                } else {
                    duplicates++;
                    fs.appendFileSync('./log.txt', "Found a duplicate: " + owner + " " + repoName + "\n");
                }
                /*
                for (let h = 0; h < blacklist_term_groups.length; h++) {
                    if (blacklist_term_groups[h].every(str => repoName.toLowerCase().includes(str))) {
                        blacklist_flag = false;
                    }
                }
                */
                // console.log('./repositories/' + framework + '/' + owner + "_" + csv[i].repo_name + "\n");
                if (!fs.existsSync('./repositories/' + framework + '/' + owner + "_" + repoName) && !fs.existsSync('./repositories/' + framework + '/' + owner + "_" + repoName + '.zip')) {
                // && !blacklist_terms.some(str => repoName.toLowerCase().includes(str)) && !blacklist_users.some(str => owner.toLowerCase() === str) && blacklist_flag) {
                    // console.log("Starting download...\n");
                    try {
                        /* This doesn't allow you to download files that are greater than 4 gb
                        let zip = await octokit.request('GET /repos/{owner}/{repo}/zipball', {
                            owner: owner,
                            repo: csv[i].repo_name,
                            headers: {
                                'X-GitHub-Api-Version': '2022-11-28'
                            }
                        });
                        fs.appendFileSync("repositories/" + framework + "/" + owner + "_" + csv[i].repo_name + ".zip", Buffer.from(zip.data));
                        */
                        // This allows you to download files that are greater than 4 gb
                        let url = "https://api.github.com/repos/" + owner + "/" + repoName + "/zipball";
                        // console.log("Downloading: " + owner + "_" + csv[i].repo_name + "\n");
                        let response = await axios({
                            method: 'get',
                            url: url,
                            headers: {
                                'Accept': 'application/vnd.github+json',
                                'Authorization': 'Bearer ' + process.env.TOKEN,
                                'X-GitHub-Api-Version': '2022-11-28'
                            },
                            responseType: 'stream'
                        });
                        await pipeline(response.data, fs.createWriteStream("repositories/" + framework + "/" + owner + "_" + repoName + ".zip"));
                        // console.log("Downloaded: " + owner + "_" + csv[i].repo_name + ".zip\n");
                        //response.data.pipe(fs.createWriteStream("repositories/" + framework + "/" + owner + "_" + csv[i].repo_name + ".zip"))
                        //    .on('end', () => console.log("Downloaded: " + owner + "_" + csv[i].repo_name + ".zip\n"));
                    } catch(e) {
                        flag = false;
                        console.log("While trying to download: " + owner + "_" + repoName + "\n");
                        console.log("Error caught during download:\n" + e);
                        fs.appendFileSync('./log.txt', "HTTP Error: " + owner + " " + repoName + "\n");
                        http_errors++;
                    }
                    if (flag) {
                        try {
                            if (!fs.existsSync('./repositories/' + framework + "/" + owner + "_" + repoName)){
                                fs.mkdirSync('./repositories/' + framework + "/" + owner + "_" + repoName);
                            }
                            let target = resolve('./repositories/' + framework + "/" + owner + "_" + repoName);
                            // console.log(target);
                            await extract('./repositories/' + framework + "/" + owner + "_" + repoName + '.zip', { dir: target })
                            console.log('Extraction complete of:\n' + './repositories/' + framework + "/" + owner + "_" + repoName + '.zip');
                            cleanUpRepos('./repositories/' + framework + "/" + owner + "_" + repoName);
                        } catch (err) {
                            console.log('Caught an error:\n' + err);
                            fs.appendFileSync('./log.txt', "Extraction or Cleanup Error: " + owner + "_" + repoName + " " + err + "\n");
                        }
                        fs.unlinkSync('./repositories/' + framework + "/" + owner + "_" + repoName + '.zip');
                        /*
                        try {
                            await decompress('./repositories/' + framework + '/' + owner + "_" + csv[i].repo_name + '.zip', './repositories/' + framework + '/' + owner + "_" + csv[i].repo_name);
                            cleanUpRepos("repositories/" + framework + "/" + owner + "_" + csv[i].repo_name);
                        } catch(e) {
                            console.log("Error caught while extracting the zip:\n" + e);
                            // skip.push(owner + "_" + csv[i].repo_name);
                        }
                        fs.unlinkSync("repositories/" + framework + "/" + owner + "_" + csv[i].repo_name + ".zip");
                        */
                    }
                }
                /*
                if (blacklist_terms.some(str => repoName.toLowerCase().includes(str)) || blacklist_users.some(str => owner.toLowerCase() === str) || !blacklist_flag) {
                    filtered_repos++;
                    fs.appendFileSync('./log.txt', "The repo " + repoName + " was filtered out because it contained a blacklisted term or username (owner: " + owner + ")\n");
                    */
                    /*
                    if (fs.existsSync('./repositories/' + framework + '/' + owner + "_" + repoName)) {
                        try {
                            fs.rmSync('./repositories/' + framework + '/' + owner + "_" + repoName, { recursive: true, force: true });
                        } catch(e) {
                            fs.appendFileSync('./log.txt', "Could not delete " + repoName + " (owner: " + owner + ")\n");
                        }
                    }
                    */
                // }
            // }
        }
        fs.appendFileSync('./log.txt', "Number of processed repos: " + number_of_repos + ". " /*+ "Of which " + filtered_repos + " were filtered out, "*/ + http_errors + " repos weren't downloaded because of an HTTP Error and " + duplicates + " duplicates were found.\n");
        console.log("Finished parsing the csv, downloading the repositories, decompressing them and removing all unnecessary files\n");
        let endTime = new Date();
        let timeElapsed = (endTime - startTime)/1000;
        fs.appendFileSync('./log.txt', "Time taken to download and extract the repositories: " + timeElapsed + " seconds.\n");
    });
}

/* TODO try this. Download repos using git clone instead of the api
fs.createReadStream('../flask_repos.csv')
  .pipe(csvParser())
  .on('data', (data) => {
    csv.push(data);
}).on('end', async () => {
    console.log("read " + csv.length + " lines\n");
    for (let i = 0; i < csv.length; i++) {
        let owner = csv[i].repo_url.split("/")[3];
        if (!fs.existsSync('./repositories/' + framework + '/' + owner + "_" + csv[i].repo_name) && !fs.existsSync('./repositories/' + framework + '/' + owner + "_" + csv[i].repo_name + '.zip')) {
            try {
                fs.mkdirSync('./repositories/' + framework + "/" + owner + "_" + csv[i].repo_name);
                fs.mkdirSync('./repositories/' + framework + "/" + owner + "_" + csv[i].repo_name + "/repo");
                execSync("git clone https://github.com/" + owner + "/" + csv[i].repo_name + ' ./repositories/' + framework + "/" + owner + "_" + csv[i].repo_name + "/repo");
                cleanUpRepos('./repositories/' + framework + "/" + owner + "_" + csv[i].repo_name);
            } catch(e) {
                console.log('Caught an error:\n' + e);
                fs.appendFileSync('./log.txt', "Git clone error: " + owner + "_" + csv[i].repo_name + " " + e + "\n");
            }
        }
    }
});
*/

/* Exctract and cleanup repositories (this library works better than decompress library)
let zips = fs.readdirSync('./repositories/' + framework, { withFileTypes: true }).filter(item => item.isFile() && item.name.endsWith(".zip")).map(item => item.name);
console.log(zips.length);
for (let i = 0; i < zips.length; i++) {
    console.log('./repositories/' + framework + "/" + zips[i]);
    try {
        if (!fs.existsSync('./repositories/' + framework + "/" + zips[i].slice(0, -4))){
            fs.mkdirSync('./repositories/' + framework + "/" + zips[i].slice(0, -4));
        }
        let target = resolve('./repositories/' + framework + "/" + zips[i].slice(0, -4));
        console.log(target);
        await extract('./repositories/' + framework + "/" + zips[i], { dir: target })
        console.log('Extraction complete of:\n' + './repositories/' + framework + "/" + zips[i]);
        fs.unlinkSync('./repositories/' + framework + "/" + zips[i]);
        cleanUpRepos('./repositories/' + framework + "/" + zips[i].slice(0, -4));
    } catch (err) {
        console.log('Caught an error:\n' + err);
    }
}
*/

// let temp = [ "gil9red_SimplePyScripts", "ryanmrestivo_red-team", "gistable_gistable", "Labs22_BlackServerOS", "Vijay-Yosi_biostack", "Mondego_pyreco", "aliostad_deep-learning-lang-detection", "Python000-class01_Python000-class01",
//     "academic-resources_stared-repos", "cndn_intelligent-code-completion", "shreejitverma_SDE-Interview-Prep", "gustcol_Canivete", "imfht_flaskapps", "LiuFang816_SALSTM_py_data"];
/* Create the codeql databases for the flask-login repositories
fs.createReadStream('../flask_repos.csv')
  .pipe(csvParser())
  .on('data', (data) => {
    csv.push(data);
}).on('end', () => {
    let startTime = new Date();
    let repositories_count = 0;
    console.log("read " + csv.length + " lines\n");
    for (let i = 0; i < csv.length; i++) {
        let flag = true;
        let owner = csv[i].repo_url.split("/")[3];
        let dir = './repositories/' + framework + '/' + owner + "_" + csv[i].repo_name;
        if (fs.existsSync(dir)) { // && temp.some(str => str === owner + "_" + csv[i].repo_name)
            let repo = fs.readdirSync(dir);
            // if (repo.length === 1) {
            for (let j = 0; j < repo.length; j++) {
                if (!repo[j].endsWith("-database")) {
                    try {
                        execSync('grep -Eir "^(import|from) flask_login " ' + dir + "/" + repo[j], { encoding: 'utf8' }).toString();
                    } catch(e) {
                        flag = false;
                    }
                    if (flag) {
                        repositories_count++;
                        try {
                            console.log("Building database for: " + dir + "/" + repo[j]);
                            execSync("codeql database create " + dir + "/" + repo[j] + "-database --language=" + lang.toLowerCase() + " --overwrite --source-root " + dir + "/" + repo[j], {timeout: 1200000}); // remove overwrite, --ram=80000 add it if needed, add { stdio: 'ignore' } option if you get too many spawnSync /bin/sh ENOBUFS errors
                        } catch(e) {
                            console.log(e + "\n");
                            fs.appendFileSync('./log.txt', "Database Creation Error: " + owner + "_" + csv[i].repo_name + " " + e + "\n");
                        }
                    }
                }
            }
        }
    }
    let endTime = new Date();
    let timeElapsed = (endTime - startTime)/1000;
    console.log("Finished parsing the csv and creating the databases, elapsed time: " + timeElapsed + " seconds\n");
    fs.appendFileSync('./log.txt', "Time taken to create the databases: " + timeElapsed + " seconds. Number of repositories processed: " + repositories_count + "\n");
});
*/

function execQueries(database, outputLocation) {
    let queryLocation = "../Flask_Queries/Library-is-used-check";
    let queries = fs.readdirSync(queryLocation);
    for (let i = 0; i < queries.length; i++) {
        if (queries[i].endsWith(".ql")) {
            let queryName = queries[i].slice(0, -3);
            execSync("codeql query run --database=" + database + " --output=" + outputLocation + "/" + queryName + ".bqrs " + queryLocation + "/" + queryName + ".ql");
            execSync("codeql bqrs decode --output=" + outputLocation + "/" + queryName + ".json --format=json " + outputLocation + "/" + queryName + ".bqrs");
        }
    }
}

/* Run library check queries
fs.createReadStream('../flask_repos.csv')
  .pipe(csvParser())
  .on('data', (data) => {
    csv.push(data);
}).on('end', () => {
    console.log("read " + csv.length + " lines\n");
    for (let i = 0; i < csv.length; i++) {
        let owner = csv[i].repo_url.split("/")[3];
        let dir = './repositories/' + framework + '/' + owner + "_" + csv[i].repo_name;
        if (fs.existsSync(dir)) {
            let subdirs = fs.readdirSync(dir);
            if (subdirs.length === 1) {
                try {
                    execSync("codeql database create " + dir + "/" + subdirs[0] + "-database --language=" + lang.toLowerCase() + " --source-root " + dir + "/" + subdirs[0], {timeout: 1200000});
                    fs.mkdirSync(dir + "/" + subdirs[0] + "-results");
                    execQueries(dir + "/" + subdirs[0] + "-database", dir + "/" + subdirs[0] + "-results");
                } catch(e) {
                    console.log("Error Caught:\n" + e);
                }
                if (fs.existsSync(dir + "/" + subdirs[0] + "-database")) {
                    fs.rmSync(dir + "/" + subdirs[0] + "-database", { recursive: true, force: true });
                }
            }
            if (subdirs.length === 2) {
                if (!subdirs.some(dir => dir.endsWith("-results"))) {
                    try {
                        if (!subdirs[0].endsWith("-database")) {
                            fs.mkdirSync(dir + "/" + subdirs[0] + "-results");
                            execQueries(dir + "/" + subdirs[0] + "-database", dir + "/" + subdirs[0] + "-results");
                        }
                        if (!subdirs[1].endsWith("-database")) {
                            fs.mkdirSync(dir + "/" + subdirs[0] + "-results");
                            execQueries(dir + "/" + subdirs[1] + "-database", dir + "/" + subdirs[1] + "-results");
                        }
                    } catch(e) {
                        console.log("Error Caught:\n" + e);
                    }
                }
            }
        }
    }
});
*/

// Run library check queries using grep
// regex: "(^import flask_login$|^from flask_login )" or "^(import|from) flask_login "
function libraryUsagesGrep() {
    fs.createReadStream('../django_filtered_list_final_v2.csv')
    .pipe(csvParser())
    .on('data', (data) => {
        csv.push(data);
    }).on('end', () => {
        console.log("read " + csv.length + " lines\n");
        let flask_login_count = 0;
        let flask_count = 0;
        let flask_security_too = 0;
        let flask_user = 0;
        let flask_oauth = 0;
        let pyotp = 0;
        let passwordmeter = 0;
        let flask_bcrypt = 0;
        let flask_wtf = 0;
        let wtforms = 0;
        let repositories = 0;
        let argon2 = 0;
        let bcrypt = 0;
        let hashlib = 0;
        let passlib = 0;
        let werkzeug = 0;
        let django_rest_framework = 0;
        let django_xadmin = 0;
        let dj_rest_auth = 0;
        let allauth = 0;
        for (let i = 0; i < csv.length; i++) {
            let owner = csv[i].repo_url.split("/")[3];
            let dir = './repositories/' + framework + '/' + owner + "_" + csv[i].repo_name;
            if (fs.existsSync(dir)) {
                let subdirs = fs.readdirSync(dir);
                for (let j = 0; j < subdirs.length; j++) {
                    if (!subdirs[j].endsWith("-database") && !subdirs[j].endsWith("-results")) {
                        repositories++;
                        /*
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) flask_login " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            flask_login_count++;
                            // console.log(stdout);
                            // console.log("Flask-login usages: " + flask_login_count + "\n");
                        } catch(e) {
                            // console.log("Error Caught:\n" + e);
                        }
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) flask " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            flask_count++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) flask_security " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            flask_security_too++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) flask_user " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            flask_user++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) flask_oauth " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            flask_oauth++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) pyotp " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            pyotp++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) passwordmeter " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            passwordmeter++;
                        } catch(e) {}
                        */
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) flask_bcrypt " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            flask_bcrypt++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) flask_wtf " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            flask_wtf++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) wtforms " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            wtforms++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) argon2 " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            argon2++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) bcrypt " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            bcrypt++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) hashlib " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            hashlib++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) passlib " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            passlib++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) werkzeug " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            werkzeug++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) rest_framework " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            django_rest_framework++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) xadmin " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            django_xadmin++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) dj_rest_auth " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            dj_rest_auth++;
                        } catch(e) {}
                        try {
                            let stdout = execSync('grep -Eir "^(import|from) allauth " ' + dir + "/" + subdirs[j], { encoding: 'utf8' }).toString();
                            allauth++;
                        } catch(e) {}
                    }
                }
            }
        }
        try {
            let content = "\nTotal repositories: " + repositories + "\nTotal Flask usages: " + flask_count + "\nTotal Flask-login usages: " + flask_login_count + "\nTotal Flask-Security-Too usages: " + flask_security_too + "\nTotal Flask-User usages: " + 
                flask_user + "\nTotal Flask-Oauth usages: " + flask_oauth + "\nTotal PyOTP usages: " + pyotp + "\nTotal PasswordMeter usages: " + passwordmeter + "\nTotal Flask-Bcrypt usages: " + flask_bcrypt + "\nTotal Flask-WTF usages: " + flask_wtf + 
                "\nTotal WTForms usages: " + wtforms + "\nTotal Argon2 usages: " + argon2 + "\nTotal Bcrypt usages: " + bcrypt + "\nTotal Hashlib usages: " + hashlib + "\nTotal Passlib usages: " + passlib + "\nTotal Werkzeug usages: " + werkzeug +
                "\nTotal Django_rest_framework usages: " + django_rest_framework + "\nTotal xadmin usages: " + django_xadmin + "\nTotal dj-rest-auth usages: " + dj_rest_auth + "\nTotal allauth usages: " + allauth;
            fs.appendFileSync('./library_usages.txt', content);
        } catch (err) {
            console.log(err);
        }
        // console.log("Total Flask-login usages: " + flask_login_count + "\n");
    });
}

// downloadAndExtractRepos('../flask_login_final_whitelist_filtered_merged_list.csv');
// downloadAndExtractOldCommits('../flask_login_final_whitelist_filtered_merged_list.csv', '../mid_commits.csv')
// downloadREADMEs('../django_final_filtered_list_w_lang_and_readme_and_desc.csv');
// findInterestingRepos("Secure-cookie-attribute", "sf_secure_attribute_session_cookie_manually_disabled.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/9bis - repos_with_manually_disabled_secure_session_cookie_flask_login_final_filtered_merged_list.txt'); // if third parameter is set to true it will look for queries that returned a result, otherwise it will look for queries that didn't return a result
// findInterestingRepos("HTTPOnly-cookie-attribute", "un_httponly_attribute_session_cookie.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/9bis - repos_with_disabled_httponly_session_cookie_flask_login_final_filtered_merged_list.txt');
// findInterestingRepos("Cookie-name-prefixes", "ut_session_cookie_name_manually_set.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/9bis - repos_with_manually_set_session_cookie_name_flask_login_final_filtered_merged_list.txt');
// findInterestingRepos("Samesite-cookie-attribute", "ut_sameseite_attribute_session_cookie_manually_set.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/9bis - repos_with_manually_set_samesite_session_cookie_flask_login_final_filtered_merged_list.txt');
// findInterestingRepos("Login-restrictions", "un_no_authentication_checks.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/9bis - repos_with_no_auth_checks_flask_login_final_filtered_merged_list.txt');
// findInterestingRepos("Logout-function-is-called", "un_logout_function_is_called.txt", false, 0, Number.MAX_VALUE, './repos_with_interesting_results/9bis - repos_with_no_logout_flask_login_final_filtered_merged_list.txt');
// findInterestingRepos("Account-deactivation", "ut_deactivated_accounts_login.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/9bis - repos_that_allow_deactivated_accounts_to_login_flask_login_final_filtered_merged_list.txt');
// findInterestingRepos("Password-strength", "un_form_with_password_field_is_validated.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/9bis - repos_with_unvalidated_forms_with_password_fields_flask_login_final_filtered_merged_list.txt');
// findInterestingRepos("Password-strength", "un_password_custom_checks.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/12 - repos_with_custom_password_strength_checks_flask_login_final_filtered_merged_list.txt');
// findInterestingRepos("Login-restrictions", "un_no_authentication_checks_general.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/10 - repos_without_login_restrictions_flask_login_final_filtered_merged_list.txt');
// findInterestingRepos(".", "django_library_used_check.txt", false, 0, Number.MAX_VALUE, './repos_with_interesting_results/17 - repos_without_django_auth_django_filtered_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt", "un_form_with_password_field_and_validators.txt"]}, [true, false], './repos_with_interesting_results/10 - repos_that_have_all_password_fields_without_validators_flask_login_final_filtered_merged_list.txt'); // looks for repos where the specified set of queries return the results specified by the list (that is the second parameter). The order of the queries corresponds to the order of the results in the list.
// getSetFromEnvStats('./repos_with_interesting_results/9bis - stats_of_config_settings_that_were_set_from_env_variable.txt'); // retrieves the number of times each config setting was set from an env variable, to find the most popular one for example
// findInterestingRepos("Secret-key", "un_secret_key.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/22bis - repos_with_hardcoded_secret_key_django_manually_filtered_list_v1.txt');
// findInterestingRepos("Login-restrictions", "un_no_authentication_checks_general.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/16 - repos_with_no_auth_checks_django_filtered_list_final_v2.txt');
// findInterestingRepos("Logout-function-is-called", "un_logout_function_is_called.txt", false, 0, Number.MAX_VALUE, './repos_with_interesting_results/22bis - repos_with_no_logout_django_manually_filtered_list_v1.txt');
findInterestingRepos("Password-hashing", "un_argon2_is_used.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/27 - repos_using_argon2_to_hash_passwords_flask_login_whitelist_filtered_list.txt');
findInterestingRepos("Password-hashing", "un_passlib_is_used.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/27 - repos_using_passlib_to_hash_passwords_flask_login_whitelist_filtered_list.txt');
findInterestingRepos("Password-hashing", "un_werkzeug_is_used.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/27 - repos_using_werkzeug_to_hash_passwords_flask_login_whitelist_filtered_list.txt');
// findInterestingRepos(".", "custom_session_engine.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/16 - repos_using_custom_session_engine_django_filtered_list_final_v2.txt');
// findInterestingRepos("Account-deactivation", "un_custom_auth_backends.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/22bis - repos_using_custom_authentication_backends_django_manually_filtered_list_v1.txt');
// findInterestingRepos("Explorative-queries", "un_list_config_settings_from_env_var.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/22bis - repos_using_env_vars_django_manually_filtered_list_v1.txt');
// findInterestingRepos("Password-strength", "un_using_django_password_field.txt", true, 0, Number.MAX_VALUE, './repos_with_interesting_results/26 - repos_using_password_field_django_whitelist_filter_list.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_using_django_built_in_forms.txt"], "Account-deactivation": ["un_custom_auth_backends.txt"]}, [true, true], './repos_with_interesting_results/18 - repos_that_use_a_custom_auth_backend_django_filtered_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_using_django_built_in_forms.txt"], "Logout-function-is-called": ["un_logout_function_is_called.txt"]}, [true, false], './repos_with_interesting_results/18 - repos_with_no_logout_django_filtered_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_using_django_built_in_forms.txt"], "Login-restrictions": ["un_no_authentication_checks_general.txt"]}, [true, true], './repos_with_interesting_results/24 - repos_with_no_auth_checks_django_whitelist_filter_list.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_using_django_built_in_forms.txt"], "Account-deactivation": ["un_custom_auth_backends.txt"]}, [true, false], './repos_with_interesting_results/19 - repos_that_were_analysed_django_whitelist_filter_list.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_flask_wtf_is_used.txt"], "Login-restrictions": ["un_no_authentication_checks_general.txt"]}, [true, true], './repos_with_interesting_results/14 - repos_with_no_auth_checks_flask_login_flask_wtf_filtered_merged_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_flask_wtf_is_used.txt"], "Secret-key": ["un_secret_key.txt"]}, [true, true], './repos_with_interesting_results/14 - repos_with_hardcoded_secret_key_flask_login_flask_wtf_filtered_merged_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_flask_wtf_is_used.txt"], "Logout-function-is-called": ["un_logout_function_is_called.txt"]}, [true, false], './repos_with_interesting_results/14 - repos_with_logout_not_called_flask_login_flask_wtf_filtered_merged_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-hashing": ["un_hashlib_is_used.txt", "un_flask_bcrypt_is_used.txt", "un_argon2_is_used.txt", "un_bcrypt_is_used.txt", "un_passlib_is_used.txt", "un_werkzeug_is_used.txt"]}, [true, false, false, false, false, false], './repos_with_interesting_results/27 - repos_with_only_hashlib_flask_login_and_password_field_whitelist_filtered_list.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt"], "Secret-key": ["un_secret_key.txt"], "Explorative-queries": ["un_potential_false_positives.txt"]}, [true, true, false], './repos_with_interesting_results/27 - repos_with_hardcoded_secret_key_flask_login_and_password_field_whitelist_filtered_list.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt"], "Flask-login-session-protection": ["sf_session_protection_strong.txt"]}, [true, true], './repos_with_interesting_results/14 - repos_with_strong_session_protection_flask_login_and_password_field_filtered_merged_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt"], "Flask-login-session-protection": ["sf_session_protection.txt"]}, [true, true], './repos_with_interesting_results/14 - repos_without_session_protection_flask_login_and_password_field_filtered_merged_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt"], "Login-restrictions": ["un_no_authentication_checks_general.txt"]}, [true, true], './repos_with_interesting_results/14 - repos_with_no_login_required_flask_login_and_password_field_filtered_merged_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt"], "Logout-function-is-called": ["un_logout_function_is_called.txt"]}, [true, false], './repos_with_interesting_results/27 - repos_with_no_logout_flask_login_and_password_field_whitelist_filtered_list.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt", "un_form_with_password_field_and_validators.txt"]}, [true, false], './repos_with_interesting_results/14 - repos_with_no_password_validators_flask_login_and_password_field_filtered_merged_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt", "un_password_length_check.txt", "un_password_regexp_check.txt", "un_password_custom_checks.txt"]}, [true, false, false, false], './repos_with_interesting_results/14 - repos_with_no_password_strength_validators_flask_login_and_password_field_filtered_merged_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt", "un_password_custom_checks.txt"]}, [true, true], './repos_with_interesting_results/14 - repos_with_custom_password_strength_checks_flask_login_and_password_field_filtered_merged_list_final_v2.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt", "un_form_with_password_field_is_validated.txt"]}, [true, true], './repos_with_interesting_results/27 - repos_with_password_form_never_validated_flask_login_and_password_field_whitelist_filtered_list.txt');
// findOverlappingResultsInReposOr({"Password-hashing": ["un_flask_bcrypt_is_used.txt", "un_argon2_is_used.txt", "un_bcrypt_is_used.txt", "un_passlib_is_used.txt", "un_hashlib_is_used.txt", "un_werkzeug_is_used.txt"]}, [true, true, true, true, true, true], './repos_with_interesting_results/27 - repos_with_more_than_one_hashing_library_including_hashlib_flask_login_and_password_field_whitelist_filtered_list.txt');
// findOverlappingResultsInRepos({"Password-strength": ["un_form_with_password_field.txt"], "Explorative-queries": ["un_custom_session_interface.txt"]}, [true, true], './repos_with_interesting_results/27 - repos_with_custom_session_interface_flask_login_and_password_field_whitelist_filtered_list.txt');
// deleteQueriesResults({"Password-strength": ["un_using_django_built_in_forms"]});
// deleteQueriesResults({"Login-restrictions": ["un_no_authentication_checks", "un_no_authentication_checks_general", "un_no_last_login_check"]});
// deleteQueriesResults({"Logout-function-is-called": ["un_logout_function_is_called"]});
// libraryUsagesGrep();
// listMostCommonKeywordsAndUsers();
