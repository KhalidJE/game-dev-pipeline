import requests, json, os
from dotenv import load_dotenv

load_dotenv()

# Initial extraction script for testing DuckDB queries - will change to fetch more data, accomodate pagination, and separate conditional clauses

client_id = os.getenv("CLIENT_ID")
client_secret = os.getenv("CLIENT_SECRET")

auth = requests.post("https://id.twitch.tv/oauth2/token", params={
    "client_id": client_id,
    "client_secret": client_secret,
    "grant_type": "client_credentials",
})
auth.raise_for_status()
token = auth.json()["access_token"]

resp = requests.post(
    "https://api.igdb.com/v4/games",
    headers={"Client-ID": client_id, "Authorization": f"Bearer {token}"},
    data="fields name, aggregated_rating, aggregated_rating_count, rating, rating_count, genres, platforms, age_ratings, first_release_date, updated_at, hypes, cover; where aggregated_rating > 75 & aggregated_rating_count > 5; sort aggregated_rating desc; limit 100;",
) # Where clause will be removed from here and instead reserved for database querying, cover will be expanded inline as well
resp.raise_for_status()
games = resp.json()

with open("games_raw.json", "w", encoding="utf-8") as f:
    json.dump(games, f, indent=1)

print(f"Saved {len(games)} games")