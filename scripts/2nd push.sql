--1 1871 2016

select min(yearid), max(yearid)
from batting


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
LIMIT 1

namefirst || ' ' || namelast AS fullname,

--3

SELECT CONCAT(namefirst, ' ', namelast) AS player_name, schools.schoolname, SUM(salaries.salary) AS total_salary, salaries.yearid
FROM people
INNER JOIN collegeplaying
USING (playerid)
INNER JOIN schools
ON collegeplaying.schoolid = schools.schoolid
INNER JOIN salaries
USING (playerid)
WHERE schools.schoolname = 'Vanderbilt University'
GROUP BY player_name, schools.schoolname, salaries.yearid
ORDER BY player_name DESC;
--

WITH vandy AS (
		SELECT DISTINCT(playerid)
		FROM collegeplaying
		WHERE schoolid iLIKE '%vand%'
		GROUP BY  DISTINCT(playerid)
	)

SELECT playerid, CONCAT(namefirst,' ',namelast), SUM(salary) AS total_salary
FROM people
INNER JOIN vandy
USING(playerid)
INNER JOIN salaries
USING(playerid)
GROUP BY playerid, CONCAT(namefirst,' ',namelast)
ORDER BY SUM(salary) DESC

with vandy AS (
	select distinct(playerid)
from collegeplaying
where schoolid ilike '%vand%'
group by distinct(playerid)
	)
SELECT CONCAT(namefirst,' ',namelast), SUM(salary) AS total_salary
FROM people
inner join vandy
using (playerid)
inner join salaries
using (playerid)
GROUP BY  CONCAT(namefirst,' ',namelast)

--4
with fielding_2016 AS (
	SELECT *
from fielding
	where yearid = 2016
	)
select sum(po) as total_putouts,
	case when pos = 'OF' THEN 'Outfield'
	
when pos IN ('SS','1B','2B','3B') THEN 'Infield'
	when pos IN ('P','C') THEN 'Battey' END AS POSITION 
FROM FIELDING_2016
INNNER JOIN PEOPLE
USING (playerid)
group by position 



ROUND(SUM(so) * 1.0 / SUM(g), 2) AS so_per_game,
	ROUND(SUM(hr) * 1.0 / SUM(g), 2) AS hr_per_game
--5

WITH games_since1920	AS (
						SELECT
							COUNT(G) AS games_played,
							10*FLOOR(yearid/10) AS Decade,
							ROUND(AVG(hr),2) AS AVG_homeruns,
							ROUND(AVG(so),2) AS AVG_strikeouts
						FROM teams
						WHERE yearid >=1920
						GROUP BY Decade)
SELECT Decade, 
		ROUND(AVG_homeruns/games_played,2) AS homeruns_per_game,
		ROUND(AVG_strikeouts/games_played,2) AS strikeouts_per_game
FROM games_since1920
ORDER BY Decade ASC





