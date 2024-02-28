SELECT *
FROM allstarfull;

SELECT *
FROM teams;

-- 1. What range of years for baseball games played does the provided database cover? 

SELECT MIN(yearid)
FROM allstarfull;

SELECT MIN(yearid)
FROM appearances;

SELECT MAX(yearid)-MIN(yearid) AS range
FROM teams;

-- ANSWER: the range is 145 years beginning in 1871 and ending in 2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT CONCAT(people.namefirst,' ', people.namelast) AS name, MIN(height), a.g_all AS games, teams.name
FROM appearances as a
LEFT JOIN people
USING (playerid)
LEFT JOIN teams
USING (teamid)
WHERE height IS NOT NULL
GROUP BY CONCAT(namefirst,' ', namelast), a.g_all, teams.name
ORDER BY min(height)

-- ANSWER: Eddie Gaedel at 43" in height played one game for the St. Louis Browns


SELECT *
FROM people
ORDER BY height

SELECT *
FROM appearances

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT *
FROM salaries

WITH vandy_alum AS
	(SELECT DISTINCT(playerid)
	FROM collegeplaying AS c
	INNER JOIN schools AS s
	USING(schoolid)
	WHERE s.schoolname ILIKE '%vanderbilt%')

SELECT CONCAT(people.namefirst,' ', people.namelast) AS name,SUM(salaries.salary):: NUMERIC ::MONEY
FROM people
INNER JOIN vandy_alum
USING (playerid)
INNER JOIN salaries
USING (playerid)
GROUP BY  CONCAT(people.namefirst,' ', people.namelast)
ORDER BY SUM(salaries.salary) :: NUMERIC :: MONEY DESC;														  
	
-- ANSWER: The highest paid player who attended Vanderbilt was David Price with a salary of $81,851,296.00

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

WITH positions AS 
	(
		SELECT f.playerid, CONCAT(people.namefirst,' ', people.namelast) AS name, po,
		CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' THEN 'Infield'
		WHEN pos = '1B' THEN 'Infield'
		WHEN pos = '2B' THEN 'Infield'
		WHEN pos = '3B' THEN 'Infield'
		WHEN pos = 'P' THEN 'Battery'
		WHEN pos = 'C' THEN 'Battery'
		ELSE 'unknown' END position
	FROM fielding AS f
	LEFT JOIN people
	USING (playerid)
	WHERE f.yearid = '2016'  )

SELECT
	(SELECT SUM(po)
	FROM positions
	WHERE position ilike 'battery') AS battery_po,
	(SELECT SUM(po)
	FROM positions
	WHERE position ilike 'infield') AS infield_po,
	(SELECT SUM(po)
	FROM positions
	WHERE position ilike 'outfield') AS outfield_po
FROM positions;	

-- ANSWER: battery_po = 41424, infield_po = 58934, outfield_po = 29560
-- total for all po is 129918

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
