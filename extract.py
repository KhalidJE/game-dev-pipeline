import requests, json, os, time
from dotenv import load_dotenv

load_dotenv()

# Initial extraction script for testing DuckDB queries - will change to fetch more data, accomodate pagination, and separate conditional clauses

client_id = os.getenv("CLIENT_ID")
client_secret = os.getenv("CLIENT_SECRET")

def fetch_all(endpoint, query, headers, page=500):
    rows, offset = [], 0
    while True:
        body = f"{query} limit {page}; offset {offset};"
        r = requests.post(f"https://api.igdb.com/v4/{endpoint}", headers=headers, data=body)
        r.raise_for_status()
        batch = r.json()
        if not batch:
            break

        rows += batch
        if len(batch) < page:
            break
        offset += page
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
game_data = "fields name, aggregated_rating, aggregated_rating_count, rating, rating_count, genres, platforms, game_modes, age_ratings, first_release_date, updated_at, hypes, cover.image_id; where aggregated_rating > 75 & aggregated_rating_count > 5; sort aggregated_rating desc;"
games = fetch_all(
    "games",
    game_data,
    {"Client-ID": client_id, "Authorization": f"Bearer {token}"}
) # Where clause will be removed from here and instead reserved for database querying, cover will be expanded inline as well

with open("raw_data/games.json", "w", encoding="utf-8") as f:
    json.dump(games, f, indent=1)
print(f"Saved {len(games)} games")

# Genre Data:
genre_data = "fields name, checksum, created_at, url;"
genres = fetch_all(
    "genres",
    genre_data,
    {"Client-ID": client_id, "Authorization": f"Bearer {token}"}
)

with open("raw_data/genres.json", "w", encoding="utf-8") as f:
    json.dump(genres, f, indent=1)
print(f"Saved {len(genres)} genres")

# Platform Data:
platform_data = "fields name, checksum, created_at;"
platforms = fetch_all(
    "platform_types",
    platform_data,
    {"Client-ID": client_id, "Authorization": f"Bearer {token}"}
)

with open("raw_data/platforms.json", "w", encoding="utf-8") as f:
    json.dump(platforms, f, indent=1)
print(f"Saved {len(platforms)} platforms")

# Game Mode Data:
mode_data = "fields name, checksum, url;"
modes = fetch_all(
    "game_modes",
    mode_data,
    {"Client-ID": client_id, "Authorization": f"Bearer {token}"}
)

with open("raw_data/modes.json", "w", encoding="utf-8") as f:
    json.dump(modes, f, indent=1)
print(f"Saved {len(modes)} game modes")