CREATE OR REPLACE TABLE games AS
SELECT id, name, aggregated_rating, aggregated_rating_count, rating, rating_count,
    to_timestamp(first_release_date) AS release_date,
    trim(regexp_replace(lower(replace(name, '&', 'and')), '[^a-z0-9]+', ' ', 'g')) AS simple_title,
    EXTRACT(YEAR FROM to_timestamp(first_release_date)) AS release_year
FROM read_json_auto('raw_data/games.json')
WHERE first_release_date IS NOT NULL
QUALIFY row_number() OVER (PARTITION BY id ORDER BY id) = 1; --ensures 1 row per game to fix 4k duplicate issue

--GENRES
CREATE OR REPLACE TABLE game_genres AS
SELECT DISTINCT id AS game_id, UNNEST(genres) AS genre_id
FROM read_json_auto('raw_data/games.json')
WHERE genres IS NOT NULL AND first_release_date IS NOT NULL;

CREATE OR REPLACE TABLE genres AS
SELECT id AS genre_id, name AS genre_name
FROM read_json_auto('raw_data/genres.json');

--MODES
CREATE OR REPLACE TABLE game_modes AS
SELECT DISTINCT id AS game_id, UNNEST(game_modes) AS mode_id
FROM read_json_auto('raw_data/games.json')
WHERE game_modes IS NOT NULL AND first_release_date IS NOT NULL;

CREATE OR REPLACE TABLE modes AS
select id as mode_id, name AS mode_name
FROM read_json_auto('raw_data/modes.json');

--PLATFORMS
CREATE OR REPLACE TABLE game_platforms AS
SELECT DISTINCT id AS game_id, UNNEST(platforms) AS platform_id
FROM read_json_auto('raw_data/games.json')
WHERE platforms IS NOT NULL AND first_release_date IS NOT NULL;

CREATE OR REPLACE TABLE platforms AS
SELECT id AS platform_id, name AS platform_name
FROM read_json_auto('raw_data/platforms.json');


--GAME AWARDS
CREATE OR REPLACE TABLE awards AS
SELECT title, award_year, is_winner,
trim(regexp_replace(lower(replace(title, '&', 'and')), '[^a-z0-9]+', ' ', 'g')) AS simple_title
FROM read_csv_auto('raw_data/awards/goty_list.csv')
QUALIFY row_number() OVER (PARTITION BY title, award_year ORDER BY is_winner DESC) = 1;

CREATE OR REPLACE TABLE awarded_games AS
SELECT a.title, a.award_year, a.is_winner, g.id AS game_id, 'exact' AS match_method
FROM awards a
JOIN games g ON g.simple_title = a.simple_title
QUALIFY row_number() OVER (
    PARTITION BY a.title, a.award_year
    ORDER BY abs(a.award_year - g.release_year)
) = 1
UNION ALL --unions in data that is in awards but not awarded_games
SELECT title, award_year, is_winner, game_id, 'manual' as match_method
FROM read_csv_auto('raw_data/awards/goty_manual.csv');