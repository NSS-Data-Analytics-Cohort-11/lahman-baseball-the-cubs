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

WITH WinsByTeam AS (
    SELECT
        teamid,
        MAX(w) AS max_wins
    FROM teams
    WHERE yearid BETWEEN 1970 AND 2016
          AND wswin = 'N'
    GROUP BY teamid
)
SELECT
    t.teamid,
    t.name AS team_name,
    wbt.max_wins,
	yearid
FROM WinsByTeam wbt
INNER JOIN teams t ON wbt.teamid = t.teamid
ORDER BY wbt.max_wins DESC
LIMIT 1;


WITH WinsByTeam AS (
    SELECT
        teamid,
        MIN AS min_wins
    FROM teams
    WHERE yearid BETWEEN 1970 AND 2016
          AND wswin = 'N'
    GROUP BY teamid
)
SELECT
    t.teamid,
    t.name AS team_name,
    wbt.max_wins,
	yearid
FROM WinsByTeam wbt
INNER JOIN teams t ON wbt.teamid = t.teamid
ORDER BY wbt.max_wins DESC
LIMIT 1;

WITH WinsByTeam AS (
    SELECT
        teamid,
        MIN(w) AS min_wins
    FROM teams
    WHERE yearid >= 1970
          AND wswin = 'Y'
    GROUP BY teamid
)
SELECT
    t.teamid,
    t.name AS team_name,
    wbt.min_wins,
	yearid,
	wswin
FROM WinsByTeam wbt
INNER JOIN teams t ON wbt.teamid = t.teamid
ORDER BY wbt.min_wins
LIMIT 1;


WITH WinsByTeam AS (
    SELECT
        teamid,
        MAX(w) AS max_wins
    FROM teams
    WHERE yearid >= '1970'
    GROUP BY teamid
),
WorldSeriesWinners AS (
    SELECT DISTINCT teamid
    FROM teams
    WHERE yearid >= '1970'
          AND wswin = 'Y'
)
SELECT
    COUNT(*) AS num_occurrences,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM WinsByTeam), 2) AS percentage
FROM WinsByTeam wbt
INNER JOIN WorldSeriesWinners wsw ON wbt.teamid = wsw.teamid
WHERE wbt.max_wins = (SELECT MAX(max_wins) FROM WinsByTeam);



WITH yearly_wins AS ( SELECT yearid, MAX (w) AS w
						FROM teams
						WHERE yearid >= 1970
						GROUP BY yearid
						ORDER BY yearid)
SELECT name, w, yearid, wswin
-- 	(SELECT COUNT(wswin)
-- 	FROM yearly_wins
-- 	WHERE wswin = 'Y')
FROM yearly_wins
INNER JOIN teams
USING (yearid, w)
--GROUP BY yearid, w, name, wswin
ORDER BY yearid, w DESC




WITH yearly_wins AS (
    SELECT yearid, MAX(w) AS max_wins
    FROM teams
    WHERE yearid >= 1970
    GROUP BY yearid
)
SELECT
    COUNT(*) AS total_years,
    SUM(CASE WHEN t1.wswin = 'Y' THEN 1 ELSE 0 END) AS wins_and_ws,
    (SUM(CASE WHEN t1.wswin = 'Y' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS win_percentage
FROM yearly_wins t1
INNER JOIN teams t2 ON t1.yearid = t2.yearid AND t1.max_wins = t2.w
WHERE t1.yearid BETWEEN 1970 AND 2016;
--
WITH yearly_wins AS (
    SELECT yearid, MAX(w) AS max_wins
    FROM teams
    WHERE yearid >= 1970
    GROUP BY yearid
)
SELECT
    COUNT(*) AS total_years,
    sum(CASE WHEN teams.wswin = 'Y' THEN 1 ELSE 0 END) AS wins_and_ws,
    (sum(CASE WHEN teams.wswin = 'Y' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS win_percentage
FROM yearly_wins
INNER JOIN teams ON yearly_wins.yearid = teams.yearid AND yearly_wins.max_wins = teams.w
WHERE teams.yearid BETWEEN 1970 AND 2016;

WITH yearly_wins AS (
    SELECT yearid, MAX(w) AS max_wins
    FROM teams
    WHERE yearid >= 1970
    GROUP BY yearid
)


SELECT
    COUNT(*) AS total_years,
    SUM(CASE WHEN teams.wswin = 'Y' THEN 1 ELSE 0 END) AS wins_and_ws,
    (SUM(CASE WHEN teams.wswin = 'Y' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS win_percentage
FROM yearly_wins
INNER JOIN teams ON yearly_wins.yearid = teams.yearid AND yearly_wins.max_wins = teams.w
WHERE teams.yearid BETWEEN 1970 AND 2016;
--8
WITH top_5 AS (
	SELECT team, park, attendance / games AS avg_atten
FROM homegames
WHERE year = 2016 AND games >= 10
ORDER BY avg_atten DESC
LIMIT 5
),
bot_5 AS (
	SELECT team, park, attendance / games AS avg_atten
FROM homegames
WHERE year = 2016 AND games >= 10
ORDER BY avg_atten ASC
LIMIT 5
)
SELECT *
FROM top_5
UNION ALL 
SELECT * 
FROM bot_5
--

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

select *
from people
where awardid = 'TSN Manager of the Year'

SELECT 
    CONCAT(p.namefirst, ' ', p.namelast) AS full_name, t.name
   
FROM awardsmanagers as a
Inner join people as p
using(playerid)
inner join managershalf as m
using (playerid)
inner join teams as t
using (teamid)
WHERE a.awardid = 'TSN Manager of the Year'
GROUP BY full_name,t.name
HAVING COUNT(DISTINCT a.lgid)  >1;


WITH NL_winners AS
(SELECT playerid, awardid, lgid, yearid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND lgid = 'NL'
GROUP BY playerid, awardid, lgid, yearid
ORDER BY playerid),
AL_winners AS
(SELECT playerid, awardid, lgid, yearid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL'
GROUP BY playerid, awardid, lgid, yearid
ORDER BY playerid)
SELECT NL_winners.playerid, NL_winners.awardid, NL_winners.lgid, AL_winners.lgid, NL_winners.yearid AS NL_win, AL_winners.yearid AS AL_win, CONCAT (namefirst, ' ', namelast) AS name
FROM NL_winners
INNER JOIN AL_winners
USING (playerid)
INNER JOIN people
USING (playerid)