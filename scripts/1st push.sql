--1 1871

select *
from batting
order by yearid asc

--2


SELECT MIN(people.height) / 12 AS shortest_height_feet,
       CONCAT(namefirst, ' ', namelast) AS player_name,
       appearances.g_all AS number_of_games,
       teams.name AS team_name
FROM appearances
INNER JOIN people
USING (playerid)
INNER JOIN teams
USING (teamid)
GROUP BY player_name, appearances.g_all, teams.name
ORDER BY shortest_height_feet
LIMIT 1;
--3

