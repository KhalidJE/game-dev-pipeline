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
for i, t in enumerate(tables):
    print(i, t.columns.tolist())