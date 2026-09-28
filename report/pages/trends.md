---
title: Trends
---

Releases and ratings by year. Pick the genres to compare.

```sql genre_list
select distinct attribute as genre
from pipeline.report_game_attributes
where attribute_type = 'Genre'
order by genre
```

<Dropdown data={genre_list} name=genre value=genre title="Genres" multiple=true selectAllByDefault=true />

```sql genre_trend
select
    make_date(release_year::int, 1, 1) as year,
    attribute as genre,
    count(*) as games,
    avg(user_rating) as avg_user_rating
from pipeline.report_game_attributes
where attribute_type = 'Genre'
    and attribute in ${inputs.genre.value}
group by all
order by year
```

<LineChart data={genre_trend} x=year y=games series=genre xFmt=yyyy title="Games released per year" />

<LineChart data={genre_trend} x=year y=avg_user_rating series=genre xFmt=yyyy yFmt=num1 title="Average user rating per year" />

## Critics vs players

```sql ratings_by_year
select
    make_date(release_year::int, 1, 1) as year,
    avg(critic_rating) as avg_critic_rating,
    avg(user_rating) as avg_user_rating
from pipeline.report_games
group by all
order by year
```

<LineChart
    data={ratings_by_year}
    x=year
    y={['avg_critic_rating', 'avg_user_rating']}
    xFmt=yyyy
    yFmt=num1
    title="Average critic and user rating by release year (all games)"
/>
