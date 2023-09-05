import { Octokit } from "octokit";
import 'dotenv/config';

// Create a personal access token at https://github.com/settings/tokens/new?scopes=repo
const octokit = new Octokit({ auth: process.env.TOKEN });



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
