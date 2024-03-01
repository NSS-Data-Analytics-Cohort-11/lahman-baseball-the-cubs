--Q1.)What range of years for baseball games played does the provided database cover?
SELECT MIN(yearid), MAX(yearid)
FROM public.teams;
-- 1871-2016

--Q2.)Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT concat(namefirst,' ', namelast) AS player_name, MIN(height) AS height, name AS team, g_all AS number_of_games
FROM people
LEFT JOIN appearances
USING(playerid)
LEFT JOIN teams
USING(teamid)
WHERE height IS NOT NULL
GROUP BY player_name, team, number_of_games
ORDER BY height ASC
LIMIT 1;


--Q3.)Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT concat(namefirst,' ',namelast) AS player_name, schoolname, SUM(salary)::NUMERIC::MONEY AS total_salary
FROM collegeplaying
INNER JOIN schools
USING(schoolid)
INNER JOIN people
USING(playerid)
INNER JOIN salaries
USING(playerid)
WHERE schoolname ILIKE '%Vanderbilt%'
GROUP BY player_name, schoolname
ORDER BY total_salary DESC;

--teammates answer using CTE
WITH vandy AS (
			SELECT DISTINCT(playerid)
			FROM collegeplaying
			WHERE schoolid ILIKE 'vand%'
			)
SELECT concat(namefirst,' ',namelast) AS player_name, SUM(salary)::NUMERIC::MONEY AS total_salary
FROM people
INNER JOIN vandy
USING(playerid)
INNER JOIN salaries
USING(playerid)
GROUP BY player_name
ORDER BY total_salary DESC;



--Q4.) Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
WITH fielding_2016 AS (
						SELECT *
						FROM fielding
						WHERE yearid = 2016
						)

SELECT SUM(po) AS total_putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
		WHEN pos IN ('P','C') THEN 'Battery' END AS position
FROM fielding_2016
INNER JOIN people
USING(playerid)
GROUP BY position;


--answer key
SELECT
	CASE
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
	END AS position_group,
	SUM(po) AS total_po
FROM fielding
WHERE yearid = 2016
GROUP BY position_group;


					 
--Q5.)Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
WITH games_since1920	AS (
						SELECT
							SUM(G) AS games_played,
							10*FLOOR(yearid/10) AS Decade,
							ROUND(SUM(hr),2) AS AVG_homeruns,
							ROUND(SUM(so),2) AS AVG_strikeouts
						FROM teams
						WHERE yearid >=1920
						GROUP BY Decade)
SELECT Decade, 
		ROUND(AVG_homeruns/games_played,2) AS homeruns_per_game,
		ROUND(AVG_strikeouts/games_played,2) AS strikeouts_per_game
FROM games_since1920
ORDER BY Decade ASC;



--Q6.)Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
WITH players_base_stats_2016 AS (
							SELECT playerid, yearid, SUM(sb) AS stolen_bases, SUM(cs) AS caught_stealing
							FROM batting
							WHERE yearid = 2016 
								AND sb+cs >= 20
							GROUP BY playerid, yearid
							)
SELECT concat(namefirst,' ',namelast) AS player_name, ROUND((stolen_bases*1.0)/(stolen_bases+caught_stealing),2) AS perc_stolen_bases
FROM players_base_stats_2016
INNER JOIN people
USING(playerid)
ORDER BY ROUND((stolen_bases*1.0)/(stolen_bases+caught_stealing),2) DESC;


	

--Q7.) From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT name, yearid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016




