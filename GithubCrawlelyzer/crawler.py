import requests
from pprint import pprint
import time
import json
from datetime import datetime
import multiprocessing
from tqdm import tqdm
from uuid import uuid4
import math
import re

class GithubCrawler():
    
    """ This crawler is built to communicate with the Github API.
        We use it to collect meta information about repositories
        that might be from interest.
    """

    def __init__(self, api_keys, db_con) -> None:
        # TODO we need to be careful with the keys here because of the limit headers.
        # Rather use one key until limit and than add the next key
        self.api_keys = api_keys.split(',')
        self.api_keys_idx = 0
        self.db_con = db_con

        self.idle = False
        self.ratelimit_limit = 999
        self.ratelimit_remaining = 999
        self.ratelimit_used = 0
        self.ratelimit_reset =  0

        self.ranges = []
        self.created = datetime.now()

    def _get_headers(self):
        api_key = self.api_keys[self.api_keys_idx]
        self.api_keys_idx = (self.api_keys_idx + 1) % len(self.api_keys)

        headers = {
            'Accept': 'application/vnd.github.v3+json',
            'Authorization': f'Bearer {api_key}',
            'X-GitHub-Api-Version': '2022-11-28',
        }

        return headers
    
    def _idle_check(self):
        while self.idle:
            time_to_wait = int(self.ratelimit_reset) - int(time.time())
            print(f"We still need to wait {time_to_wait} seconds")
            if  time_to_wait <= 0:
                self.idle = False
                break
            time.sleep(10)

    def _get(self, url, params=None, as_json=True):

        while 1:
            self._idle_check()
            res = requests.get(url, params=params, headers=self._get_headers())

            self.ratelimit_limit = res.headers.get("x-ratelimit-limit", self.ratelimit_limit)
            self.ratelimit_remaining = res.headers.get("x-ratelimit-remaining", -1)
            self.ratelimit_used = res.headers.get("x-ratelimit-used", int(self.ratelimit_used) + 1)
            self.ratelimit_reset = res.headers.get("x-ratelimit-reset", self.ratelimit_reset)

            if int(self.ratelimit_remaining) < 0:
                print("STRANGE BEHAVIOUR")
                print(res.status_code)
                print(res.headers)
                print(res.content)
                # Sleep 5 minutes TODO is not so nice
                time.sleep(5*60)
                continue

            if int(self.ratelimit_remaining) <= 0:
                self.idle = True

            self._idle_check()

            # We expect to receive json

            if as_json:
                result = None

                try:
                    result = res.json()
                except Exception as e:
                    print("UNEXPECTED")
                    print(res.content)
                    # Sleep 5 minutes TODO is not so nice
                    time.sleep(5*60)
                    continue
                break
            else:
                result = res
                break

        return result

    def _merge_binary_search_ranges(self):
        # Sort by the start value of each range
        self.ranges.sort(key=lambda x: x[0])

        merged = [self.ranges[0]]
        for current_start, current_end in self.ranges[1:]:
            # Get the last range in the merged list
            last_start, last_end = merged[-1]
            
            # Check if the current range overlaps or is adjacent with the last range
            if current_start <= last_end + 1: 
                merged[-1] = [last_start, max(last_end, current_end)]  # Merge ranges
            else:
                merged.append([current_start, current_end])  # Add new range

        self.ranges = merged


    def search_code(self, q, per_page=1, page=1):
        params = {
            'q': q,
            'per_page': per_page,
            'page': page
        }

        json_data = self._get('https://api.github.com/search/code', params=params)
        # pprint(json_data)
        return json_data

    def get_repository_by_date(self, start_date, end_date):
        params = {
            'q': "created:<=2021-03-31 created:>=2014-01-01",
            'per_page': 1,
            'page': 100
        }
        json_data = self._get('https://api.github.com/repositories', params=params)
        pprint(json_data)

    def get_repository_by_id(self, r_id):
        json_data = self._get('https://api.github.com/repositories/%d' % r_id)
        # pprint(json_data)
        return json_data
    
    def get_repository_by_url(self, r_url):
        json_data = self._get(r_url)
        # pprint(json_data)
        return json_data

    def get_repository_by_id_and_langs(self, r_id, langs):
        json_data = self.get_repository_by_id(r_id)
        if json_data.get("language") in langs:
            pprint(json_data)
            return json_data
        pprint(json_data.get("language"))
        return {}

    def get_repository_by_id_and_lang(self, r_id, lang):
        json_data = self.get_repository_by_id(r_id)
        pprint(json_data)
        if json_data.get("language") == lang:
            pprint(json_data)
            return json_data
        pprint(json_data.get("language"))
        return {}

    def get_commit_until_date(self, r_url, date):
        # This request only looks at the default branch
        json_data = self._get(f"{r_url}/commits?until={date.isoformat()}")
        if len(json_data) != 0:
            return json_data[0]        
        return None


    def linear_helper(self, query, start, end, search_id):

        # We begin with page 10 and count down.
        # The API search often changes the total_count on the last page (10) to a higher number...
        res = self.search_code(query + f" size:{start}..{end}", per_page=100, page=10)
        total_count = int(res.get("total_count", 0))

        print(f"""
        For {start}..{end} we found {total_count}.
        You have {self.ratelimit_remaining} / {self.ratelimit_limit} left.
        {self.ratelimit_used} used.
        Next rest: {self.ratelimit_reset}
        """)

        # Even if the total is larger than 1k, there is nothing that we can do now.

        # store results

        cur = self.db_con.cursor()

        # We started with page 10 earlier so it needs to be first.
        # Then we continue with 1 again.
        for p in [10] + list(range(1,10)):
            print("On page %d" % p, sep=" ")

            # We make the request to 10 twice as often it changes the total count for the second request
            res = self.search_code(query + f" size:{start}..{end}", per_page=100, page=p)
            total_count = int(res.get("total_count", 0))
            print(f"Total count: {total_count}")

            data = res.get('items', [])
            print(f"Working through {len(data)} data")

            # TODO log only for comparison
            print(start, end, p, len(data))

            for repo in data:
                repo_data = repo.get('repository')
                r_id = repo_data.get('id')
                r_url = repo_data.get('url')

                # Skip requesting and storing repositories that appear multiple times.
                cur.execute(
                    """ SELECT repo_id FROM github WHERE repo_id=%s AND search_query_uuid=%s""",
                    (r_id, search_id)
                )
                repo = cur.fetchone()
                if repo:
                    continue

                repo_data = self.get_repository_by_url(r_url)
                cur.execute(
                    """INSERT INTO github (repo_id, data, language, search_query_uuid, repo_name, repo_url, stargazers_count,forks_count, watchers_count) VALUES 
                    (%s, %s, %s, %s, %s, %s, %s, %s, %s);""",
                    (r_id, json.dumps(repo_data), repo_data.get("language", None), search_id,
                        repo_data.get('name'), repo_data.get('html_url'), repo_data.get('stargazers_count'), repo_data.get('forks_count'), repo_data.get('watchers_count'))
                )
                
            # If there are less than 100 data points, we know we are at the last page. We ignore page 10 as it is often empty.
            if p != 10 and len(data) < 100:
                break

        # Store our current range to continue from here
        self.ranges.append([start, end])
        self._merge_binary_search_ranges()
        print(f"Current ranges:\n{self.ranges}")
        cur.execute(
            """
                INSERT INTO search_history (created, query, range, uuid) VALUES (%s, %s, %s, %s)
                ON CONFLICT (query, created, uuid) DO
                UPDATE SET range=%s;
            """,
            (self.created, query, self.ranges, search_id, self.ranges)
        )
        cur.close()

    def linear_search(self, query, start, end, search_id=None):
        if start >= end:
            return

        # Init search         
        if search_id is None:
            search_id = str(uuid4())
            print(f"search id: {search_id}")

            cur = self.db_con.cursor()
            cur.execute(
                """
                    INSERT INTO search_history (created, query, range, uuid) VALUES (%s, %s, %s, %s)
                """,
                (self.created, query, self.ranges, search_id)
            )
            cur.close()

        offset = 200
        for i in range(start, end, offset):
            self.linear_helper(query, i, i+offset, search_id)

    def binary_search(self, query, offset, delta, end, search_id=None):
        if offset >= end:
            return
        

        # Init search         
        if search_id is None:
            search_id = str(uuid4())
            print(f"search id: {search_id}")

            cur = self.db_con.cursor()
            cur.execute(
                """
                    INSERT INTO search_history (created, query, range, uuid) VALUES (%s, %s, %s, %s)
                """,
                (self.created, query, self.ranges, search_id)
            )
            cur.close()

        # We begin with page 10 and count down.
        # The API search often changes the total_count on the last page (10) to a higher number...
        res = self.search_code(query + f" size:{offset}..{offset+delta}", per_page=100, page=10)
        total_count = int(res.get("total_count", 0))

        print(f"""
        For {offset}..{offset+delta} we found {total_count}. End: {end}.
        You have {self.ratelimit_remaining} / {self.ratelimit_limit} left.
        {self.ratelimit_used} used.
        Next rest: {self.ratelimit_reset}
        """)


        # Even if the total count is <= 1000 here, it can be that it changes.
        # Therefore, we check it in the end again just in case.
        if total_count <= 1000:
            # store results

            cur = self.db_con.cursor()

            # We started with page 10 earlier so it needs to be first.
            # Then we continue with 1 again.
            for p in [10] + list(range(1,10)):
                print("On page %d" % p, sep=" ")

                # We make the request to 10 twice as often it changes the total count for the second request
                res = self.search_code(query + f" size:{offset}..{offset+delta}", per_page=100, page=p)
                total_count = int(res.get("total_count", 0))
                print(f"Total count: {total_count}")

                if total_count > 1000:
                    # If the total count shows to be > 1000, we need to to binary search again
                    break

                data = res.get('items', [])
                print(f"Working through {len(data)} data")

                # TODO log only for comparison
                print(offset, delta, p, len(data))

                for repo in data:
                    repo_data = repo.get('repository')
                    r_id = repo_data.get('id')
                    r_url = repo_data.get('url')

                    # Skip requesting and storing repositories that appear multiple times.
                    cur.execute(
                        """ SELECT repo_id FROM github WHERE repo_id=%s AND search_query_uuid=%s""",
                        (r_id, search_id)
                    )
                    repo = cur.fetchone()
                    if repo:
                        continue

                    repo_data = self.get_repository_by_url(r_url)
                    cur.execute(
                        """INSERT INTO github (repo_id, data, language, search_query_uuid, repo_name, repo_url, stargazers_count,forks_count, watchers_count) VALUES 
                        (%s, %s, %s, %s, %s, %s, %s, %s, %s);""",
                        (r_id, json.dumps(repo_data), repo_data.get("language", None), search_id,
                         repo_data.get('name'), repo_data.get('html_url'), repo_data.get('stargazers_count'), repo_data.get('forks_count'), repo_data.get('watchers_count'))
                    )
                    
                # If there are less than 100 data points, we know we are at the last page. We ignore page 10 as it is often empty.
                if p != 10 and len(data) < 100:
                    break

            # If we found total_count > 1000 during the loop, we jump here but don't want to store it.
            if total_count > 1000:
                # Here, we know we searched offset..offset+delta
                self.ranges.append([offset, offset+delta])
                self._merge_binary_search_ranges()
                print(f"Current ranges:\n{self.ranges}")
                cur.execute(
                    """
                        INSERT INTO search_history (created, query, range, uuid) VALUES (%s, %s, %s, %s)
                        ON CONFLICT (query, created, uuid) DO
                        UPDATE SET range=%s;
                    """,
                    (self.created, query, self.ranges, search_id, self.ranges)
                )
            cur.close()


        if total_count > 1000:
            detla_half = math.ceil(delta / 2)
            self.binary_search(query, offset, detla_half, offset + detla_half, search_id=search_id)
            self.binary_search(query, offset + detla_half, detla_half, offset+delta, search_id=search_id)

        # continue
        self.binary_search(query, offset + delta, delta, end, search_id=search_id)

    def pre_process_database(self):
        """ This function takes a look into the collected data and does
            some pre processing like dedublicating.
        """
        pass

    def get_languages(self, r_url):
        # This request only looks at the default branch
        json_data = self._get(f"{r_url}/languages")   
        return json_data

    def get_readme(self, r_url):
        # This request only looks at the default branch
        json_data = self._get(f"{r_url}/readme")   
        return json_data

    def get_contributors(self, r_url):
        # This request only looks at the default branch
        json_data = self._get(f"{r_url}/contributors?per_page=100")   
        return json_data

    def get_commits(self, r_url):
        # This request only looks at the default branch
        results = []
        page = 1
        while 1:
            json_data = self._get(f"{r_url}/commits?per_page=100&page={page}")  
            results += json_data
            page += 1
            if len(json_data) < 100:
                break
 
        return results
    

    def get_commits_count(self, r_url):
        # This request only looks at the default branch
        res = self._get(f"{r_url}/commits?per_page=1&page=1", as_json=False)       
        reg_str = r"\&page=(\d*)"
        link = res.headers.get("link")
        if not link:
            return 0, None
        matches = re.findall(reg_str, link)

        try:
            result = res.json()
        except:
            result = None

        return matches[-1], result
    
    def get_contributors_count(self, r_url):
        # This request only looks at the default branch
        res = self._get(f"{r_url}/contributors?per_page=1&page=1", as_json=False)       
        reg_str = r"\&page=(\d*)"
        link = res.headers.get("link")
        if not link:
            return 0
        matches = re.findall(reg_str, link)
        return matches[-1]
    
    def update_commits(self, search_id):
        cur = self.db_con.cursor()
        cur.execute(
            """ SELECT DISTINCT ON (repo_url) repo_url, data FROM github WHERE search_query_uuid=%s and commits IS NULL and repo_url IS NOT NULL""",
            (search_id, )
        )
        repos = cur.fetchall()

        results = {}
        for repo in repos:
            print(repo)
            repo_data = repo[1]
            repo_url = repo[0]
            print(repo_url)
            # contributors = self.get_contributors(repo_data["url"])
            # commits = self.get_commits(repo_data["url"])
            contributors_count = self.get_contributors_count(repo_data["url"])

            commits_count, latest_commit = self.get_commits_count(repo_data["url"])
            # results[repo_url] = commits
            print("#Contri: %s" % contributors_count)
            print("#Commits: %s" % commits_count)
            print("Commits: %s" % latest_commit)

            cur.execute(
                """ UPDATE github SET commits_count=%s, contributors_count=%s, commits=%s WHERE repo_url=%s""",
                (commits_count, contributors_count, json.dumps(latest_commit), repo_url)
            )
        
        print(results)

        cur.close()


    def update_languages_and_readme(self, search_id):
        # 1aa45639-2a2e-4f15-97de-31307ec0d221
        cur = self.db_con.cursor()
        cur.execute(
            """ SELECT DISTINCT ON (repo_url) repo_url, data, languages FROM github WHERE search_query_uuid=%s and readme IS NULL and repo_url IS NOT NULL""",
            (search_id, )
        )
        repos = cur.fetchall()

        results = {}
        for repo in tqdm(repos):
            # print(repo)
            repo_data = repo[1]
            repo_url = repo[0]
            languages = repo[2]
            print(repo_url)
            if not languages:
                languages = self.get_languages(repo_data["url"])
            print("languages: %s" % languages)
            readme = self.get_readme(repo_data["url"])
            print("readme: %s" % readme)

            cur.execute(
                """ UPDATE github SET languages=%s, readme=%s WHERE repo_url=%s""",
                (json.dumps(languages), json.dumps(readme), repo_url)
            )
        
        print(results)

        cur.close()

    def get_historical_commits(self, search_id):
        query = f"""
            SELECT DISTINCT repo_name, repo_url, MAX(commits_count), MAX(data::json->>'url')
            FROM github 
            WHERE repo_url IS NOT NULL 
            AND search_query_uuid = '{search_id}' 
            GROUP BY 1, 2 
            HAVING  MAX(stargazers_count) >= 5 
            AND MAX(commits_count) >= 10 
            AND MAX((commits::json->0->'commit'->'author'->>'date')::TIMESTAMP) >= '2020-01-01'::timestamp
        """

        # 030b70fd-015a-46af-b12a-f86fa2fc27c2

        cur = self.db_con.cursor()
        cur.execute(query)
        repos = cur.fetchall()

        for repo in tqdm(repos):
            repo_url = repo[1]
            print(f"working on {repo_url}")
            commit_number = round(repo[2] / 2)
            api_url = repo[3]

            res = self._get(f"{api_url}/commits?per_page=1&page={commit_number}", as_json=False)       

            try:
                result = res.json()
            except:
                result = None

            cur.execute(
                """ INSERT INTO  historical_commits (repo_url, commit_number, data) VALUES (%s, %s, %s)""",
                (repo_url, commit_number, json.dumps(result))
            )
        cur.close()

    ### IT FOLLOWS LONGITUDINAL STUFF
    def download_commit(r_url, sha):
        pass
