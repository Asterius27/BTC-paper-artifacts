from crawler import GithubCrawler
from database import Database
from argparse import ArgumentParser

from config import GIT_API_KEYS

def run_crawler(search_query='"from django"', range="0,384000", language="Python"):
    database = Database()
    database.set_up_database()
    
    db_con = database.get_db_con()

    if language:
        search_query += f" language:{language}"
    
    print(f"You are looking for: {search_query}")
    # Looking for previous searches
    cur = db_con.cursor()
    cur.execute("SELECT created, range, uuid FROM search_history WHERE query = %s ORDER BY created DESC LIMIT 3", (search_query,))
    previous_searches = cur.fetchall()
    cur.close()

    crawler = GithubCrawler(api_keys=GIT_API_KEYS, db_con=db_con)
    offset = int(range.split(',')[0])
    delta = 500

    # Fixed searchable filesize by 384000:
    # https://docs.github.com/en/free-pro-team@latest/rest/search/search?apiVersion=2022-11-28#search-code:~:text=Only%20files%20smaller%20than%20384%20KB%20are%20searchable.
    max_filesize = int(range.split(',')[1])
    
    search_id = None

    if len(previous_searches) > 0:
        print("We found previous searches with this query:")
    for idx, search in enumerate(previous_searches):
        print(f"{idx}) {search[0]}: {search[1]}")
    if len(previous_searches) > 0:
        print("Do you want to continue a run?")
        cnt_nr = input("Number (or empty if not): ")
        if cnt_nr:
            search_id = previous_searches[int(cnt_nr)][2]
            prv_range = previous_searches[int(cnt_nr)][1]
            prv_max_range = prv_range[-1][1]
            offset = prv_max_range

    # crawler.binary_search(search_query, offset, delta, max_filesize, search_id=search_id)
    crawler.linear_search(search_query, start=offset, end=max_filesize, search_id=search_id)
    crawler.pre_process_database()
    db_con.close()

def update_database():
    search_uuid = input("Give me your search uuid: ")
    database = Database()
    db_con = database.get_db_con()
    crawler = GithubCrawler(api_keys=GIT_API_KEYS, db_con=db_con)

    # crawler.update_commits(search_uuid)
    crawler.update_languages_and_readme(search_uuid)
    
def historical_commits():
    search_uuid = input("Give me your search uuid: ")
    database = Database()
    db_con = database.get_db_con()
    crawler = GithubCrawler(api_keys=GIT_API_KEYS, db_con=db_con)

    # crawler.update_commits(search_uuid)
    crawler.get_historical_commits(search_uuid)

def run_codelyzer():
    codelyzer = GithubCodelyzer()

def main():    
    parser = ArgumentParser(
                    prog='Codelyzer',
                    description='This program crawls Github for repositories to analyze with codeQL')
    parser.add_argument('-s', '--search', type=str, help='The search query used in Github')
    parser.add_argument('-r', '--range', type=str, help='The range that is used for the search [start,end]')
    parser.add_argument('-u', '--update', type=bool, help='Update the database')
    parser.add_argument('-i', '--historical', type=bool, help='Get historical commits')
    args = parser.parse_args()
    
    if args.update:
        update_database()
    elif args.historical:
        historical_commits()
    else:
        if args.search and args.range:
            run_crawler(search_query=args.search, range=args.range)
        else:
            run_crawler()

if __name__ == "__main__":
    main()

    
    
