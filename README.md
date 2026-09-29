# Game Dev Pipeline
A data pipeline to extract, transform, and load game data from the IGDB API. Processed data is used to create a report for the described purpose below.

## Introduction
This project was undertaken for the purpose of completing my application to the Information Lab. I recently graduated from City, University of London with a First-Class degree in Computer Science and was previously working as a control & communication systems engineer for a consultancy, where I spent my time working with different teams, including project delivery, network engineering, and (for the majority of my time) the support team at Heathrow.

After graduation and having spent so much time working in systems engineering, I found that I was unsure of what career path to pursue with my degree. Getting to understand more about data analysis and engineering has cleared that up for me, with this project in particular giving me the opportunity to confirm that data engineering is a career path that suits my skillset and my character. For that reason, this programme seems like the best way for me to both begin my career and grow within the field with confidence.

## What I Built & Who For
This pipeline exists to serve a creative director at a game development studio aiming to come up with a new game idea to pitch to a publisher. The director wants to base the decision on what type of games have been succeeding, taking into account several factors:
  * Ratings from external critics
  * Ratings from users/players
  * Genres
  * Platforms
  * Game modes
  * Release date

The director also wants to identify gaps in the market by finding which genres are under-represented in terms of shipping and over-represented in awarding. To do this, game award data is also part of the pipeline. A genre-opportunity table is the culmination of all the director's priorities for this use case, showing which genres have the most games shipped, which genres have the most games awarded, and how many games are awarded per 1000 per genre.

A final interactive report is created using the pre-existing tables as well as two tables specifically created for the report. The interactive report takes the form of a web page with 4 pages; Home (abstract, general statistics for genre opportunity), Breakdown (shows comparisons based on nomination rates, player ratings, critic ratings, etc.), Game Finder (allows for lookups of individual titles, complete with a search box), and Trends (shows releases and ratings as they change year by year, allows for filtering by genres).

 ## The Data
 Data is fetched from the IGDB API, using a Twitch account for authorisation (but raw data is committed so that step isn't needed unless re-fetching is required). Data pertaining to ~4,800 games is fetched. The following data is extracted for the aforementioned purpose:
 Games Endpoint
   * name
   * aggregated_rating - ensures ratings come from credible sources
   * aggregated_rating_count - to ensure average external critic ratings are not biased
   * rating - to get an idea of user opinions
   * rating_count - proves validity of average scores
   * genres - gives the director an idea of what genres perform best
   * platforms - allows director to plan for different device compatibility
   * game modes - allows director to analyse which modes (e.g. singleplayer, PVP, co-op, etc.) are most commonly supported
   * first_release_date - proves longevity of analysed games
   * cover - for use in report presentation (see future work)
    
  Scope filters include:
   * first_release_date >= 1388534400 - to take into account only more recent games from 2014 onwards, enabling matching with GOTY data
   * rating_count >= 10 - this filter further reduces bloat and makes more sense for the target audience as the director would want to know which genres are most noticed by the market.

   Scope filters that were removed:
   * game_type.id = 0 - did not limit to just main games as expected and instead cut out some games during fetching.
      * this was instead handled in transform.sql where I specified specific types to exclude.
   * summary != null - some GOTY winners were listed in IGDB with no summary (such as Inside).
   * status = null | status = 0 | status = 8 - limits results to just released or delivered (or no defined status) rather than unfinished but also caused issues with some titles being marked with the wrong status and thus not showing up.

   These filters dropped the returned results from ~304k to ~24k games, with rating_count initially filtering to != 0 then >= 10 and filtering out a further 20k games to bring the total to ~4.8k.

Genres Endpoint
   * name
   * checksum - track changes to IGDB entry between pulls

Platforms Endpoint
   * name
   * checksum - track changes to IGDB entry between pulls

Game Modes Endpoint
   * name
   * checksum - track changes to IGDB entry between pulls

Game Awards
   * Event (year of award)
   * Game (name of title)
      * is_winner - derived from list of nominees (first title at the top of the list each year is the winner)

ID field is returned by default in all cases.

Link to IGDB API documentation: https://api-docs.igdb.com

## How It Works
Uses DuckDB for a local database and Python for extraction code. Evidence.dev is used for the final interactive report.

Game data originates from IGDB, specifically pulled from the following endpoints: game, genres, platform_types, game_modes.
Game award data is pulled from Wikipedia (https://en.wikipedia.org/wiki/The_Game_Award_for_Game_of_the_Year) and matched to game data pulled from IGDB.

Uses keyset pagination for data fetching. Made a switch from offset paging to improve data consistency; rows were being skipped between extraction script runs and returning new results each time. Was also the better choice for performance as it keeps execution time O(1).

## How To Run It
Requires Python 3.11+ and Node.js 18+. The raw data is committed, so no API credentials are needed unless a re-fetch is required.

Install the Python dependencies from the project root:
```
pip install -r requirements.txt
```

0. Optional: if raw data needs to be fetched again, copy `.env.example` to `.env`, fill in your Twitch client ID and secret, then run `python extract.py` and `python extract_goty.py` from the project root.
1. From the project root, run `python build.py` to build `dev.db`.
2. From the report/ folder:
   ```
   npm install
   npm run sources   # pulls the report tables out of dev.db
   npm run dev       # opens the report at http://localhost:3000
   ```
If `dev.db` changes (i.e. if running `build.py` again), rerun `npm run sources`.

## What I Would Do Next
Adding more awards would be the priority; there are highly acclaimed games belonging to under-represented genres (e.g. MOBAs such as League of Legends) that won't be accurately portrayed through just The Game Awards' GOTY nominations. Awards such as the BAFTA Games Awards, The D.I.C.E. Awards, The Game Developers Choice Awards (GDCA), and The Golden Joystick Awards all select games differently. For instance, the D.I.C.E. Awards' voters are game developers, engineers and industry professionals (so it acts as a form of peer review) whereas the Golden Joystick Awards are predominantly voted on by the global public and gaming community.

For the specified audience, having this extra information would allow them to make an informed decision with greater confidence.

Also, genre_opportunity still counts DLCS, expansions, bundles, etc., so for future work, it would be good to find a way to add a sanity check for non-main games without losing important entries that could be tied to game award data.

One last, purely aesthetic change that could be made is to make use of the cover endpoint and load game cover images on the final report when a game is searched. The endpoint is already pulled but has not been used.

## Project Structure
```
game_dev_pipeline/
├── extract.py              # fetches games, genres, platforms and game modes from the IGDB API (keyset pagination)
├── extract_goty.py         # scrapes The Game Awards GOTY nominees from Wikipedia
├── transform.sql           # builds the cleaned, bridge, awards, genre_opportunity and report_* tables
├── build.py                # runs transform.sql to (re)build dev.db
├── requirements.txt        # Python dependencies
├── .env.example            # template for Twitch/IGDB credentials (only needed for extract.py)
├── raw_data/
│   ├── games.json          # raw IGDB game data
│   ├── genres.json
│   ├── modes.json
│   ├── platforms.json
│   └── awards/
│       ├── goty.html       # saved Wikipedia page
│       ├── goty_list.csv   # parsed GOTY nominees and winners
│       └── goty_manual.csv # nominees matched to IGDB IDs by hand where names differ
└── report/                 # Evidence report (runs locally, reads dev.db)
    ├── evidence.config.yaml
    ├── package.json
    ├── sources/pipeline/   # DuckDB connection to ../dev.db and one query per report table
    └── pages/
        ├── index.md        # home: genre opportunity, GOTY nominations per 1,000 games shipped
        ├── breakdown.md    # genres, platforms and game modes by volume, ratings and nomination rate
        ├── trends.md       # releases and ratings over time, filterable by genre
        └── games.md        # searchable list of individual games
```

`dev.db` is not committed; it is created by `build.py`.

### Tables (dev.db)
- `games`, `genres`, `platforms`, `modes` - cleaned IGDB data
- `game_genres`, `game_platforms`, `game_modes` - bridge tables linking games to each attribute
- `awards`, `awarded_games` - GOTY nominees and their matched IGDB games
- `genre_opportunity` - games shipped, GOTY nominations and nominations per 1,000 games, by genre
- `report_games` - one row per game with ratings and GOTY status (used by the report)
- `report_game_attributes` - one row per game per genre, platform or game mode (used by the report's filters)

## Where AI Helped
* Initial resources/links for learning & available information for IGDB API
* Switching from offset paging to keyset paging (fetch_all) troubleshooting
* Genre_opportunity, report_games, report_game_attributes tables troubleshooting
* Extract_goty.py - troubleshooting issues with data frames
* Queries for checking for mismatched data
* Formatting for Project Structure section
* Claude code used for majority of Evidence interactive report
* Removed any unnecessary files created for testing throughout the process
