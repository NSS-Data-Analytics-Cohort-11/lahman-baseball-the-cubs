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

--schools table: schoolid, schoolname
--people: namefirst, namelast
--salaries: salary

--SELECT *
-- FROM collegeplaying
-- LIMIT 10

-- SELECT *
-- FROM schools
-- LIMIT 10

-- SELECT *
-- FROM people
-- LIMIT 10

-- SELECT *
-- FROM salaries
-- LIMIT 10

SELECT CONCAT(namefirst,' ', namelast) AS name, SUM(salary)::numeric::money
FROM schools
INNER JOIN collegeplaying
USING (schoolid)
INNER JOIN people
USING (playerid)
INNER JOIN salaries
USING (playerid) 
WHERE schoolname LIKE 'Vanderbilt%'
GROUP BY schoolname, CONCAT(namefirst,' ', namelast)
ORDER BY SUM(salary)::numeric::money DESC;
--answer: David Price

--question 4: Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT *
FROM fielding
LIMIT 10;

SELECT SUM(po) AS total_putouts, 
	CASE WHEN pos = 'OF' THEN 'Outfield'
		 WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
		 WHEN pos IN ('P', 'C') THEN 'Battery' END AS position
FROM fielding
GROUP BY position, pos
