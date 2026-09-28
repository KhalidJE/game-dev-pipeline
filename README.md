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

The director also wants to identify gaps in the market by finding which genres are under-represented in terms of shipping and over-represented in awarding. To do this, game award data is also part of the pipeline. A genre-opportunity table is the culmination of all the director's priorities for this use case, showing which genres have the most games shipped, which genres have the most games awarded, and how many games are awarded per 1000 per genre.

A final interactive report...

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
   * rating_count >= 10 - this filter further reduces bloat and makes more sense for the target audience as the director would want to know which genres are most noticed by the market.

   Scope filters that were removed:
   * game_type.id = 0 - did not limit to just main games as expected and instead cut out some games during fetching.
      * this was instead handled in transform.sql where I specified specific types to exclude.
   * summary != null - some GOTY winners were listed in IGDB with no summary (such as Inside).
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
Adding more awards would be the priority; there are highly acclaimed games belonging to under-represented genres (e.g. MOBAs such as League of Legends) that won't be accurately portrayed through just The Game Awards' GOTY nominations. Awards such as the BAFTA Games Awards, The D.I.C.E. Awards, The Game Developers Choice Awards (GDCA), and The Golden Joystick Awards all select games differently. For instance, the D.I.C.E. Awards' voters are game developers, engineers and industry professionals (so it acts as a form of peer review) whereas the Golden Joystick Awards are predominantly voted on by the global public and gaming community.

For the specified audience, having this extra information would allow them to make an informed decision with greater confidence.

## Where AI Helped
* switching from offset paging to keyset paging (fetch_all)
* genre_opportunity table
* extract_goty.py - understanding how to work with data frames
* queries for checking for mismatched data
* resources/links for learning