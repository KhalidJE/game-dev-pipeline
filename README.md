# game-dev-pipeline
A data pipeline to extract, transform, and load game data from the IGDB API. Processed data is used to create a report for the described purpose below.

## What I Built & Who For
This pipeline exists to serve a creative director at a game development studio aiming to come up with a new game idea to pitch to a publisher. The individual wants to base the decision on what type of games have been succeeding, taking into account several factors:
  * Ratings from external critics
  * Ratings from users/players
  * Genres
  * Platforms
  * Game modes
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
    
  Scope filters include:
   * first_release_date >= 1388534400 - to take into account only more recent games from 2014 onwards, enabling matching with GOTY data
   * rating_count >= 10 - just acts as a further filter to reduce bloat. 

   Scope filters that were removed:
   * game_type.id = 0 - did not limit to just main games as expected and instead cut out some games during fetching.
   * summary != null - some GOTY winners were listed in IGDB with no summary (such as Inside)
   * status = null | status = 0 | status = 8 - limits results to just released or delivered (or no defined status) rather than unfinished but also caused issues with some titles being marked with the wrong status and thus not showing up.

   These filters dropped the returned results from ~304k to ~24k games, with rating_count initially filtering to != 0 then >= 10 and filtering out a further 20k games to bring the total to 4.8k+.

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

## What I Would Do Next

## Where AI Helped
