SELECT * FROM allstarfull
SELECT * FROM appearances --q2
	SELECT DISTINCT playerid
	FROM appearances
SELECT * FROM awardsmanagers
SELECT * FROM awardsplayers
SELECT * FROM awardssharemanagers
SELECT * FROM awardsshareplayers
SELECT * FROM batting
	SELECT SUM(so) strikeout, SUM(hr) homerun 
	FROM batting
	
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

	WITH games_1920s AS 
				(
			SELECT ROUND(SUM(so) * 1.0 / SUM(g),2) AS avg_strikeouts
				  ,ROUND(SUM(hr) * 1.0 / SUM(g),2) AS avg_home_run
		FROM teams
		WHERE yearid BETWEEN 1920 AND 1929
				),
	 games_1930s AS 
				(
			SELECT ROUND(SUM(so) * 1.0 / SUM(g),2) AS avg_strikeouts
				  ,ROUND(SUM(hr) * 1.0 / SUM(g),2) AS avg_home_run
		FROM teams
		WHERE yearid BETWEEN 1930 AND 1939			
				),
	 games_1940s AS 
				(
			SELECT ROUND(SUM(so) * 1.0 / SUM(g),2) AS avg_strikeouts
				  ,ROUND(SUM(hr) * 1.0 / SUM(g),2) AS avg_home_run
		FROM teams
		WHERE yearid BETWEEN 1940 AND 1949		
				),
	 games_1950s AS 
				(
			SELECT ROUND(SUM(so) * 1.0 / SUM(g),2) AS avg_strikeouts
				  ,ROUND(SUM(hr) * 1.0 / SUM(g),2) AS avg_home_run
		FROM teams
		WHERE yearid BETWEEN 1950 AND 1959		
				),
	 games_1960s AS 
				(
			SELECT ROUND(SUM(so) * 1.0 / SUM(g),2) AS avg_strikeouts
				  ,ROUND(SUM(hr) * 1.0 / SUM(g),2) AS avg_home_run
		FROM teams
		WHERE yearid BETWEEN 1960 AND 1969
	            ),
	 games_1970s AS 
				(
			SELECT ROUND(SUM(so) * 1.0 / SUM(g),2) AS avg_strikeouts
			      ,ROUND(SUM(hr) * 1.0 / SUM(g),2) AS avg_home_run
		FROM teams
		WHERE yearid BETWEEN 1970 AND 1979	
				),			
	 games_1980s AS 
				(
			SELECT ROUND(SUM(so) * 1.0 / SUM(g),2) AS avg_strikeouts
				  ,ROUND(SUM(hr) * 1.0 / SUM(g),2) AS avg_home_run
		FROM teams
		WHERE yearid BETWEEN 1980 AND 1989
				),			
	 games_1990s AS 
				(
			SELECT ROUND(SUM(so) * 1.0 / SUM(g),2) AS avg_strikeouts
				  ,ROUND(SUM(hr) * 1.0 / SUM(g),2) AS avg_home_run
		FROM teams
		WHERE yearid BETWEEN 1990 AND 1999
				),			
	 games_2000s AS 
				(
			SELECT ROUND(SUM(so) * 1.0 / SUM(g),2) AS avg_strikeouts
				  ,ROUND(SUM(hr) * 1.0 / SUM(g),2) AS avg_home_run
		FROM teams
		WHERE yearid BETWEEN 2000 AND 2009
				),			
	 games_2010s AS 
				(
			SELECT ROUND(SUM(so) * 1.0 / SUM(g),2) AS avg_strikeouts
			      ,ROUND(SUM(hr) * 1.0 / SUM(g),2) AS avg_home_run
		FROM teams
		WHERE yearid BETWEEN 2010 AND 2016
	) 	
			
 SELECT *,
      CASE WHEN avg_strikeouts = 2.81 THEN '1920s'
	    WHEN avg_strikeouts = 3.32 THEN '1930s'
	     WHEN avg_strikeouts = 3.55 THEN '1940s'
		  WHEN avg_strikeouts = 4.40 THEN '1950s'
		   WHEN avg_strikeouts = 5.72 THEN '1960s'
		    WHEN avg_strikeouts = 5.14 THEN '1970s'
		     WHEN avg_strikeouts = 5.36 THEN '1980s'
			  WHEN avg_strikeouts = 6.15 THEN '1990s'
			   WHEN avg_strikeouts = 6.56 THEN '2000s'
			    WHEN avg_strikeouts = 7.52 THEN '2010s' end AS Decade
FROM (
	SELECT *
	FROM games_1920s
		UNION ALL 
	SELECT *
	FROM games_1930s
		UNION ALL 
	SELECT * 
	FROM games_1940s
		UNION ALL 
	SELECT * 
	FROM games_1950s
		UNION ALL 
	SELECT * 
	FROM games_1960s
	UNION ALL 
		SELECT * 
	FROM games_1970s
		UNION ALL 
	SELECT * 
	FROM games_1980s
		UNION ALL 
	SELECT * 
	FROM games_1990s
		UNION ALL 
	SELECT * 
	FROM games_2000s
		UNION ALL 
	SELECT * 
	FROM games_2010s)
--Answer: ^^ This question was heck	

--6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
SELECT playerid,CONCAT(namefirst, ' ',namelast) AS name, sb AS stolen_bases, cs AS caught_stealing,  ROUND((sb * 1.0) / (sb + cs),2) * 100 AS percent_stolen
FROM batting
INNER JOIN people 
USING(playerid)
WHERE yearid = 2016 AND sb + cs >=20
GROUP BY playerid, sb, cs, CONCAT(namefirst, ' ',namelast)
ORDER BY  ROUND((sb * 1.0) / (sb + cs),2) * 100 DESC

--Answer: Chris Owings	91%
	
--7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT yearid, teamid, w, l, wswin, w+l AS total_games, ROUND((w * 1.0) / (w+l),2) *100 AS win_perc_y
FROM teams
WHERE yearid >= 1970 AND wswin = 'Y'
ORDER BY w ASC
--Los Angeles Dodgers	
SELECT yearid, teamid, w, l, wswin,w+l AS total_games, ROUND((w * 1.0) / (w+l),2) *100 AS win_perc_n
FROM teams
WHERE yearid >= 1970 AND wswin = 'N'
ORDER BY w DESC
--Seattle Mariners	

WITH problem_year AS (
	SELECT yearid, teamid, w, l, wswin, w+l AS total_games, ROUND((w * 1.0) / (w+l),2) *100 AS win_perc_y
	FROM teams 
	WHERE yearid >= 1970 AND wswin = 'Y'
	ORDER BY w ASC
    ) 
SELECT * 
FROM problem_year
DELETE FROM problem_year WHERE yearid = 1981
	
 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	