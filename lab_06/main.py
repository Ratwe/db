import random

from sqlalchemy import create_engine, text, inspect, MetaData, VARCHAR, Integer, Numeric
from sqlalchemy.testing.schema import Table, Column

engine = create_engine("postgresql+psycopg2://postgres:postgres@localhost:5000/postgres")
metadata = MetaData()


def menu():
    count = 3
    while True:
        count += 1
        if count == 4:
            count = 0
            print("1. Выполнить скалярный запрос")
            print("2. Выполнить запрос с несколькими соединениями (JOIN)")
            print("3. Выполнить запрос с ОТВ(CTE) и оконными функциями")
            print("4. Выполнить запрос к метаданным")
            print("5. Вызвать скалярную функцию (написанную в третьей лабораторной работе)")
            print("6. Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе)")
            print("7. Вызвать хранимую процедуру (написанную в третьей лабораторной работе)")
            print("8. Вызвать системную функцию или процедуру")
            print("9. Создать таблицу в базе данных, соответствующую тематике БД")
            print("10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY")
            print("11. Выход")

        choice = input("Выберите номер опции: ")

        match choice:
            case "1":
                execute_scalar_query()
            case "2":
                execute_join_query()
            case "3":
                execute_cte_query()
            case "4":
                execute_metadata_query()
            case "5":
                call_scalar_function()
            case "6":
                call_table_function()
            case "7":
                call_stored_procedure()
            case "8":
                call_system_function()
            case "9":
                create_table()
            case "10":
                insert_data()
            case "11":
                break
            case _:
                print("Неверный ввод. Попробуйте еще раз.")

        metadata.create_all(engine)


def execute_scalar_query():
    print("Выполняем скалярный запрос...")
    with engine.connect() as connection:
        result = connection.execute(text("SELECT version();"))
        print(result.scalar())


def execute_join_query():
    print("Выполняем запрос с JOIN...")
    with engine.connect() as connection:
        query = text("""
            SELECT match.matchid, match.dataversion
            FROM match
            WHERE EXISTS (
                SELECT match.dataversion
                FROM match
                INNER JOIN game ON match.dataversion = game.dataversion
            );
        """)
        result = connection.execute(query)

        rows = result.fetchall()
        for row in rows:
            print(f"Match ID: {row[0]}, Data Version: {row[1]}")


def execute_cte_query():
    print("Выполняем запрос с ОТВ(CTE) и оконными функциями...")

    with engine.connect() as connection:
        query = text("""
            WITH CTE AS (
                SELECT
                    puuid,
                    ROW_NUMBER() OVER (PARTITION BY accountlvl ORDER BY accountlvl) AS rn
                FROM account
            )
            select * from cte
            where rn = 2;
        """)
        result = connection.execute(query)

        rows = result.fetchall()
        for row in rows:
            print(f"puuid: {row[0]}, rn: {row[1]}")


def execute_metadata_query():
    print("Выполняем запрос к метаданным...")
    inspector = inspect(engine)
    if inspector.has_table('game'):
        print("Таблица Game существует")
    else:
        print("Таблицы Game не существует")
    if inspector.has_table('match'):
        print("Таблица Match существует")
    else:
        print("Таблицы Match не существует")


def call_scalar_function():
    print("Вызываем скалярную функцию...")

    with engine.connect() as connection:
        # Call the table function and fetch the result
        query = text(f"SELECT one();")
        result = connection.execute(query)

        # Fetch and print the results
        rows = result.fetchall()
        for row in rows:
            print(f"One: {row[0]}")


def call_table_function():
    print("Вызываем многооператорную или табличную функцию...")

    with engine.connect() as connection:
        # Call the table function and fetch the result
        query = text(f"select get_between_winrate(0, 20);")
        result = connection.execute(query)

        # Fetch and print the results
        rows = result.fetchall()
        print("get_between_winrate(0, 20) result:")
        for row in rows:
            print(f"{row[0]}")


def call_stored_procedure():
    print("Вызываем хранимую процедуру...")

    with engine.connect() as connection:
        query = text("call get_table_metadata();")
        connection.execute(query)
        print("get_table_metadata() called")


def call_system_function():
    print("Вызываем системную функцию или процедуру...")

    with engine.connect() as connection:
        query = text("select get_between_winrate(0, 20);")
        result = connection.execute(query)
        rows = result.fetchall()
        for row in rows:
            print(f"(Name, winrate): {row[0]})")

def create_table():
    print("Создаем таблицу в базе данных...")

    game_table = Table(
        'game', metadata,
        Column('gameId', VARCHAR(255), primary_key=True),
        Column('gameName', VARCHAR(255)),
        Column('players', Integer),
        Column('matches', Integer),
        Column('dataVersion', Numeric(2, 1)),
        extend_existing=True
    )

    # Create the table
    game_table.create(engine, checkfirst=True)


def insert_data():
    print("Выполняем вставку данных в созданную таблицу...")

    with engine.connect() as connection:
        # Generate random data
        random_data = [
            {
                'gameId': f'game_{random.randint(1, 1000000)}',
                'gameName': f'Game {random.randint(1, 1000000)}',
                'players': random.randint(1, 10),
                'matches': random.randint(5, 20),
                'dataVersion': round(random.uniform(1, 5), 1),
            }
            for i in range(1, 11)  # Inserting 10 rows as an example
        ]

        # Insert the random data into the Game table
        connection.execute(text("""
            INSERT INTO game (gameId, gameName, players, matches, dataVersion)
            VALUES (:gameId, :gameName, :players, :matches, :dataVersion)
        """), random_data)

        # Verify the insertion by selecting and printing the data
        result = connection.execute(text("SELECT * FROM game")).fetchall()
        print("\nInserted Data:")
        for row in result:
            print(row)


menu()
