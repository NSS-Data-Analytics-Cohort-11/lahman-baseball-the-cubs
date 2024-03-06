--1 1871 2016  What range of years for baseball games played does the provided database cover? 


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

	
--3


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

--4 Using the fielding table, group players into three groups based on their position: 
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

--6



WITH players2016_sb AS (
    SELECT
        playerid,
        sb,
        cs,
        (sb + cs) AS sb_attempts
    FROM batting
    WHERE yearid = 2016 AND (sb + cs) > 20
)
SELECT
    namefirst || ' ' || namelast AS fullname,
    ROUND((sb * 100) / (sb + cs), 2) AS sb_percent,
    sb,cs
FROM players2016_sb
INNER JOIN people USING (playerid)
GROUP BY sb_percent, fullname, sb,cs
ORDER BY sb_percent DESC;






--7

(SELECT
	'Most wins that lost world series',
 	yearid AS year,
	name AS team,
	w As num_wins
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'N'
ORDER BY w DESC
LIMIT 1)
UNION
(SELECT
 	'Least wins that won world series',
	yearid AS year,
	name AS team,
	w As num_wins
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
 	AND yearid <> 1981
ORDER BY w
LIMIT 1);











WITH yearly_wins AS (
    SELECT yearid, MAX(w) AS max_wins
    FROM teams
    WHERE yearid >= 1970
    GROUP BY yearid
)
SELECT
    COUNT(distinct teams.yearid) AS total_years,
    sum(CASE WHEN teams.wswin = 'Y' THEN 1 ELSE 0 END) AS wins_and_ws,
    (sum(CASE WHEN teams.wswin = 'Y' THEN 1 ELSE 0 END) * 100.0) / count(distinct teams.yearid) AS win_percentage
FROM yearly_wins
INNER JOIN teams ON yearly_wins.yearid = teams.yearid AND yearly_wins.max_wins = teams.w
WHERE teams.yearid BETWEEN 1970 AND 2016;


--8



WITH top_5_attendance AS
(SELECT teams.name, homegames.team, park_name, homegames.attendance, games, homegames.attendance/games AS attendance_per_game, 'TOP 5' AS ranking
FROM homegames
FULL JOIN parks
USING (park)
FULL JOIN teams
ON parks.park = teams.park
WHERE year = 2016 
AND games >= 10
ORDER BY homegames.attendance/games DESC
LIMIT 5), 

bottom_5_attendance AS
(SELECT teams.name, homegames.team, park_name, homegames.attendance, games, homegames.attendance/games AS attendance_per_game, 'BOTTOM 5'AS ranking
FROM homegames
FULL JOIN parks
USING (park)
FULL JOIN teams
ON parks.park = teams.park
WHERE year = 2016 
AND games >= 10
ORDER BY homegames.attendance/games
LIMIT 5)

SELECT *
FROM top_5_attendance
UNION ALL
SELECT *
FROM bottom_5_attendance

--9



WITH both_league_winners AS (
	SELECT
		playerid--, count(DISTINCT lgid)
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid IN ('AL', 'NL')
	GROUP BY playerid
	--order by COUNT(DISTINCT lgid) desc
	HAVING COUNT(DISTINCT lgid) = 2
	)
SELECT
	namefirst || ' ' || namelast AS full_name,
	yearid,
	lgid,
	name
FROM people
INNER JOIN both_league_winners
USING(playerid)
INNER JOIN awardsmanagers
USING(playerid)
INNER JOIN managers
USING(playerid, yearid, lgid)
INNER JOIN teams
USING(teamid, yearid,lgid)
WHERE awardid = 'TSN Manager of the Year'
ORDER BY full_name, yearid;	 

--10

SELECT
    p.namefirst || ' ' || p.namelast AS player_name,
    b.hr AS home_runs_2016
FROM batting AS b
INNER JOIN people AS p ON b.playerID = p.playerid
WHERE b.yearid = 2016
	AND hr > 0
	AND EXTRACT(YEAR FROM debut::date) <= 2016 - 9
    AND b.hr = (
        SELECT MAX(hr)
        FROM batting
        WHERE playerid = b.playerid)
ORDER BY home_runs_2016 DESC;
	 