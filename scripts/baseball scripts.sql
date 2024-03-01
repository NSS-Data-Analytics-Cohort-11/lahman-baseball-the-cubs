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

SELECT *
FROM batting

SELECT playerid, sb, cs, sb/(sb+cs)
FROM batting
WHERE yearid = 2016 
	AND (sb + cs)>= 20
