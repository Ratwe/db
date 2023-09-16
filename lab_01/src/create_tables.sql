-- Создаем базу данных
CREATE DATABASE mydatabase;

-- Используем созданную базу данных
\c mydatabase;

-- Создаем таблицу "Account"
CREATE TABLE IF NOT EXISTS Account (
    puuid VARCHAR(255) PRIMARY KEY,
    playerName VARCHAR(255),
    lastPlayed TIMESTAMP,
    sincePlayed TIMESTAMP,
    accountLvl INT
);

-- Создаем таблицу "Game"
CREATE TABLE IF NOT EXISTS Game (
    gameId VARCHAR(255) PRIMARY KEY,
    gameName VARCHAR(255),
    players INT,
    matches INT,
    dataVersion VARCHAR(50)
);

-- Создаем таблицу "Match"
CREATE TABLE IF NOT EXISTS Match (
    matchId VARCHAR(255) PRIMARY KEY,
    participants TEXT[],
    dataVersion numeric(2, 1),
    gameCreation TIMESTAMP,
    gameDuration INT
);

-- Создаем таблицу "Champion"
CREATE TABLE IF NOT EXISTS Champion (
    champId VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    gamesCount INT,
    winrate DECIMAL(5, 2),
    cost INT
);

-- Завершаем SQL-файл
