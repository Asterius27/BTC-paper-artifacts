import { Octokit } from "octokit";
import { setTimeout } from 'timers/promises';
import 'dotenv/config';
import * as fs from 'fs';
import decompress from "decompress";
import { execSync } from "child_process";

// Create a personal access token at https://github.com/settings/tokens/new?scopes=repo
const octokit = new Octokit({ auth: process.env.TOKEN });

// /search/repositories does not have limitations (for the results) but doesn't allow to search for keywords in files or the existence of specific files.
// It allows to filter by language (automatically detected by github) and it allows to filter using topics, but they are user defined.
// when having millions of results (and only in this case it seems) both the web ui and the api aren't consistent (sometimes it returns more results, other times less results) (when using /search/repositories)
// web ui and api results don't match when the query is generic (ex. when only filtering by language), with more specific queries the results match. (api returns more results when they don't match (when using /search/repositories))
// /search/code limits it's result when compared to the web ui (see https://docs.github.com/en/search-github/searching-on-github/searching-code for full list of limitations), but allows to search for stuff inside the files. (returns way less results than web ui, see: https://github.com/github/rest-api-description/issues/2956)
// results also differ between requests that are the same but made in different points in time (so they aren't consistent) (when using /search/code)
// This reaches the API rate limit, it will take a while to download all of the repositories, maybe add a timer and wait in order to not exceed the rate limit? yes (done)
// For authenticated requests, you can make up to 30 requests per minute for all search endpoints except for the "Search code" endpoint. The "Search code" endpoint requires you to authenticate and limits you to 10 requests per minute
// The GitHub REST API provides up to 1,000 results for each search and no more (even if the query results say that the total count is higher), it's a limit for both the /search/code and /search/repositories
// So only the first 1000 search results are available
// /search/repositories allows us to sort and order by number of stars, forks..., while /search/code does not (in the web ui it's the same)
/*
let arr = []
for (let i = 0; i < 10; i++) {
    const { data, headers } = await octokit.request('GET /search/code', {
        headers: {
            'X-GitHub-Api-Version': '2022-11-28',
        },
        q: '"from flask_login" language:Python', // add fork:true to include forks, should we also include forks? no
        per_page: 100,
        page: i + 1
    });
    arr.push(data);
    console.log("headers: " + headers.link);
    console.log("total count: " + arr[i].total_count);
    console.log("incomplete results: " + arr[i].incomplete_results);
    console.log("items length: " + arr[i].items.length);
    console.log("owner: " + arr[i].items[0].repository.owner.login);
    console.log("repo name: " + arr[i].items[0].repository.name);
    console.log("page: " + (i + 1));
    if (!data) { // TODO don't know if this works, have to test it
        break
    }
    await setTimeout(6200);
}
*/

// Testing the whole process with a couple of repositories
if (process.argv.includes("-d")) {
    const { data } = await octokit.request('GET /search/code', {
        headers: {
            'X-GitHub-Api-Version': '2022-11-28',
        },
        q: '"from flask_login" language:Python',
        per_page: 10
    });
    for(let i = 0; i < data.items.length; i++) {
        let zip = await octokit.request('GET /repos/{owner}/{repo}/zipball', {
            owner: data.items[i].repository.owner.login,
            repo: data.items[i].repository.name,
            headers: {
                'X-GitHub-Api-Version': '2022-11-28'
            }
        });
        fs.appendFileSync("repositories/repo" + i + ".zip", Buffer.from(zip.data));
    }
}

if (process.argv.includes("-a")) {
    let queries_dir = "../Flask_Queries"
    let files = fs.readdirSync('repositories');
    let queries = fs.readdirSync(queries_dir);
    /* This works
    for(let i = 0; i < files.length; i++) {
        await decompress('./repositories/repo' + i + '.zip', './repositories/repo' + i);
        fs.unlinkSync('repositories/repo' + i + '.zip');
    }
    */
    // This works
    for(let i = 0; i < files.length; i++) {
        let dir = fs.readdirSync('repositories/repo' + i);
        execSync("codeql database create ./repositories/repo" + i + "/" + dir[0] + "-database --language=python --source-root ./repositories/repo" + i + "/" + dir[0]);
    }
    // This works
    for(let j = 0; j < queries.length; j++) {
        let query = fs.readdirSync(queries_dir + '/' + queries[j]);
        for(let h = 0; h < query.length; h++) {
            if (query[h].endsWith(".ql")) {
                for(let i = 0; i < files.length; i++) {
                    let dir = fs.readdirSync('repositories/repo' + i).filter(str => str.endsWith("-database"));
                    if (!fs.existsSync("./repositories/repo" + i + "/" + queries[j])){
                        fs.mkdirSync("./repositories/repo" + i + "/" + queries[j]);
                    }
                    execSync("codeql query run --database=./repositories/repo" + i + "/" + dir[0] + " --output=./repositories/repo" + i + "/" + queries[j] + "/" + query[h].slice(0, -3) + ".bqrs " + queries_dir + '/' + queries[j] + "/" + query[h]);
                    execSync("codeql bqrs decode --output=./repositories/repo" + i + "/" + queries[j] + "/" + query[h].slice(0, -3) + ".txt --format=text ./repositories/repo" + i + "/" + queries[j] + "/" + query[h].slice(0, -3) + ".bqrs");
                }
            }
        }
    }
}

// This has no rate limits, gets all repositories and allows us to filter them by language, but doesn't allow to search for keywords inside files
// It might take a while since it scans all of the repositories in github
// TODO add filtering (only get the most famous repositories)
/* This works
let since = [];
let repositories = [];
while (true) {
    const { data, headers } = await octokit.request('GET /repositories', {
        headers: {
            'X-GitHub-Api-Version': '2022-11-28'
        },
        since: parseInt(since[1])|0
    });
    since = headers.link.split(",").filter(str => str.includes('rel="next"'))[0].match("since=(.*)>;");
    console.log("headers: " + headers.link);
    console.log("data: " + data.length);
    console.log("since: " + since[1]);
    for (let i = 0; i < data.length; i++) {
        try {
            let lang = await octokit.request('GET /repos/{owner}/{repo}/languages', {
                owner: data[i].owner.login,
                repo: data[i].name,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });
            if (lang.data.hasOwnProperty('Python')) {
                repositories.push(data[i]);
                console.log("language: " + JSON.stringify(lang.data));
            }
        }
        catch(e) {
            console.log(e);
        }
    }
}
*/

// only downloads the default branch (the main branch)
/* This works
let zip = await octokit.request('GET /repos/{owner}/{repo}/zipball', {
    owner: data.items[0].repository.owner.login,
    repo: data.items[0].repository.name,
    headers: {
        'X-GitHub-Api-Version': '2022-11-28'
    }
});
fs.appendFileSync("repositories/test.zip", Buffer.from(zip.data))
*/

/* Example
const {
  data: { login },
} = await octokit.rest.users.getAuthenticated();
console.log("Hello, %s", login);
*/

/* Example
const { data: { login } } = await octokit.request('GET /user', { // only gets the login field of the response, to get all fields simply do const { data }
    headers: {
        'X-GitHub-Api-Version': '2022-11-28'
    }
});
console.log(login);
*/
