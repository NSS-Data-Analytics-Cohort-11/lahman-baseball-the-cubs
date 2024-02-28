--Q1.)What range of years for baseball games played does the provided database cover?
SELECT MIN(yearid)
FROM public.teams;


--Q2.)Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT concat(namefirst,' ', namelast) AS player_name, MIN(height) AS height, name, g_all
FROM people
LEFT JOIN appearances
USING(playerid)
LEFT JOIN teams
USING(teamid)
WHERE height IS NOT NULL
GROUP BY player_name, name, g_all
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

--CTE
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
SELECT *
FROM fielding

SELECT playerid,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
		WHEN pos IN ('P','C') THEN 'Battery'
FROM fielding
WHERE pos = 

					 
					 SELECT playerid,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS',pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
		WHEN pos = 'P' AND