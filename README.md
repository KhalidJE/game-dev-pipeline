# game-dev-pipeline
A data pipeline to extract, transform, and load game data from the IGDB API. Processed data is used to create a report for the described purpose below.

## What I Built & Who For
This pipeline exists to serve a creative director at a game development studio aiming to come up with a new game idea to pitch to a publisher. The individual wants to base the decision on what type of games have been succeeding, taking into account several factors:
  * Ratings from external critics
  * Ratings from users/players
  * Genres
  * Platforms
  * Release date

 ## The Data
 Data is fetched from the IGDB API, using a Twitch account for authorisation. Data pertaining to ~24,000 games is fetched. The following data is extracted for the aforementioned purpose:
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
   * cover - for use in report presentation
   * age_ratings - to keep track of target audiences
    
  Scope filters include:
   * game_type.id = 0 - limits results to just main games, excluding DLCs and expansions in the process
   * summary != null - filters out unfinished entries
   * status = null | status = 0 | status = 8 - limits results to just released or delivered (or no defined status) rather than unfinished
   * first_release_date >= 2010 - to take into account only more recent games and exclude older, less relevant titles
   * rating_count != 0 - just acts as a further filter to reduce bloat, final two filters drop returned count from ~304k to ~24k games

Genres Endpoint
   * name
   * checksum - track changes to IGDB entry between pulls

Platforms Endpoint
   * name
   * checksum - track changes to IGDB entry between pulls

Game Modes Endpoint
   * name
   * checksum - track changes to IGDB entry between pulls

ID field is returned by default in all cases.

Link to IGDB API documentation: https://api-docs.igdb.com


## How It Works
Uses DuckDB for a local database and Python for extraction code. Evidence.dev is used for the final interactive report.

## How To Run It

## What I Would Do Next

## Where AI Helped
