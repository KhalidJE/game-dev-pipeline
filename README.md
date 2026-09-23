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
 Data is fetched from the IGDB API, using a Twitch account for authorisation. The following data is extracted for the aforementioned purpose:
   * name
   * aggregated_rating - ensures ratings come from credible sources
   * aggregated_rating_count - to ensure average external critic ratings are not biased
   * rating - to get an idea of user opinions
   * rating_count - proves validity of average scores
   * genres - gives the director an idea of what genres perform best
   * platforms - allows director to plan for different device compatibility
   * first_release_date - proves longevity of analysed games
   * cover - for use in report presentation

Link to IGDB API documentation: https://api-docs.igdb.com


## How It Works
Uses DuckDB for a local database and Python for extraction code. Evidence.dev is used for the final interactive report.

## How To Run It

## What I Would Do Next

## Where AI Helped
