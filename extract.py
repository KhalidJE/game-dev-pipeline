import requests, json, os, time, pathlib
from dotenv import load_dotenv

load_dotenv()

# Initial extraction script for testing DuckDB queries - will change to fetch more data, accomodate pagination, and separate conditional clauses

client_id = os.getenv("CLIENT_ID")
client_secret = os.getenv("CLIENT_SECRET")

def fetch_all(endpoint, fields, headers, scope=None, page=500):
    rows, last_id = [], 0
    while True:
        where = f"id > {last_id}"
        if scope:
            where = f"({scope}) & {where}"
        body = f"{fields} where {where}; sort id asc; limit {page};"
        r = requests.post(f"https://api.igdb.com/v4/{endpoint}", headers=headers, data=body)
        r.raise_for_status()
        batch = r.json()
        if not batch:
            break

        rows += batch
        last_id = batch[-1]["id"]
        time.sleep(0.25) # adhere to 4 requests/sec limit
    return rows

auth = requests.post("https://id.twitch.tv/oauth2/token", params={
    "client_id": client_id,
    "client_secret": client_secret,
    "grant_type": "client_credentials",
})
auth.raise_for_status()
token = auth.json()["access_token"]

# Game Data:
GAME_FIELDS = ("fields name, aggregated_rating, aggregated_rating_count, rating, rating_count, genres, platforms, game_modes, game_type, first_release_date, cover.image_id;")
GAME_SCOPE = ("first_release_date >= 1388534400 & rating_count >= 10")

#game_data = "fields name, aggregated_rating, aggregated_rating_count, rating, rating_count, genres, platforms, game_modes, first_release_date, cover.image_id; where game_type.id = 0 & first_release_date >= 1388534400 & rating_count != 0;"
games = fetch_all(
    "games",
    GAME_FIELDS, 
    {"Client-ID": client_id, "Authorization": f"Bearer {token}"},
    scope=GAME_SCOPE,
) # where clause for filtering by aggregated ratings removed from extraction and reserved for database querying

with open("raw_data/games.json", "w", encoding="utf-8") as f:
    json.dump(games, f, indent=1)
print(f"Saved {len(games)} games")

# Genre Data:
genre_data = "fields name, checksum;"
genres = fetch_all(
    "genres",
    genre_data,
    {"Client-ID": client_id, "Authorization": f"Bearer {token}"}
)

with open("raw_data/genres.json", "w", encoding="utf-8") as f:
    json.dump(genres, f, indent=1)
print(f"Saved {len(genres)} genres")

# Platform Data:
platform_data = "fields name, checksum;"
platforms = fetch_all(
    "platform_types",
    platform_data,
    {"Client-ID": client_id, "Authorization": f"Bearer {token}"}
)

with open("raw_data/platforms.json", "w", encoding="utf-8") as f:
    json.dump(platforms, f, indent=1)
print(f"Saved {len(platforms)} platforms")

# Game Mode Data:
mode_data = "fields name, checksum;"
modes = fetch_all(
    "game_modes",
    mode_data,
    {"Client-ID": client_id, "Authorization": f"Bearer {token}"}
)

with open("raw_data/modes.json", "w", encoding="utf-8") as f:
    json.dump(modes, f, indent=1)
print(f"Saved {len(modes)} game modes")