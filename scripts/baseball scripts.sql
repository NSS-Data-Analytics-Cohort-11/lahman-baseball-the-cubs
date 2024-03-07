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
						ORDER BY yearid),
most_win_teams AS (SELECT name, yearid, wswin 
					FROM teams
				   	INNER JOIN yearly_wins
				   USING (yearid, w)
				   
SELECT
	(SELECT COUNT *
	
	--(CASE WHEN wswin = 'Y' THEN 1
	-- ELSE 0 END) AS count_wswin
	 
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
INNER JOIN parks
USING (park)
INNER JOIN teams
ON team= teamid AND year = yearid
WHERE year = 2016 
AND games >= 10
ORDER BY homegames.attendance/games DESC
LIMIT 5), 

bottom_5_attendance AS
(SELECT teams.name, homegames.team, park_name, homegames.attendance, games, homegames.attendance/games AS attendance_per_game, 'BOTTOM 5'AS ranking
FROM homegames
INNER JOIN parks
USING (park)
INNER JOIN teams
ON team= teamid AND year = yearid
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

	 --answer: 

	 
	 
--trying to pull in team name
-- WITH NL_winners AS
-- (SELECT playerid, awardid, lgid, yearid
-- FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year' AND lgid = 'NL'
-- GROUP BY playerid, awardid, lgid, yearid
-- ORDER BY playerid), 

-- AL_winners AS
-- (SELECT playerid, awardid, lgid, yearid
-- FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL'
-- GROUP BY playerid, awardid, lgid, yearid
-- ORDER BY playerid)

-- SELECT NL_winners.playerid, NL_winners.awardid, NL_winners.lgid, AL_winners.lgid, CONCAT (namefirst, ' ', namelast) AS manager_name, teams.name, NL_winners.yearid, AL_winners.yearid
-- FROM NL_winners
-- INNER JOIN AL_winners
-- USING (playerid)
-- INNER JOIN people
-- USING (playerid)
-- INNER JOIN appearances
-- USING (playerid)
-- INNER JOIN teams
-- USING (teamid)
-- GROUP BY playerid, NL_winners.awardid, NL_winners.lgid, AL_winners.lgid, CONCAT (namefirst, ' ', namelast), teams.name, NL_winners.yearid, AL_winners.yearid

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

	 --Dibran's answer: 
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
	 
	 
	 
	 
	 
	 
--finding team names associated w/those managers; need to join on multiple columns
SELECT people.playerid, teams.teamid, teams.name, teams.yearid
FROM people
INNER JOIN appearances
USING (playerid)
INNER JOIN teams
USING (teamid)
WHERE playerid IN ('johnsda02', 'leylaji99')
GROUP BY playerid, teams.teamid, teams.name, teams.yearid
ORDER BY yearid

	 

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


	 
--for individual presentation:
SELECT *
FROM teams
WHERE name LIKE 'Kansas City %'
	 
SELECT *
FROM schools
	 WHERE schoolname LIKE '%Kansas%' OR schoolname LIKE 'Truman%'
	 
SELECT *
FROM collegeplaying
	 WHERE schoolid IN ('kansas', 'kansasst', 'kskccco', 'trumanst', 'umkc')
--79 rows
	 
--basic info about Truman players from people table: 	 
WITH truman_players AS (
	 SELECT DISTINCT playerid
FROM collegeplaying
WHERE schoolid ='trumanst') --4 Truman players

SELECT CONCAT(namefirst, ' ', namelast) AS player_name, CAST(CONCAT(birthmonth, '/', birthday, '/', birthyear) AS date) AS birthdate, CONCAT(birthcity, ', ', birthstate) AS birthplace, weight, height, bats, throws, CAST(debut AS date), AGE(CAST(debut AS date), CAST(CONCAT(birthmonth, '/', birthday, '/', birthyear) AS date)) AS age_at_debut, CAST(finalgame AS date), AGE(CAST(finalgame AS date), CAST(debut AS date)) AS career_length--, salaries.*
FROM people
INNER JOIN truman_players
USING (playerid)
-- FULL JOIN salaries
-- USING (playerid)
	 --further investigation: what teams did they play for? salaries? stats (batting, fielding, etc)? awards? all star?

--salaries for Bruce (1985) & Al (1985, 86, 88); nothing for Guy or Dave	 
SELECT CONCAT(namefirst, ' ', namelast) AS player_name, yearid, teamid, salary::numeric::money
FROM salaries
INNER JOIN people
USING (playerid)
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')
ORDER BY playerid

--establishes that salary data starts with 1985:
-- SELECT DISTINCT yearid
-- FROM salaries
-- ORDER BY yearid	

-- appearances info
SELECT CONCAT(namefirst, ' ', namelast) AS player_name, appearances.yearid, name, g_all AS total_games, g_batting, g_defense, g_p AS pitcher, g_of AS outfielder, g_ph AS pinch_hitter, g_pr AS pinch_runner
FROM appearances
INNER JOIN teams
USING (teamid, yearid)
INNER JOIN people
USING (playerid)	 
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')
ORDER BY CONCAT(namefirst, ' ', namelast), yearid

	 -- teams list
SELECT CONCAT(namefirst, ' ', namelast) AS player_name, appearances.yearid, name 
FROM appearances
INNER JOIN teams
USING (teamid, yearid)
INNER JOIN people
USING (playerid)	 
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')
ORDER BY CONCAT(namefirst, ' ', namelast), yearid
	 
-- SELECT *
-- FROM appearances	 
-- WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')
	 
	 
--batting stats
SELECT  CONCAT(namefirst, ' ', namelast) AS player_name, yearid, teamid, g AS games, ab AS at_bats, r AS runs, h AS hits, h2b AS doubles, h3b AS triples, rbi, sb AS stolen_bases, cs AS caught_stealing, bb AS base_on_balls, so AS strikeouts, ibb AS intentional_walks, hbp AS hit_by_pitch, sh AS sacrifice_hits, sf AS sacrifice_flies, gidp AS grounded_into_double_plays
FROM batting
INNER JOIN people
USING (playerid)	 
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')
ORDER BY playerid, yearid
 
--pitching stats (Guy did not pitch)
SELECT CONCAT(namefirst, ' ', namelast) AS player_name, yearid, teamid, gs AS games_started, sho AS shutouts, h AS hits, hr AS homeruns, bb AS walks, so AS strikeouts, wp AS wild_pitches, hbp AS batters_hit_by_pitch
FROM pitching
INNER JOIN people
USING (playerid)	 
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')
ORDER BY playerid, yearid

SELECT *
FROM pitching
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')	 
	 
--sum of pitching stats
SELECT CONCAT(namefirst, ' ', namelast) AS player_name, SUM (g) AS total_games, SUM (gs) AS total_games_started, SUM (sho) AS total_shutouts, SUM (so) AS total_strikeouts, SUM (wp) AS total_wild_pitches, SUM (hbp) AS total_batters_hit_by_pitch
FROM pitching
INNER JOIN people
USING (playerid)	 
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')
GROUP BY CONCAT(namefirst, ' ', namelast)	 
	 
--position played (fielding)
SELECT CONCAT(namefirst, ' ', namelast) AS player_name, pos AS position
FROM fielding
INNER JOIN people
USING (playerid)
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')
GROUP BY CONCAT(namefirst, ' ', namelast), pos 

	 --Al played in WS in 1986
SELECT *
FROM pitchingpost
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')
	 
	 
--teams table info for Truman players; Bruce's team won WS in 1986
WITH truman_players AS (SELECT playerid, yearid, teamid
FROM fielding
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01') )
	 
SELECT playerid, yearid, name AS team_name, rank, w AS wins, l AS losses, lgwin AS league_championship, wswin AS world_series_win
FROM teams
INNER JOIN truman_players
USING (yearid, teamid)
ORDER BY playerid, yearid

	 --Bruce & Al: Rookie of the Year
SELECT *
FROM awardsshareplayers
WHERE playerid IN ('berenbr01', 'curtrgu01', 'nippeal01','wehrmda01')
	 