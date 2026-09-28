CREATE OR REPLACE TABLE games AS
SELECT id, name, aggregated_rating, aggregated_rating_count, rating, rating_count,
    to_timestamp(first_release_date) AS release_date,
    trim(regexp_replace(lower(replace(name, '&', 'and')), '[^a-z0-9]+', ' ', 'g')) AS simple_title,
    EXTRACT(YEAR FROM to_timestamp(first_release_date)) AS release_year
FROM read_json_auto('raw_data/games.json')
WHERE first_release_date IS NOT NULL AND (game_type NOT IN (1 | 2 | 3 | 13 | 14) OR game_type IS NULL) --excludes DLCs, expansions, bundles, packs and updates
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

CREATE OR REPLACE TABLE genre_opportunity AS
WITH per_genre AS (
    SELECT genre_id, count(DISTINCT game_id) AS games_shipped
    FROM game_genres GROUP BY genre_id
),
awards_per_genre AS (
    SELECT gg.genre_id, count(DISTINCT ag.game_id) AS awarded
    FROM awarded_games ag
    JOIN game_genres gg ON gg.game_id = ag.game_id
    GROUP BY gg.genre_id
)
SELECT g.genre_name, p.games_shipped, coalesce(a.awarded, 0) AS awarded, coalesce(a.awarded, 0) * 1000.0 / p.games_shipped AS awarded_per_1000
FROM genres g
JOIN per_genre p ON p.genre_id = g.genre_id
LEFT JOIN awards_per_genre a ON a.genre_id = g.genre_id
ORDER BY awarded_per_1000 DESC;

--REPORT TABLES (flattened for the Evidence report, exported by build.py)
CREATE OR REPLACE TABLE report_games AS
WITH goty AS (
    SELECT game_id, bool_or(is_winner) AS won, min(award_year) AS award_year
    FROM awarded_games
    GROUP BY game_id
)
SELECT g.id AS game_id, g.name, g.release_year,
    round(g.aggregated_rating, 1) AS critic_rating, g.aggregated_rating_count AS critic_rating_count,
    round(g.rating, 1) AS user_rating, g.rating_count AS user_rating_count,
    CASE WHEN goty.won THEN 'Winner' WHEN goty.game_id IS NOT NULL THEN 'Nominee' ELSE 'Not nominated' END AS goty_status,
    goty.award_year
FROM games g
LEFT JOIN goty ON goty.game_id = g.id;

CREATE OR REPLACE TABLE report_game_attributes AS --one row per game per genre/platform/mode
WITH attributes AS (
    SELECT gg.game_id, 'Genre' AS attribute_type, ge.genre_name AS attribute
    FROM game_genres gg JOIN genres ge ON ge.genre_id = gg.genre_id
    UNION ALL
    SELECT gp.game_id, 'Platform', p.platform_name
    FROM game_platforms gp JOIN platforms p ON p.platform_id = gp.platform_id
    UNION ALL
    SELECT gm.game_id, 'Game mode', m.mode_name
    FROM game_modes gm JOIN modes m ON m.mode_id = gm.mode_id
)
SELECT a.attribute_type, a.attribute, r.*,
    CASE WHEN r.goty_status <> 'Not nominated' THEN 1 ELSE 0 END AS is_nominated
FROM attributes a
JOIN report_games r ON r.game_id = a.game_id; --inner join keeps attributes consistent with the games scope filters
