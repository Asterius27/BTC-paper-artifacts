import { Octokit } from "octokit";
import 'dotenv/config';
import * as fs from 'fs';

// Create a personal access token at https://github.com/settings/tokens/new?scopes=repo
const octokit = new Octokit({ auth: process.env.TOKEN });

// /search/repositories does not have limitations (for the results) but doesn't allow to search for keywords in files or the existence of specific files.
// It allows to filter by language (automatically detected by github) and it allows to filter using topics, but they are user defined.
// when having millions of results both the web ui and the api aren't perfect (sometimes it returns more results, other times less results) (as for repositories)
// web ui and api results don't match when the query is generic (ex. when only filtering by language), with more specific queries the results match.
// /search/code limits it's result when compared to the web ui (see https://docs.github.com/en/search-github/searching-on-github/searching-code for full list of limitations), but allows to search for stuff inside the files.
// results also differ between requests that are the same but made in different points in time (when using /search/code)
// TODO what to do? get all python repositories and then filter them locally, maybe using codeql?
// TODO this reaches the API rate limit, it will take a while to download all of the repositories, maybe add a timer and wait in order to not exceed the rate limit?
// For authenticated requests, you can make up to 30 requests per minute for all search endpoints except for the "Search code" endpoint. The "Search code" endpoint requires you to authenticate and limits you to 10 requests per minute
let arr = []
for (let i = 0; ; i++) {
    const { data, headers } = await octokit.request('GET /search/code', {
        headers: {
            'X-GitHub-Api-Version': '2022-11-28',
        },
        q: '"from flask_login" language:Python', // add fork:true to include forks, should we also include forks?
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
}

// only downloads the default branch (the main branch)
/* This works
var zip = await octokit.request('GET /repos/{owner}/{repo}/zipball', {
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
