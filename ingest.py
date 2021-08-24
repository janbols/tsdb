import config
import psycopg2

# connect to the database
conn = psycopg2.connect(database=config.DB_NAME,
                        host=config.HOST,
                        user=config.USER,
                        password=config.PASS,
                        port=config.PORT)

# insert CSV file into given table
def insert(csv_file, table_name):
    cur = conn.cursor()
    copy_sql = """
            COPY {table} FROM stdin WITH CSV HEADER
            DELIMITER as ','
            """.format(table=table_name)
    with open(csv_file, 'r') as f:
        cur.copy_expert(sql=copy_sql, file=f)
        conn.commit()
        cur.close()

print("Inserting games.csv")
insert("data/games.csv", "game")

print("Inserting plays.csv")
insert("data/plays.csv", "play")

print("Inserting players.csv")
insert("data/players.csv", "player")

print("Inserting stadium_info.csv")
insert("data/stadium_info.csv", "stadium_info")

print("Inserting scores.csv")
insert("data/scores.csv", "scores")

# iterate over each week's CSV file and insert them
for i in range(1, 18):
    print(f'Inserting week{i}'.format(i = str(i)))
    insert(f'data/week{i}.csv'.format(i=i), "tracking")

conn.close()
