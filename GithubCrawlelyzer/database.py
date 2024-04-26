import psycopg2

class Database:
    """ The database class handles all connections
        and queries to the database.
    """

    def __init__(self, dbname="github_db", user="git_user", password="***", host="127.0.0.1", port=5432) -> None:
        self.dbname = dbname
        self.user = user
        self.password = password
        self.host = host
        self.port = port
        self.connections = []

    def __del__(self):
        for con in self.connections:
            if not con.closed:
                con.close()

    def set_up_database(self):
        con = self.get_db_con()
        cur = con.cursor()

        # Create Github Table
        cur.execute("""
            CREATE TABLE IF NOT EXISTS github (
                    id SERIAL PRIMARY KEY,
                    search_query_uuid VARCHAR(36),
                    repo_id INTEGER,
                    repo_name TEXT,
                    repo_url TEXT,
                    stargazers_count INTEGER,
                    forks_count INTEGER,
                    watchers_count INTEGER,
                    language TEXT,
                    data JSONB
            );
        """)

        # Create Search History Table
        cur.execute("""
            CREATE TABLE IF NOT EXISTS search_history (
                    id SERIAL PRIMARY KEY,
                    uuid VARCHAR(36),
                    query TEXT,
                    range INTEGER[],
                    created TIMESTAMP,
                    UNIQUE (query, created, uuid)
            );
        """)

        cur.close()
        con.close()

    def get_db_con(self, autocommit=True):
        con = psycopg2.connect(dbname=self.dbname, user=self.user, password=self.password, host=self.host, port=self.port)
        con.autocommit = autocommit
        self.connections.append(con)
        return con
