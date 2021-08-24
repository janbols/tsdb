CREATE TABLE game (
                      game_id INT PRIMARY KEY,
                      game_date DATE,
                      gametime_et TIME,
                      home_team TEXT,
                      visitor_team TEXT,
                      week INT
);

CREATE TABLE player (
                        player_id INT PRIMARY KEY,
                        height TEXT,
                        weight INT,
                        birthDate DATE,
                        collegeName TEXT,
                        position TEXT,
                        displayName TEXT
);

CREATE TABLE play (
                      gameId INT,
                      playId INT,
                      playDescription TEXT,
                      quarter INT,
                      down INT,
                      yardsToGo INT,
                      possessionTeam TEXT,
                      playType TEXT,
                      yardlineSide TEXT,
                      yardlineNumber INT,
                      offenseFormation TEXT,
                      personnelO TEXT,
                      defendersInTheBox INT,
                      numberOfPassRushers INT,
                      personnelD TEXT,
                      typeDropback TEXT,
                      preSnapVisitorScore INT,
                      preSnapHomeScore INT,
                      gameClock TIME,
                      absoluteYardlineNumber INT,
                      penaltyCodes TEXT,
                      penaltyJerseyNumber TEXT,
                      passResult TEXT,
                      offensePlayResult INT,
                      playResult INT,
                      epa DOUBLE PRECISION,
                      isDefensivePI BOOLEAN
);

CREATE TABLE tracking (
                          time TIMESTAMP,
                          x DOUBLE PRECISION,
                          y DOUBLE PRECISION,
                          s DOUBLE PRECISION,
                          a DOUBLE PRECISION,
                          dis DOUBLE PRECISION,
                          o DOUBLE PRECISION,
                          dir DOUBLE PRECISION,
                          event TEXT,
                          player_id INT,
                          displayName TEXT,
                          jerseyNumber INT,
                          position TEXT,
                          frameId INT,
                          team TEXT,
                          gameid INT,
                          playid INT,
                          playDirection TEXT,
                          route TEXT
);

CREATE TABLE scores (
                        scoreid INT PRIMARY KEY,
                        date DATE,
                        visitor_team TEXT,
                        visitor_team_abb TEXT,
                        visitor_score INT,
                        home_team TEXT,
                        home_team_abb TEXT,
                        home_score INT
);

CREATE TABLE stadium_info (
                              stadiumid INT PRIMARY KEY,
                              stadium_name TEXT,
                              location TEXT,
                              surface TEXT,
                              roof_type TEXT,
                              team_name TEXT,
                              team_abbreviation TEXT,
                              time_zone TEXT
);


CREATE INDEX idx_gameid ON tracking (gameid);
CREATE INDEX idx_playerid ON tracking (player_id);
CREATE INDEX idx_playid ON tracking (playid);

/*
tracking: name of the table
time: name of the timestamp column
*/
SELECT create_hypertable('tracking', 'time');
