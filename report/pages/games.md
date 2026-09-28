---
title: Game finder
---

Look up individual titles, for example to find reference games for a pitch. Use the table's search box to find a game by name.

```sql goty_statuses
select distinct goty_status from pipeline.report_games order by goty_status
```

```sql release_years
select distinct release_year from pipeline.report_games order by release_year desc
```

<Dropdown data={goty_statuses} name=goty value=goty_status title="Game of the Year status" multiple=true selectAllByDefault=true />
<Dropdown data={release_years} name=years value=release_year title="Release year" multiple=true selectAllByDefault=true />

```sql game_list
select name, release_year, goty_status, critic_rating, critic_rating_count, user_rating, user_rating_count
from pipeline.report_games
where goty_status in ${inputs.goty.value}
    and release_year in ${inputs.years.value}
order by user_rating_count desc
```

<DataTable data={game_list} search=true rows=50>
    <Column id=name title="Game" />
    <Column id=release_year title="Released" fmt="0" />
    <Column id=goty_status title="GOTY status" />
    <Column id=critic_rating title="Critic rating" fmt=num1 contentType=colorscale />
    <Column id=critic_rating_count title="Critic reviews" fmt=num0 />
    <Column id=user_rating title="User rating" fmt=num1 contentType=colorscale />
    <Column id=user_rating_count title="User ratings" fmt=num0 />
</DataTable>
