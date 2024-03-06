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
SELECT playerid,CONCAT(namefirst, ' ',namelast) AS name, sb AS stolen_bases, cs AS caught_stealing, sb + cs AS num_attemps,  ROUND((sb * 1.0) / (sb + cs),2) * 100 AS percent_stolen
FROM batting
INNER JOIN people 
USING(playerid)
WHERE yearid = 2016 AND sb + cs >=20
GROUP BY playerid, sb, cs, CONCAT(namefirst, ' ',namelast)
ORDER BY  ROUND((sb * 1.0) / (sb + cs),2) * 100 DESC

--Answer: Chris Owings	91%





--7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. 
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
-- SELECT * 
-- FROM teams
-- WHERE yearid >=1970 AND w > l 
-- ORDER BY w DESC

-- WITH big_win AS 
-- 		(
-- 		SELECT wswin, COUNT(wswin) AS win
-- 		FROM teams 
-- 		WHERE wswin = 'Y' AND yearid >=1970 AND w > l 
-- 		GROUP BY wswin
-- 		),
--      big_lost AS 
-- 	 (
-- 		SELECT wswin, COUNT(wswin) AS lost
-- 		FROM teams
-- 		WHERE wswin = 'N' AND yearid >=1970 AND w > l 
-- 		GROUP BY wswin
-- 	   ) 
	   
-- SELECT *
-- FROM (
--    SELECT win
--    FROM big_win
--    FULL OUTER JOIN big_lost
--    USING(wswin)
   
-- )




WITH win AS (SELECT yearid, teamid, w, l, wswin, w+l AS total_games, ROUND((w * 1.0) / (w+l),2) *100 AS win_perc_y
FROM teams
WHERE yearid >= 1970 AND wswin = 'Y'
ORDER BY w ASC
LIMIT 1),
--LA Dodgers
win_fixed AS (SELECT yearid, teamid, w, l, wswin, w+l AS total_games, ROUND((w * 1.0) / (w+l),2) *100 AS win_perc_y
FROM teams
WHERE yearid >= 1970 AND wswin = 'Y' AND yearid != 1981
ORDER BY w ASC
LIMIT 1),
--	St. Louis Cardinals	
lose AS (SELECT yearid, teamid, w, l, wswin,w+l AS total_games, ROUND((w * 1.0) / (w+l),2) *100 AS win_perc_n
FROM teams
WHERE yearid >= 1970 AND wswin = 'N'
ORDER BY w DESC
		LIMIT 1)
--Seattle Mariners	

SELECT *
FROM win
UNION ALL 
SELECT * 
FROM lose
UNION ALL 
SELECT * 
FROM win_fixed
--Answer: Pt 1 ^^

SELECT  ROUND(((COUNT(wswin) * 1.0) / 53) * 100,2) AS perc_win_most_wins
FROM
(WITH max_wins AS (
	SELECT yearid, MAX(w) AS w
	FROM teams
	WHERE yearid >= 1970
	GROUP BY yearid
	ORDER BY yearid
	  )
SELECT yearid, name, w, wswin
FROM max_wins
INNER JOIN teams
USING(yearid, w)
GROUP BY yearid, name, w, wswin
ORDER BY yearid, w DESC)
WHERE wswin = 'Y'
--Answer: pt2 ^^ 22.64%

--8.Using the attendance figures from the homegames table, 
--find the teams and parks which had the top 5 average attendance per game in 2016
--(where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played.
--Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

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
--Answer: ^^ top 5 and bottom 5
SELECT* 
FROM (SELECT park_name,
homegames.attendance,
name,
games,
homegames.attendance / games AS attendance_per_year
FROM homegames
INNER JOIN parks
USING(park)
INNER JOIN teams
ON team = teamid AND year = yearid
WHERE year = 2016 AND games >= 10
ORDER BY attendance_per_year DESC 
LIMIT 5) AS top_5
UNION 
(SELECT park_name,
homegames.attendance,
name,
games,
homegames.attendance / games AS attendance_per_year
FROM homegames
INNER JOIN parks
USING(park)
INNER JOIN teams
ON team = teamid AND year = yearid
WHERE year = 2016 AND games >= 10
ORDER BY attendance_per_year ASC 
LIMIT 5)
ORDER BY attendance_per_year DESC
--class review ^

--9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)?
--Give their full name and the teams that they were managing when they won the award.
SELECT *
FROM awardsmanagers
INNER JOIN people
USING(playerid)

-- WITH AL AS (
-- 	SELECT playerid, lgid, yearid
-- FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL' 
-- ORDER BY playerid
-- 	),
-- NL AS (
-- 	SELECT playerid, lgid, yearid
-- FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year' AND lgid = 'NL' 
-- ORDER BY playerid
-- 	)
-- 	SELECT playerid, CONCAT(namefirst, ' ', namelast) AS name,AL.lgid, AL.yearid,
-- 															  NL.lgid, NL.yearid
															  
-- 	FROM AL
-- 	INNER JOIN NL 
-- 	USING(playerid)
-- 	INNER JOIN people
-- 	USING(playerid)	
----------------------------------------------					
SELECT CONCAT(people.namefirst,' ', people.namelast) AS fullname, teams.name, teams.lgid, awardsmanagers.yearid
FROM
	(SELECT playerid
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid IN('NL', 'AL')
	GROUP BY playerid
	HAVING COUNT(DISTINCT lgid) > 1) AS mb
INNER JOIN awardsmanagers ON mb.playerid = awardsmanagers.playerid
INNER JOIN people ON awardsmanagers.playerid = people.playerid
INNER JOIN managers ON people.playerid = managers.playerid AND awardsmanagers.yearid = managers.yearid
INNER JOIN teams ON managers.teamid = teams.teamid AND teams.yearid = managers.yearid
WHERE awardid = 'TSN Manager of the Year';					
					
--Answer:  ^^

--10.Find all players who hit their career highest number of home runs in 2016.
--Consider only players who have played in the league for at least 10 years, 
--and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

	
-- WITH career_2006 AS (SELECT playerid, yearid, hr 
-- FROM batting
-- WHERE yearid >= 2006 AND hr >=1
-- ORDER BY playerid, yearid DESC),

-- career_2016 AS (SELECT playerid, yearid
-- FROM batting
-- WHERE yearid = 2016 
-- GROUP BY playerid, yearid)

-- SELECT career_2016.playerid, career_2016.yearid, COUNT(hr)
-- FROM career_2006
-- INNER JOIN career_2016
-- ON career_2006.playerid = career_2016.playerid
-- -- GROUP BY career_2016.playerid, career_2016.yearid
-- -- ORDER BY COUNT(hr) DESC
-- -- ------------------------


-- WITH full_batting AS (
--  	SELECT 
-- 	playerid, yearid, 
-- 	SUM(hr) AS hr
-- FROM batting
-- 	GROUP BY playerid, yearid),
-- decaders AS (
-- 	SELECT playerid
-- FROM full_batting
-- 	GROUP BY  playerid
-- 	HAVING COUNT(*) >=10),
-- eligible_players AS (
-- 	SELECT playerid, hr
-- FROM decaders
-- 	INNER JOIN full_batting
-- 		USING(playerid)
-- 	WHERE yearid = 2016 AND hr >=1),
-- career_bests AS (
-- 	SELECT playerid, MAX(hr) AS hr
-- FROM full_batting
-- 	GROUP BY playerid)

-- SELECT CONCAT(namefirst, ' ' ,namelast) AS fullname,
-- hr
-- FROM eligible_players
-- JOIN career_beats
-- USING()
	
SELECT
    p.namefirst || ' ' || p.namelast AS player_name,
    b.hr AS home_runs_2016
FROM batting AS b
INNER JOIN people AS p ON b.playerID = p.playerid
WHERE b.yearid = 2016
	AND hr > 0
	AND EXTRACT(YEAR FROM debut::date) <= 2016 - 9
    AND b.hr = (
        SELECT MAX(hr)
        FROM batting
        WHERE playerid = b.playerid)
ORDER BY home_runs_2016 DESC;
--Answer^^ thank you jess
WITH highest_2016 AS
				/* return playerid and number of home runs if max was in 2016 */
			(SELECT  playerid,
						/* return hr when 2016 AND player hit their max hr */
						CASE WHEN hr = MAX(hr) OVER (PARTITION BY playerid) AND yearid = 2016 THEN hr
								END AS career_highest_2016
				FROM batting
				GROUP BY playerid, hr, yearid
				ORDER BY playerid)

SELECT  p.namefirst || ' ' || p.namelast AS name,
		h.career_highest_2016 AS num_hr
FROM highest_2016 AS h
LEFT JOIN people AS p
	ON h.playerid = p.playerid
WHERE h.career_highest_2016 IS NOT NULL
	AND h.career_highest_2016 > 0
	AND DATE_PART('year', p.debut::DATE) <= 2007
ORDER BY num_hr DESC;
--Derek thank you 