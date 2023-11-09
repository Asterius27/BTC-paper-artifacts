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
const framework = "Flask";
let lang = "python";
let extensions = [".pyx", ".pxd", ".pxi", ".numpy", ".numpyw", ".numsc", ".py", ".cgi", ".fcgi", ".gyp", ".gypi", ".lmi", ".py3", ".pyde", ".pyi", ".pyp", ".pyt", ".pyw", ".rpy", ".spec", ".tac", ".wsgi", ".xpy", ".pytb"];
let blacklist_terms = ["tutorial", "docs", "ctf", "test", "challenge"]; // TODO add more, have to make it more precise. Add flask as word to filter out?
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
                if (repo_counter[keywords[j]] === undefined) {
                    repo_counter[keywords[j]] = 1;
                } else {
                    repo_counter[keywords[j]]++;
                }   
            }
        }
        fs.writeFileSync("./most_common_repo_keywords.json", JSON.stringify(repo_counter, null, 4));
        fs.writeFileSync("./most_common_users.json", JSON.stringify(owner_counter, null, 4));
        let owner_entries = Object.entries(owner_counter);
        let repo_entries = Object.entries(repo_counter);
        // TODO sort doesn't work
        owner_entries.sort((x, y) => y[1] - x[1]);
        repo_entries.sort((x, y) => y[1] - x[1]);
        fs.writeFileSync("./most_common_repo_keywords_sorted.json", JSON.stringify(Object.fromEntries(repo_entries), null, 4));
        fs.writeFileSync("./most_common_users_sorted.json", JSON.stringify(Object.fromEntries(owner_entries), null, 4));
    });
}

function findInterestingRepos(queryDirectory, queryName, result) {
    let dir = './repositories/' + framework;
    let repos = fs.readdirSync(dir);
    for (let i = 0; i < repos.length; i++) {
        let repo = fs.readdirSync(dir + "/" + repos[i]);
        for (let j = 0; j < repo.length; j++) {
            if (repo[j].endsWith("-results")) {
                if (fs.existsSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName)) {
                    let query = fs.readFileSync(dir + "/" + repos[i] + "/" + repo[j] + "/" + queryDirectory + "/" + queryName, 'utf-8').split("\n");
                    query.pop();
                    if (query.length > 2 && result) {
                        fs.appendFileSync('./repos_with_interesting_results.txt', "Query: " + queryDirectory + "/" + queryName + " Repo: " + repos[i] + "\n");
                    }
                    if (query.length <= 2 && !result) {
                        fs.appendFileSync('./repos_with_interesting_results.txt', "Query: " + queryDirectory + "/" + queryName + " Repo: " + repos[i] + "\n");
                    }
                }
            }
        }
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

// Download and extract the repositories
function downloadAndExtractRepos() {
    let startTime = new Date();
    fs.createReadStream('../flask_login_list.csv')
    .pipe(csvParser())
    .on('data', (data) => {
        csv.push(data);
    }).on('end', async () => {
        console.log("read " + csv.length + " lines\n");
        deleteEmptyDirsAndDatabases('./repositories/' + framework);
        let filtered_repos = 0;
        let number_of_repos = 0;
        for (let i = 0; i < csv.length; i++) {
            if (csv[i].stars >= 10) {
                number_of_repos++;
                let owner = csv[i].repo_url.split("/")[3];
                let repoName = csv[i].repo_url.split("/")[4];
                let flag = true;
                // console.log('./repositories/' + framework + '/' + owner + "_" + csv[i].repo_name + "\n");
                if (!fs.existsSync('./repositories/' + framework + '/' + owner + "_" + repoName) && !fs.existsSync('./repositories/' + framework + '/' + owner + "_" + repoName + '.zip') && !blacklist_terms.some(str => repoName.toLowerCase().includes(str))) {
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
                if (blacklist_terms.some(str => repoName.toLowerCase().includes(str))) {
                    filtered_repos++;
                    fs.appendFileSync('./log.txt', "The repo " + repoName + " was filtered out because it contained a blacklisted term (owner: " + owner + ")\n");
                }
            }
        }
        fs.appendFileSync('./log.txt', "Number of processed repos: " + number_of_repos + ". Of which " + filtered_repos + " were filtered out.\n");
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
    fs.createReadStream('../flask_repos.csv')
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
        for (let i = 0; i < csv.length; i++) {
            let owner = csv[i].repo_url.split("/")[3];
            let dir = './repositories/' + framework + '/' + owner + "_" + csv[i].repo_name;
            if (fs.existsSync(dir)) {
                let subdirs = fs.readdirSync(dir);
                for (let j = 0; j < subdirs.length; j++) {
                    if (!subdirs[j].endsWith("-database") && !subdirs[j].endsWith("-results")) {
                        repositories++;
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
                    }
                }
            }
        }
        try {
            let content = "\nTotal repositories: " + repositories + "\nTotal Flask usages: " + flask_count + "\nTotal Flask-login usages: " + flask_login_count + "\nTotal Flask-Security-Too usages: " + flask_security_too + "\nTotal Flask-User usages: " + 
                flask_user + "\nTotal Flask-Oauth usages: " + flask_oauth + "\nTotal PyOTP usages: " + pyotp + "\nTotal PasswordMeter usages: " + passwordmeter + "\nTotal Flask-Bcrypt usages: " + flask_bcrypt + "\nTotal Flask-WTF usages: " + flask_wtf + 
                "\nTotal WTForms usages: " + wtforms;
            fs.appendFileSync('./library_usages.txt', content);
        } catch (err) {
            console.log(err);
        }
        // console.log("Total Flask-login usages: " + flask_login_count + "\n");
    });
}

// downloadAndExtractRepos();
// findInterestingRepos("Flask-login-session-protection", "session_protection.txt", true); // if last parameter is set to true will look for queries that returned a result, otherwise it will look for queries that didn't return a result
// libraryUsagesGrep();
listMostCommonKeywordsAndUsers();
