CREATE OR REPLACE TABLE games AS
SELECT id, name, aggregated_rating, aggregated_rating_count, rating, rating_count, age_ratings, to_timestamp(first_release_date) AS release_date
FROM read_json_auto('raw_data/games.json')
WHERE first_release_date IS NOT NULL;

--GENRES
CREATE OR REPLACE TABLE game_genres AS
SELECT id AS game_id, UNNEST(genres) AS genre_id
FROM read_json_auto('raw_data/games.json')
WHERE genres IS NOT NULL;

CREATE OR REPLACE TABLE genres AS
SELECT id AS genre_id, name AS genre_name
FROM read_json_auto('raw_data/genres.json');

--MODES
CREATE OR REPLACE TABLE game_modes AS
SELECT id AS game_id, UNNEST(modes) AS mode_id
FROM read_json_auto('raw_data/games.json')
WHERE modes IS NOT NULL;

CREATE OR REPLACE TABLE modes AS
select id as mode_id, name AS mode_name
FROM read_json_auto('raw_data/modes.json')

--PLATFORMS
CREATE OR REPLACE TABLE game_platforms AS
SELECT id AS game_id, UNNEST(platforms) AS platform_id
FROM read_json_auto('raw_data/games.json')
WHERE platforms IS NOT NULL;

CREATE OR REPLACE TABLE platforms AS
SELECT id AS platform_id, name AS platform_name
FROM read_json_auto('raw_data/platforms.json')