---
title: Genre Opportunity
---

Games released since 2014 with at least 10 user ratings on IGDB, matched against The Game Awards' Game of the Year nominees. Genres that ship few games but earn many nominations are the most promising for a pitch.

```sql kpis
select
    count(*) as games,
    count(*) filter (where goty_status <> 'Not nominated') as nominees,
    avg(critic_rating) as avg_critic_rating,
    avg(user_rating) as avg_user_rating
from pipeline.report_games
```

<BigValue data={kpis} value=games title="Games in scope" fmt=num0 />
<BigValue data={kpis} value=nominees title="GOTY nominees matched" fmt=num0 />
<BigValue data={kpis} value=avg_critic_rating title="Avg critic rating" fmt=num1 />
<BigValue data={kpis} value=avg_user_rating title="Avg user rating" fmt=num1 />

## Nominations per 1,000 games shipped

```sql opportunity
select * from pipeline.genre_opportunity
order by awarded_per_1000 desc
```

<BarChart
    data={opportunity}
    x=genre_name
    y=awarded_per_1000
    yFmt=num1
    swapXY=true
    chartAreaHeight=500
    title="GOTY nominations per 1,000 games, by genre"
    subtitle="Higher means a genre is recognised more often than its share of releases would suggest"
/>

## Supply vs recognition

<ScatterPlot
    data={opportunity}
    x=games_shipped
    y=awarded
    series=genre_name
    tooltipTitle=genre_name
    legend=false
    xAxisTitle="Games shipped"
    yAxisTitle="GOTY nominations"
    title="Games shipped vs GOTY nominations"
    subtitle="Top-left genres are under-supplied but over-awarded"
/>

<DataTable data={opportunity} rows=25>
    <Column id=genre_name title="Genre" />
    <Column id=games_shipped title="Games shipped" fmt=num0 />
    <Column id=awarded title="GOTY nominations" fmt=num0 />
    <Column id=awarded_per_1000 title="Nominations per 1,000" fmt=num1 contentType=bar />
</DataTable>

Explore genres, platforms and game modes in detail on the [Breakdown](/breakdown) page, see how they change over time on [Trends](/trends), or look up individual titles in the [Game finder](/games).
