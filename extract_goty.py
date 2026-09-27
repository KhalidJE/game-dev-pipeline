import requests, pathlib
import pandas as pd

#Game Awards
UA = "goty-pipeline/1.0 (https://github.com/KhalidJE/game-dev-pipeline)" #custom user agent string to identify scraper in compliance with wikipedia's policy
url = "https://en.wikipedia.org/wiki/The_Game_Award_for_Game_of_the_Year"

output_dir = pathlib.Path("raw_data/awards")
output_dir.mkdir(parents=True, exist_ok=True)

response = requests.get(url, headers={"User-Agent": UA}, timeout=30)
response.raise_for_status()

output_file = output_dir / "goty.html"
output_file.write_text(response.text, encoding="utf-8")
print(f"Page saved to {output_file}")

tables = pd.read_html(output_file)
df = tables[1]

df = df.rename(columns={"Event": "award_year", "Game": "title"})[["title", "award_year"]]

# cleanup
df["award_year"] = df["award_year"].astype(str).str.extract(r"(\d{4})")[0]
df["award_year"] = df["award_year"].ffill().astype(int)
df["title"] = df["title"].str.replace(r"\[.*?\]", "", regex=True).str.strip()
df["title"] = df["title"].str.replace("‡", "").str.strip() # all GOTY winners have the ‡ symbol at the end of their title, not needed for identification - winners are always top of the list

df["is_winner"] = df.groupby("award_year").cumcount() == 0

df.to_csv("raw_data/awards/goty_list.csv", index=False)

# code for finding the index of the correct table:
# for i, t in enumerate(tables):
#     print(i, t.columns.tolist())