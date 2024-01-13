-- Ограничение уникальности для столбца "playerName" в таблице "Account"
ALTER TABLE Account
ADD CONSTRAINT unique_player_name
UNIQUE (playerName);

-- Ограничение CHECK для столбца "lastPlayed > sincePlayed" в таблице "Account"
ALTER TABLE Account
ADD CONSTRAINT check_last_played_gt_since_played
CHECK (lastPlayed > sincePlayed);

-- Ограничение CHECK для столбца "lastPlayed <= now()" в таблице "Account"
ALTER TABLE Account
ADD CONSTRAINT check_last_played_gt_since_played
CHECK (lastPlayed <= now());

-- Ограничение уникальности для столбца "gameName" в таблице "Game"
ALTER TABLE Game
ADD CONSTRAINT unique_game_name
UNIQUE (gameName);

-- Ограничение проверки для столбца "accountLvl" в таблице "Account"
ALTER TABLE Account
ADD CONSTRAINT check_account_lvl
CHECK (accountLvl >= 0);

-- Ограничение проверки для столбца "gameDuration" в таблице "Match"
ALTER TABLE Match
ADD CONSTRAINT check_game_duration
CHECK (gameDuration >= 0);

-- Ограничение проверки для столбца "winrate" в таблице "Champion"
ALTER TABLE Champion
ADD CONSTRAINT check_champ_winrate
CHECK (winrate >= 0);

-- Ограничение проверки для столбца "winrate" в таблице "Champion"
ALTER TABLE Champion
ADD CONSTRAINT check_champ_winrate_1
CHECK (winrate <= 100);

ALTER TABLE Champion
ADD CONSTRAINT check_champ_games_count
CHECK (gamescount >= 0);

-- Ограничение уникальности для столбца "gameName" в таблице "Game"
ALTER TABLE Champion
ADD CONSTRAINT unique_champ_name
UNIQUE (name);

-- Ограничение уникальности для столбца "gameName" в таблице "Game"
ALTER TABLE Champion
ADD CONSTRAINT check_champ_cost
CHECK (cost >= 0);

-- Ограничение по умолчанию для столбца "dataVersion" в таблице "Game"
ALTER TABLE Game
ALTER COLUMN dataVersion SET DEFAULT 'Н/Д';
