---
title: Breakdown
---

Compare genres, platforms and game modes on volume, critic and user ratings, and Game of the Year recognition. Rankings only include groups with at least 20 games.

<ButtonGroup name=attr_type title="Break down by">
    <ButtonGroupItem valueLabel="Genre" value="Genre" default />
    <ButtonGroupItem valueLabel="Platform" value="Platform" />
    <ButtonGroupItem valueLabel="Game mode" value="Game mode" />
</ButtonGroup>

<Slider name=min_votes title="Minimum user ratings per game" min=10 max=500 step=10 defaultValue=10 />

```sql by_attribute
select
    attribute,
    count(*) as games,
    avg(critic_rating) as avg_critic_rating,
    avg(user_rating) as avg_user_rating,
    sum(is_nominated) as goty_nominees,
    avg(is_nominated) as nomination_rate
from pipeline.report_game_attributes
where attribute_type = '${inputs.attr_type}'
    and user_rating_count >= ${inputs.min_votes}
group by attribute
```

```sql most_shipped
select * from ${by_attribute}
order by games desc
limit 15
```

```sql top_nomination_rate
select * from ${by_attribute}
where games >= 20
order by nomination_rate desc
limit 15
```

```sql top_critic
select * from ${by_attribute}
where games >= 20 and avg_critic_rating is not null
order by avg_critic_rating desc
limit 15
```

```sql top_user
select * from ${by_attribute}
where games >= 20
order by avg_user_rating desc
limit 15
```

<Grid cols=2>
    <BarChart data={most_shipped} x=attribute y=games yFmt=num0 swapXY=true title="Most shipped" />
    <BarChart data={top_nomination_rate} x=attribute y=nomination_rate yFmt=pct1 swapXY=true title="GOTY nomination rate" subtitle="Share of games that were nominated" />
    <BarChart data={top_critic} x=attribute y=avg_critic_rating yFmt=num1 swapXY=true title="Highest rated by critics" subtitle="Average critic score" />
    <BarChart data={top_user} x=attribute y=avg_user_rating yFmt=num1 swapXY=true title="Highest rated by players" subtitle="Average user score" />
</Grid>

## Full breakdown

<DataTable data={by_attribute} search=true rows=25 sort="games desc">
    <Column id=attribute title={inputs.attr_type} />
    <Column id=games fmt=num0 />
    <Column id=avg_critic_rating title="Avg critic rating" fmt=num1 contentType=colorscale />
    <Column id=avg_user_rating title="Avg user rating" fmt=num1 contentType=colorscale />
    <Column id=goty_nominees title="GOTY nominees" fmt=num0 />
    <Column id=nomination_rate title="Nomination rate" fmt=pct1 contentType=bar />
</DataTable>
