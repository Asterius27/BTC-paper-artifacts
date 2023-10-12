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
// let skip = [];

if (!fs.existsSync("./repositories")){
    fs.mkdirSync("./repositories");
}
if (!fs.existsSync("./repositories/" + framework)){
    fs.mkdirSync("./repositories/" + framework);
}

/* Download and extract the repositories
fs.createReadStream('../flask_repos.csv')
  .pipe(csvParser())
  .on('data', (data) => {
    if (i < 500) {
        let owner = data.repo_url.split("/")[3];
        octokit.request('GET /repos/{owner}/{repo}/zipball', {
            owner: owner,
            repo: data.repo_name,
            headers: {
                'X-GitHub-Api-Version': '2022-11-28'
            }
        }).then(async (zip) => {
            fs.appendFileSync("repositories/" + framework + "/" + owner + "_" + data.repo_name + ".zip", Buffer.from(zip.data));
            try {
                await decompress('./repositories/' + framework + '/' + owner + "_" + data.repo_name + '.zip', './repositories/' + framework + '/' + owner + "_" + data.repo_name);
            } catch(e) {
                console.log(e);
                // skip.push(owner + "_" + data.repo_name);
            }
            fs.unlinkSync("repositories/" + framework + "/" + owner + "_" + data.repo_name + ".zip");
        });
    }
    i++;
}).on('end', () => {
    console.log("Finished parsing the csv, waiting for the downloads to finish...\n");
});
*/

// Create the codeql databases for the repositories
fs.createReadStream('../flask_repos.csv')
  .pipe(csvParser())
  .on('data', (data) => {
    if (i < 50) {
        let owner = data.repo_url.split("/")[3];
        let dir = './repositories/' + framework + '/' + owner + "_" + data.repo_name;
        let repo = fs.readdirSync(dir);
        if (repo.length === 1) {
            try {
                exec("codeql database create " + dir + "/" + repo[0] + "-database --language=" + lang.toLowerCase() + " --source-root " + dir + "/" + repo[0], {timeout: 480000});
            } catch(e) {
                console.log(e);
            }
        }
    }
    i++;
}).on('end', () => {
    console.log("Finished parsing the csv, waiting for the creation of the databases to finish...\n");
});
