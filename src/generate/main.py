from faker import Faker
import psycopg2
from psycopg2 import sql
import random


# Функция для генерации случайных значений для таблицы "Account"
def generate_account_values(fake):
    puuid = fake.uuid4()
    playerName = fake.user_name()
    lastPlayed = fake.date_time_this_decade()
    sincePlayed = fake.date_time_between(start_date="-5y", end_date="now")
    accountLvl = fake.random_int(min=1, max=30)
    return puuid, playerName, lastPlayed, sincePlayed, accountLvl


# Функция для генерации случайных значений для таблицы "Game"
def generate_game_values(fake):
    gameId = fake.uuid4()
    games = [
        "Dota 2",
        "PlayerUnknown's Battlegrounds",
        "Team Fortress 2",
        "Garry's Mod",
        "Grand Theft Auto V",
        "Lol",
        "Valorant",
        "TfT",
        "LoR"
        # Добавьте другие игры Steam в список
    ]
    gameName = random.choice(games)
    players = fake.random_int(min=1, max=100000)
    matches = fake.random_int(min=1, max=10000)
    dataVersion = "{:.2f}".format(random.uniform(3.0, 7.0))
    return gameId, gameName, players, matches, dataVersion


# Функция для генерации случайных значений для списка participants
def generate_participants(fake, num_players):
    participants = [fake.uuid4() for _ in range(num_players)]
    return participants


# Функция для генерации случайных значений для таблицы "Match"
def generate_match_values(fake, num_players):
    matchId = fake.uuid4()
    participants = generate_participants(fake, num_players)
    dataVersion = "{:.2f}".format(random.uniform(3.0, 7.0))
    gameCreation = fake.date_time_between(start_date="-1y", end_date="now")
    gameDuration = fake.random_int(min=1, max=60)  # Пример генерации длительности игры от 1 до 60 минут
    return matchId, participants, dataVersion, gameCreation, gameDuration


# Функция для генерации случайных значений для таблицы "Champion"
def generate_champion_values(fake):
    champId = fake.uuid4()
    name = fake.word()
    gamesCount = fake.random_int(min=0, max=1000)
    winrate = fake.random_int(min=0, max=100)
    cost = fake.random_int(min=0, max=78) * 100  # Генерация кратного 100 значения от 0 до 7800
    return champId, name, gamesCount, winrate, cost


# Функция для вставки данных в указанную таблицу с указанным количеством записей
def insert_data_into_table(table_name, generate_values_func, num_records):
    # Создаем подключение к базе данных
    conn = psycopg2.connect(
        dbname='postgres',
        user='postgres',
        password='postgres',
        host='localhost',
        port='5000'
    )

    # Создаем объект Faker для генерации фиктивных данных
    fake = Faker()

    duplicate_cnt = 0

    # Создаем курсор для выполнения SQL-запросов
    cur = conn.cursor()

    for _ in range(num_records):
        values = generate_values_func(fake, 10)

        # SQL-запрос для вставки данных
        insert_query = sql.SQL(f"""
            INSERT INTO {table_name} VALUES %s
        """)

        try:
            # Попытка выполнить SQL-запрос с данными
            cur.execute(insert_query, (values,))

            # Коммитим транзакцию
            conn.commit()
        except:
            # Обработка исключения, если вставка не удалась из-за дубликата
            duplicate_cnt += 1
            conn.rollback()  # Откатываем транзакцию и продолжаем генерацию

    # Закрываем курсор и соединение
    cur.close()
    conn.close()

    print(f"duplicates {duplicate_cnt}")


insert_data_into_table("Match", generate_match_values, 3000)
