SELECT *
FROM allstarfull;

SELECT *
FROM teams;

-- 1. What range of years for baseball games played does the provided database cover? 

SELECT MIN(yearid)
FROM allstarfull;

SELECT MIN(yearid)
FROM appearances;

SELECT MAX(yearid), MIN(yearid), MAX(yearid)-MIN(yearid) AS range
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

--official answer key
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


--teammate answer__
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
GROUP BY position;

--official answer key
SELECT
	CASE
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
	END AS position_group,
	SUM(po) AS total_po
FROM fielding
WHERE yearid = 2016
GROUP BY position_group



-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

--verifying info- table exploration
SELECT *
FROM teams;

SELECT 10*floor(yearid/10) AS decade
FROM teams;

SELECT 10*floor(yearid/10) AS decade
FROM teams
ORDER BY 10*floor(yearid/10) DESC;

SELECT ROUND(AVG(so), 2) AS average_so
FROM teams;
--744.15

SELECT SUM(g) AS total_games
FROM teams;
--426582

SELECT ROUND(AVG(so)/SUM(g),2) AS avg_so_per_g
FROM teams

SELECT ROUND(AVG(hr), 2) AS average_hr
FROM teams;

--102.5


	--MAIN QUERY	
SELECT 10*floor(yearid/10) AS decade, ROUND(SUM(so)*1.0/SUM(g),2) AS avg_so_per_g,  ROUND(sum(hr)*1.0/sum(g),2) AS avg_hr_per_g
FROM teams
WHERE 10*floor(yearid/10)>= '1920'
GROUP BY decade
ORDER BY decade

--ANSWER: The average strikeouts per game increases until the 50's and 60's after which it dropped and began ascending again to the most rescent all time high in strike outs Highest hr avg is still in the 1950's at .81.



--teammate query-
WITH games_since1920	AS (
						SELECT
							COUNT(G) AS games_played,
							10*FLOOR(yearid/10) AS Decade,
							ROUND(AVG(hr),2) AS AVG_homeruns,
							ROUND(AVG(so),2) AS AVG_strikeouts
						FROM teams
						WHERE yearid >=1920
						GROUP BY Decade)
SELECT Decade, 
		ROUND(AVG_homeruns/games_played,2) AS homeruns_per_game,
		ROUND(AVG_strikeouts/games_played,2) AS strikeouts_per_game
FROM games_since1920
ORDER BY Decade ASC

--official answer key

ROUND(SUM(so) * 1.0 / SUM(g), 2) AS so_per_game,
	ROUND(SUM(hr) * 1.0 / SUM(g), 2) AS hr_per_game
	
	
-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

Select playerid, SUM(sb)*1.0/(cs+sb)*100 AS success_sb
FROM fielding
WHERE sb IS NOT NULL
	AND cs IS NOT NULL
	AND yearid = '2016'
HAVING SUM(cs+sb) >20
GROUP BY playerid

SELECT * 
FROM fielding
--cte
WITH stealing_players AS
	(	Select playerid, sb, cs
		FROM batting 
		WHERE (cs + sb) >=20 
			AND yearid = 2016	)
--MAIN QUERY			
SELECT playerid, people.namefirst || ' ' || people.namelast AS fullname, ROUND(SUM(sb)*1.0/SUM(cs+sb),2)*100 AS success_sb
FROM stealing_players
INNER JOIN people	
USING (playerid)
GROUP BY playerid, people.namefirst || ' ' || people.namelast
ORDER BY ROUND(SUM(sb)*1.0/SUM(cs+sb),2)*100 DESC;

-- ANSWER: Chris Owings with 91% success

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. 

SELECT * 
FROM teams;

-- CTE
WITH wins AS 
	(	SELECT yearid, name, wswin, w, l
		FROM teams
		WHERE wswin IS NOT NULL
		AND yearid between 1970 and 2016 )
		
--MAIN QUERY
SELECT name, wswin, MAX(w)
FROM wins
WHERE wswin ilike 'N'
GROUP BY name, wswin
ORDER BY MAX(w) DESC

-- ANSWER Part A: Largest wins that did not win WS- 116- Seattle Mariners

WITH wins AS 
	(	SELECT yearid, name, wswin, w, l
		FROM teams
		WHERE wswin IS NOT NULL
		AND yearid between 1970 and 2016 )
		
--MAIN QUERY
SELECT name, wswin, yearid, MIN(w)
FROM wins
WHERE wswin ilike 'y'
GROUP BY name, wswin, yearid
ORDER BY MIN(w)

-- ANSWER Part B: LA DODGERS won WS with only 63 wins- in 1981 but there was a strike that year.

WITH wins AS 
	(	SELECT yearid, name, wswin, w, l
		FROM teams
		WHERE wswin IS NOT NULL
		AND yearid between 1970 and 2016 )
		
--MAIN QUERY
SELECT name, wswin, yearid, MIN(w)
FROM wins
WHERE wswin ilike 'y'
	AND yearid <> '1981'
GROUP BY name, wswin, yearid
ORDER BY MIN(w);

--Answer part c: if 1981 is excluded, the next WS winner is St. Louis Cardinals with 83 wins in 2006


-- 7D. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT MAX(w), yearid,
FROM teams
WHERE yearid>= 1970

WITH wins AS 
	(	SELECT yearid, name, wswin, w, MAX(w) AS max_wins
		FROM teams
		WHERE wswin IS NOT NULL
		AND yearid between 1970 and 2016
		GROUP BY yearid, name, wswin,w
		ORDER BY max(w) DESC 	)

ws_wins AS 
	(	SELECT yearid, name, wswin, w, MAX(w) AS max_wins
		FROM teams
		WHERE wswin IS NOT NULL
		AND yearid between 1970 and 2016
		GROUP BY yearid, name, wswin,w
		ORDER BY max(w) DESC 	)

--MAIN QUERY
SELECT 
	(SELECT COUNT(wswin)
       	FROM wins
		WHERE wswin ilike 'y'
	 	GROUP BY w, max_wins --yearid, name, wswin, l 
		HAVING w =max_wins) *1.0	/OUNT(wswin)
							FROM wins )*100 AS percent
		
FROM wins
-- GROUP BY yearid, name, wswin, w, l, max_wins



-- ANSWER: NY Yankees in 1998 with 114 wins





-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


SELECT * 
FROM homegames

WITH top_5 AS (
	SELECT hg.team, p.park_name, hg.attendance/hg.games AS avg_attendance, 'TOP 5' AS ranking 
	FROM homegames as hg
	INNER JOIN parks as p
	USING (park)
	INNER JOIN teams as t
	ON hg.team = t.teamid AND hg.year = t.yearid
	WHERE hg.year= 2016
-- 	AND hg.team = t.teamid
	GROUP BY hg.team, hg.team, park_name, hg.games, hg.attendance
	HAVING hg.games>= 10
	ORDER BY avg_attendance DESC
	LIMIT 5	),

bottom_5 AS (
	SELECT hg.team, p.park_name, hg.attendance/hg.games AS avg_attendance, 'BOTTOM 5' AS ranking  
	FROM homegames as hg
	INNER JOIN parks as p
	USING (park)
	INNER JOIN teams as t
	ON hg.team = t.teamid AND hg.year = t.yearid
	WHERE hg.year= '2016'
	GROUP BY hg.team, park_name, hg.games, hg.attendance
	HAVING hg.games>= 10
	ORDER BY avg_attendance
	LIMIT 5	)
	
SELECT *
FROM top_5
UNION ALL
SELECT *
FROM bottom_5


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award

WITH nl_award AS (
	SELECT *
	FROM awardsmanagers
	INNER JOIN people
	USING (playerid)
	WHERE awardid ilike '%TSN%'
		AND lgid ilike 'NL'	), 
		
al_award AS (
SELECT *
	FROM awardsmanagers
	INNER JOIN people
	USING (playerid) 
	WHERE awardid ilike '%TSN%'
		AND lgid ilike 'AL'	)		
		
-- SELECT * 
-- FROM al_award, nl_award
-- WHERE al_award.playerid=nl_award.playerid

-- teams_mgrs AS (
-- 	SELECT *
-- 	FROM managershalf
-- 	INNER JOIN teams
-- 	USING(teamid)	)

SELECT
	namefirst || ' ' || namelast AS full_name,
	yearid,
	lgid,
	name
FROM people
INNER JOIN nl_award
USING(playerid)
INNER JOIN al_award
USING(playerid)
INNER JOIN awardsmanagers
USING(playerid)
INNER JOIN managers
USING(playerid, yearid, lgid)
INNER JOIN teams
USING(teamid, yearid,lgid)
WHERE awardid = 'TSN Manager of the Year'




--ANSWER dibran

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


-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

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
