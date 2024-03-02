--QUESTION 1. What range of years for baseball games played does the provided database cover? 
SELECT *
FROM teams
LIMIT 10;
--oldest year: 1871

SELECT *
FROM teams
ORDER by yearid DESC
LIMIT 10;
--most recent year: 2016

--question 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
--name, height - from people table
--# games - from appearances (g_all), teams
--team name - from 
--
-- SELECT *
-- FROM people;

SELECT CONCAT(namefirst,' ', namelast) AS name, height, g_all AS games_played, name AS team_name
FROM people
INNER JOIN appearances
USING (playerid)
INNER JOIN teams
ON appearances.teamid = teams.teamid
WHERE teams.teamid = 'SLA'
ORDER BY height
LIMIT 1;
--answer: "Eddie Gaedel"	43	1	"St. Louis Browns"

--question 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

--correct answer:
SELECT *
FROM schools
WHERE schoolname LIKE '%Vander%';

WITH vandy_players AS (
	SELECT DISTINCT playerid
	FROM collegeplaying
	WHERE schoolid = 'vandy'
)
SELECT 
	namefirst ||  namelast AS fullname, 
	SUM(salary)::int::MONEY AS total_salary
FROM salaries
INNER JOIN vandy_players
USING(playerid)
INNER JOIN people
USING(playerid)
GROUP BY namefirst || namelast
ORDER BY total_salary DESC;
--answer: David Price

--wrong answer: 
SELECT CONCAT(namefirst,' ', namelast) AS name, SUM(salary)::numeric::money
FROM schools
INNER JOIN collegeplaying
USING (schoolid)
INNER JOIN people
USING (playerid)
INNER JOIN salaries
USING (playerid) 
WHERE schoolname LIKE 'Vanderbilt%'
GROUP BY CONCAT(namefirst,' ', namelast)
ORDER BY SUM(salary)::numeric::money DESC;
--answer: David Price

--question 4: Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

-- SELECT *
-- FROM fielding
-- LIMIT 10;

SELECT SUM(po) AS total_putouts, 
	CASE WHEN pos = 'OF' THEN 'Outfield'
		 WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
		 WHEN pos IN ('P', 'C') THEN 'Battery' END AS position
FROM fielding
WHERE yearid = 2016
GROUP BY position;
--answer: see query

--question 5: Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?


WITH games_since1920 AS (
						SELECT SUM(G) AS games_played,
							10*FLOOR(yearid/10) AS Decade,
							ROUND(SUM(hr),2) AS AVG_homeruns,
							ROUND(SUM(so),2) AS AVG_strikeouts
						FROM teams
						WHERE yearid >=1920
						GROUP BY Decade
						)
SELECT Decade, 
		ROUND(AVG_homeruns/games_played,2) AS homeruns_per_game,
		ROUND(AVG_strikeouts/games_played,2) AS strikeouts_per_game
FROM games_since1920
ORDER BY Decade ASC;

--answer: run query; avg. strikeouts per game and homeruns per game increase as time goes on

--question 6: Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

-- SELECT *
-- FROM batting
WITH stealing AS (
				SELECT playerid, sb, cs, sb+cs AS total_attempts 
				FROM batting
				WHERE yearid = 2016 
				AND (sb + cs)>= 20
				)
SELECT  CONCAT(namefirst,' ', namelast), sb, cs, total_attempts, ROUND((100.0*sb/total_attempts), 2) AS successful_steals
FROM stealing
INNER JOIN people
USING (playerid)
ORDER BY (1.0*sb/total_attempts) DESC
LIMIT 1;
--answer: Chris Owings, 91%

--question 7:
-- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT name, w AS wins, wswin AS world_series_win
FROM teams
WHERE yearid >= 1970
AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;
--From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 116 wins, Seattle Mariners

SELECT name, yearid, w AS wins, wswin AS world_series_win
FROM teams
WHERE yearid >= 1970 
AND wswin = 'Y'
ORDER BY w;
--What is the smallest number of wins for a team that did win the world series? 63, LA Dodgers
--reason: there was a player strike that year (1981)

SELECT name, yearid, w AS wins, wswin AS world_series_win
FROM teams
WHERE yearid >= 1970 AND yearid NOT IN (1981)
AND wswin = 'Y'
ORDER BY w;
--What is the smallest number of wins for a team that did win the world series? not including 1981: 83 wins, Cardinals in 2006

--first approach: 
-- WITH yearly_wins AS ( SELECT name, w, wswin AS world_series_win, yearid
-- 					FROM teams
-- 					WHERE yearid >= 1970
-- 					GROUP BY yearid, name, wswin, w
-- 					ORDER BY yearid, w DESC )
-- SELECT name, MAX(w), yearid, world_series_win 
-- -- 	(CASE WHEN world_series_win = 'Y' AND THEN 1
-- -- 		  ELSE 0 END) AS ws_win_count
-- FROM yearly_wins
-- --WHERE world_series_win = 'Y'
-- GROUP BY yearid, name, world_series_win
-- ORDER BY yearid, MAX(w) DESC




WITH yearly_wins AS ( SELECT yearid, MAX (w) AS w
						FROM teams
						WHERE yearid >= 1970
						GROUP BY yearid
						ORDER BY yearid)
SELECT name, w, yearid, wswin, 
	(CASE WHEN wswin = 'Y' THEN 1
	 ELSE 0 END) AS count_wswin
	 
-- 	(SELECT COUNT(wswin)
-- 	FROM teams
-- 	WHERE wswin = 'Y')
FROM yearly_wins
INNER JOIN teams
USING (yearid, w)
--GROUP BY yearid, w, name, wswin
ORDER BY yearid, w DESC


--max wins by year
SELECT name, w AS wins, yearid, wswin
FROM teams
WHERE yearid = 1970
--AND wswin = 'N'
GROUP BY yearid, name, w, wswin
ORDER BY wins DESC
LIMIT 1;

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
-- SELECT *
-- FROM homegames
-- WHERE year = 2016
--note: ATL played in 2 different parks

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

--question 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
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

SELECT NL_winners.playerid, NL_winners.awardid, NL_winners.lgid, AL_winners.lgid, CONCAT (namefirst, ' ', namelast) AS manager_name, teams.name, yearid
FROM NL_winners
INNER JOIN AL_winners
USING (playerid)
INNER JOIN people
USING (playerid)
INNER JOIN appearances
USING (playerid)
INNER JOIN teams
USING (teamid)
GROUP BY playerid, NL_winners.awardid, NL_winners.lgid, AL_winners.lgid, CONCAT (namefirst, ' ', namelast), teams.name, yearid

--fixing earlier errors
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

--finding team names associated w/those managers
SELECT people.playerid, teams.teamid, teams.name, teams.yearid
FROM people
INNER JOIN appearances
USING (playerid)
INNER JOIN teams
USING (teamid)
WHERE playerid IN ('johnsda02', 'leylaji99')
GROUP BY playerid, teams.teamid, teams.name, teams.yearid
ORDER BY yearid


SELECT *
from people