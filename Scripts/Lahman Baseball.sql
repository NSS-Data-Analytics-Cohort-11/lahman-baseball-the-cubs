SELECT * FROM allstarfull
SELECT * FROM appearances --q2
	SELECT DISTINCT playerid
	FROM appearances
SELECT * FROM awardsmanagers
SELECT * FROM awardsplayers
SELECT * FROM awardssharemanagers
SELECT * FROM awardsshareplayers
SELECT * FROM batting
SELECT * FROM battingpost
SELECT * FROM collegeplaying --q3~
	SELECT playerid, schoolid, yearid
	FROM collegeplaying
	WHERE schoolid iLIKE '%vand%'	
SELECT * FROM fielding --q4 SUM(po)
SELECT * FROM fieldingof 
SELECT * FROM fieldingofsplit
SELECT * FROM fieldingpost 
SELECT * FROM halloffame
SELECT * FROM homegames
SELECT * FROM managers
SELECT * FROM managershalf
SELECT * FROM parks
SELECT * FROM people --q2
SELECT * FROM pitching
SELECT * FROM pitchingpost
SELECT * FROM salaries --q3~ playerid for q3
SELECT * FROM schools
SELECT * FROM seriespost 
SELECT * FROM teams --q1
SELECT * FROM teamsfranchises --Minor League Baseball 120 teams
SELECT * FROM teamshalf
----------------------------------------------------------------------------------

--Q1. What range of years for baseball games played does the provided database cover?
SELECT MIN(yearid) AS earliest_year, MAX(yearid) AS  latest_year
FROM teams
--Answer: 1871 - 2016

--Q2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT playerid, CONCAT(namefirst,' ',namelast), namegiven, height, teamid
FROM people
INNER JOIN appearances
USING(playerid)
WHERE playerid LIKE 'gaedeed01' 
ORDER BY height ASC
--Answer: Eddie Gaedel at 3feet 7inches only played one game for SLA or ST. Louis Browns

--Q3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
WITH vandy AS (
		SELECT DISTINCT(playerid)
		FROM collegeplaying
		WHERE schoolid iLIKE '%vand%'
		GROUP BY  DISTINCT(playerid)
	)

SELECT playerid, CONCAT(namefirst,' ',namelast) AS name , SUM(salary)::NUMERIC::MONEY AS total_salary
FROM people
INNER JOIN vandy
USING(playerid)
INNER JOIN salaries
USING(playerid)
GROUP BY playerid, CONCAT(namefirst,' ',namelast)
ORDER BY SUM(salary) DESC
--Answer: David Price earned a total of $81,851,296

--Q4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
WITH fielding_2016 AS (
	SELECT * 
FROM fielding
WHERE yearid = 2016
	)
	
SELECT SUM(po) AS total_putouts,
		CASE WHEN pos = 'OF' THEN 'Outfield'
			WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			WHEN pos IN ('P', 'C') THEN 'Battery' END AS position
FROM fielding_2016
INNER JOIN people
USING(playerid)
GROUP BY position

--Answer:^^

--Q5.Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	