import { Octokit } from "octokit";
import 'dotenv/config';
import * as fs from 'fs';
import decompress from "decompress";
import { exec } from "child_process";
import csvParser from 'csv-parser';

const octokit = new Octokit({ auth: process.env.TOKEN });
const framework = "Flask";
let i = 0;
let lang = "python";
let extensions = [".pyx", ".pxd", ".pxi", ".numpy", ".numpyw", ".numsc", ".py", ".cgi", ".fcgi", ".gyp", ".gypi", ".lmi", ".py3", ".pyde", ".pyi", ".pyp", ".pyt", ".pyw", ".rpy", ".spec", ".tac", ".wsgi", ".xpy", ".pytb"];
// let skip = [];

if (!fs.existsSync("./repositories")){
    fs.mkdirSync("./repositories");
}
if (!fs.existsSync("./repositories/" + framework)){
    fs.mkdirSync("./repositories/" + framework);
}

process.on('uncaughtException', function (exception) {
    console.log("Error Caught:\n" + exception);
});

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
  .on('data', async (data) => {
    // if (i < 500) {
        let owner = data.repo_url.split("/")[3];
        let zip = await octokit.request('GET /repos/{owner}/{repo}/zipball', {
            owner: owner,
            repo: data.repo_name,
            headers: {
                'X-GitHub-Api-Version': '2022-11-28'
            }
        });
        fs.appendFileSync("repositories/" + framework + "/" + owner + "_" + data.repo_name + ".zip", Buffer.from(zip.data));
        try {
            await decompress('./repositories/' + framework + '/' + owner + "_" + data.repo_name + '.zip', './repositories/' + framework + '/' + owner + "_" + data.repo_name);
        } catch(e) {
            console.log("Error Caught:\n" + e);
            // skip.push(owner + "_" + data.repo_name);
        }
        fs.unlinkSync("repositories/" + framework + "/" + owner + "_" + data.repo_name + ".zip");
        cleanUpRepos("repositories/" + framework + "/" + owner + "_" + data.repo_name);
    // }
    // i++;
}).on('end', () => {
    console.log("Finished parsing the csv, downloading the repositories, decompressing them and removing all unnecessary files\n");
});

/* Create the codeql databases for the repositories
fs.createReadStream('../flask_repos.csv')
  .pipe(csvParser())
  .on('data', (data) => {
    if (i < 50) {
        let owner = data.repo_url.split("/")[3];
        let dir = './repositories/' + framework + '/' + owner + "_" + data.repo_name;
        let repo = fs.readdirSync(dir);
        if (repo.length === 1) {
            exec("codeql database create " + dir + "/" + repo[0] + "-database --language=" + lang.toLowerCase() + " --source-root " + dir + "/" + repo[0], {timeout: 480000});
        }
    }
    i++;
}).on('end', () => {
    console.log("Finished parsing the csv, waiting for the creation of the databases to finish...\n");
});
*/
