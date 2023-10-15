import { Octokit } from "octokit";
import 'dotenv/config';
import * as fs from 'fs';
import decompress from "decompress";
import { exec, execSync } from "child_process";
import csvParser from 'csv-parser';

const octokit = new Octokit({ auth: process.env.TOKEN });
const framework = "Flask";
let lang = "python";
let extensions = [".pyx", ".pxd", ".pxi", ".numpy", ".numpyw", ".numsc", ".py", ".cgi", ".fcgi", ".gyp", ".gypi", ".lmi", ".py3", ".pyde", ".pyi", ".pyp", ".pyt", ".pyw", ".rpy", ".spec", ".tac", ".wsgi", ".xpy", ".pytb"];
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

// Remove unnecessary files
function cleanUpRepos(dir) {
    let files = fs.readdirSync(dir, { withFileTypes: true }).filter(item => item.isFile()).map(item => item.name);
    let sub_dirs = fs.readdirSync(dir, { withFileTypes: true }).filter(item => item.isDirectory()).map(item => item.name);
    if (sub_dirs.length === 0) {
        for (let i = 0; i < files.length; i++) {
            if (!extensions.some(e => files[i].endsWith(e))) {
                fs.unlinkSync(String(dir) + "/" + String(files[i]))
            }
        }
    } else {
        for (let i = 0; i < files.length; i++) {
            if (!extensions.some(e => files[i].endsWith(e))) {
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
fs.createReadStream('../flask_repos.csv')
  .pipe(csvParser())
  .on('data', (data) => {
    csv.push(data);
}).on('end', async () => {
    console.log("read " + csv.length + " lines\n");
    for (let i = 0; i < csv.length; i++) {
        let owner = csv[i].repo_url.split("/")[3];
        let flag = true;
        console.log('./repositories/' + framework + '/' + owner + "_" + csv[i].repo_name + "\n");
        if (!fs.existsSync('./repositories/' + framework + '/' + owner + "_" + csv[i].repo_name) && !fs.existsSync('./repositories/' + framework + '/' + owner + "_" + csv[i].repo_name + '.zip')) {
            console.log("Starting download...\n");
            try {
                let zip = await octokit.request('GET /repos/{owner}/{repo}/zipball', {
                    owner: owner,
                    repo: csv[i].repo_name,
                    headers: {
                        'X-GitHub-Api-Version': '2022-11-28'
                    }
                });
                fs.appendFileSync("repositories/" + framework + "/" + owner + "_" + csv[i].repo_name + ".zip", Buffer.from(zip.data));
            } catch(e) {
                flag = false;
                console.log("Error Caught:\n" + e);
            }
            if (flag) {
                try {
                    await decompress('./repositories/' + framework + '/' + owner + "_" + csv[i].repo_name + '.zip', './repositories/' + framework + '/' + owner + "_" + csv[i].repo_name);
                    cleanUpRepos("repositories/" + framework + "/" + owner + "_" + csv[i].repo_name);
                } catch(e) {
                    console.log("Error Caught:\n" + e);
                    // skip.push(owner + "_" + csv[i].repo_name);
                }
                fs.unlinkSync("repositories/" + framework + "/" + owner + "_" + csv[i].repo_name + ".zip");
            }
        }
    }
    console.log("Finished parsing the csv, downloading the repositories, decompressing them and removing all unnecessary files\n");
});

/* Create the codeql databases for the repositories
fs.createReadStream('../flask_repos.csv')
  .pipe(csvParser())
  .on('data', (data) => {
    csv.push(data);
}).on('end', () => {
    console.log("read " + csv.length + " lines\n");
    for (let i = 0; i < csv.length; i++) {
        if (i < 50) {
            let owner = csv[i].repo_url.split("/")[3];
            let dir = './repositories/' + framework + '/' + owner + "_" + csv[i].repo_name;
            if (fs.existsSync(dir)) {
                let repo = fs.readdirSync(dir);
                if (repo.length === 1) {
                    // remember to uncomment the process.on uncaughtException callback
                    exec("codeql database create " + dir + "/" + repo[0] + "-database --language=" + lang.toLowerCase() + " --source-root " + dir + "/" + repo[0], {timeout: 480000});
                }
            }
        }
    }
    console.log("Finished parsing the csv and creating the databases\n");
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
                    execSync("codeql database create " + dir + "/" + subdirs[0] + "-database --language=" + lang.toLowerCase() + " --source-root " + dir + "/" + subdirs[0], {timeout: 480000});
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
