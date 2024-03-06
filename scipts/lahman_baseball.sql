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
SELECT concat(namefirst,' ',namelast) AS player_name, ROUND(((stolen_bases*1.0)/(stolen_bases+caught_stealing))*100,2) AS perc_stolen_bases
FROM players_base_stats_2016
INNER JOIN people
USING(playerid)
ORDER BY ROUND(((stolen_bases*1.0)/(stolen_bases+caught_stealing))*100,2) DESC;


	

--Q7.) From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
/*WITH max_num_wins_lost_WS AS (
							SELECT name, yearid, w AS wins, wswin
							FROM teams
							WHERE yearid BETWEEN 1970 AND 2016
							AND wswin = 'N'
							ORDER BY w DESC
							--LIMIT 1
							---seattle mariners
						),
	min_num_wins_won_WS AS (
							SELECT name, yearid, w AS wins, wswin
							FROM teams
							WHERE yearid BETWEEN 1970 AND 2016
							AND wswin = 'Y'
							ORDER BY w ASC
							--LIMIT 1
							---LA Dodgers
							)
SELECT *
FROM max_num_wins_lost_WS
UNION ALL
SELECT *
FROM min_num_wins_won_WS*/




--answer
WITH most_wins AS (
				SELECT yearid, MAX(w) AS w
				FROM teams
				WHERE yearid>=1970
				GROUP BY yearid
				ORDER BY yearid
				),
most_win_teams AS (
					SELECT yearid, name, wswin
					FROM teams
					INNER JOIN most_wins
					USING (yearid,w)
					)
SELECT 
	(SELECT COUNT(*)
	FROM most_win_teams
	WHERE wswin = 'Y'
	) * 100.0 /
	(SELECT COUNT(*)
	FROM most_win_teams
	);


--Q8.)Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
SELECT park_name,
homegames.attendance,
name,
games,
homegames.attendance / games AS attendance_per_game
FROM homegames
INNER JOIN parks
USING(park)
INNER JOIN teams
ON team=teamid AND year=yearid
WHERE year=2016 AND games>=10
ORDER BY attendance_per_game DESC
LIMIT 5;



--My queries
WITH top_avg_games AS (
					SELECT team, park, attendance, games, year
					FROM homegames
					WHERE year = 2016 
						AND games >= 10 
					ORDER BY attendance DESC
					)
SELECT team, park_name, attendance/games AS attendance_per_games
FROM top_avg_games
INNER JOIN parks
USING(park)
ORDER BY attendance_per_games DESC
LIMIT 5;



WITH low_avg_games AS (
					SELECT team, park, attendance, games, year
					FROM homegames
					WHERE year = 2016 
						AND games >= 10 
					ORDER BY attendance ASC
					)
SELECT team, park,_name attendance/games AS attendance_per_games
FROM low_avg_games
INNER JOIN parks
USING(park)
ORDER BY attendance_per_games ASC
LIMIT 5;
	


--emily answer
WITH top_5_attendance AS
(SELECT teams.name, homegames.team, park_name, homegames.attendance, games, homegames.attendance/games AS attendance_per_game, 'TOP 5' AS ranking
FROM homegames
FULL JOIN parks
USING (park)
FULL JOIN teams
ON parks.park = teams.park
WHERE year = 2016 
AND games >= 10
ORDER BY homegames.attendance/games DESC
LIMIT 5), 

bottom_5_attendance AS
(SELECT teams.name, homegames.team, park_name, homegames.attendance, games, homegames.attendance/games AS attendance_per_game, 'BOTTOM 5'AS ranking
FROM homegames
FULL JOIN parks
USING (park)
FULL JOIN teams
ON parks.park = teams.park
WHERE year = 2016 
AND games >= 10
ORDER BY homegames.attendance/games
LIMIT 5)

SELECT *
FROM top_5_attendance
UNION ALL
SELECT *
FROM bottom_5_attendance



--Q9.)Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
WITH NL_TSN AS (
				SELECT playerid, awardid, yearid,lgid AS NL
				FROM awardsmanagers
				WHERE awardid ILIKE '%TSN%'
				AND lgid = 'NL'
				),
AL_TSN AS (
			SELECT playerid, awardid, yearid,lgid AS AL
				FROM awardsmanagers
				WHERE awardid ILIKE '%TSN%'
				AND lgid = 'AL'
			),
manager_name AS (
					SELECT playerid, concat(namefirst,' ',namelast) AS manager_name
					FROM people
			),

team_name AS (
				SELECT playerid, teamid, name AS team_name
				FROM appearances
				LEFT JOIN teams
				USING (teamid)
				)
SELECT DISTINCT(playerid), manager_name, team_name, NL, AL
FROM awardsmanagers
INNER JOIN NL_TSN
USING(playerid)
INNER JOIN AL_TSN
USING(playerid)
INNER JOIN manager_name
USING(playerid)
INNER JOIN team_name
USING(playerid)


--Dibran answer
WITH both_league_winners AS (
	SELECT playerid, count(DISTINCT lgid)
	FROM awardsmanagers
	WHERE awardid = 'TSN Manager of the Year'
		AND lgid IN ('AL', 'NL')
	GROUP BY playerid
	HAVING COUNT(DISTINCT lgid)=2
		)
SELECT namefirst ||' '||namelast AS full_name,
	yearid,
	lgid,
	name
FROM people
INNER JOIN both_league_winners
USING(playerid)
INNER JOIN awardsmanagers
USING(playerid)
INNER JOIN managers
USING(playerid,yearid,lgid)
INNER JOIN teams
USING (teamid,yearid,lgid)
WHERE awardid = 'TSN Manager of the Year'


--Q10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.




--Presentation
Select *
FROM parks
WHERE state = 'MI'

--------

WITH det_tigers AS (
					SELECT *
					FROM teams
					WHERE name ILIKE '%tiger%'
					),
				
players AS (
					SELECT namefirst || ' '||namelast AS player_name
					FROM people
				)
SELECT teamid, yearid, player_name
FROM appearances
INNER JOIN det_tigers
USING(teamid, yearid)
INNER JOIN players
ON appearances.playerid = people.playerid
	
	
--Detroit players
SELECT namefirst|| ' '||namelast AS player_name, yearid, name AS team_name
FROM people
INNER JOIN appearances
USING(playerid)
INNER JOIN teams
USING(yearid)
WHERE name ILIKE '%Tiger%'
	

--players who played on DET Tigers and Went to Michigan State
WITH detroit_players AS (SELECT namefirst|| ' '||namelast AS player_name, yearid, name AS mlb_team_name, playerid
						FROM people
						INNER JOIN appearances
						USING(playerid)
						INNER JOIN teams
						USING(yearid)
						WHERE name ILIKE '%Tiger%')
SELECT DISTINCT(player_name), mlb_team_name, schoolname, inducted, category
FROM collegeplaying
INNER JOIN detroit_players
USING(playerid)
INNER JOIN schools
USING(schoolid)
INNER JOIN halloffame
USING(playerid)
WHERE schoolname ILIKE '%Michigan State Univ%'



WITH msu_spartans AS (
			SELECT DISTINCT(playerid), schoolname
			FROM collegeplaying
			INNER JOIN schools
			USING(schoolid)
			WHERE schoolname ILIKE '%Michigan State Univ%'
			)
SELECT DISTINCT(concat(namefirst,' ',namelast)) AS player_name, schoolname, inducted
FROM people
INNER JOIN msu_spartans
USING(playerid)
INNER JOIN halloffame
USING(playerid)

---Grandpa Anderson
WITH walter_anderson AS (
							select namefirst|| ' '||namelast AS player_name, concat(birthmonth, '/',birthday,'/',birthyear) AS birthday, birthstate, birthcity, playerid, throws, debut, finalgame, namegiven, schoolname
							FROM people
							INNER JOIN collegeplaying
							USING(playerid)
							INNER JOIN schools
							ON collegeplaying.schoolid = schools.schoolid
							WHERE namefirst|| ' '||namelast ILIKE '%Walter Ander%'
						)
SELECT player_name, birthday, birthstate, birthcity, schoolname, teamid, yearid, throws, SO AS strikeouts, g AS games, era
FROM pitching
INNER JOIN walter_anderson
USING(playerid)



--Average height of a pitcher
SELECT
	CASE
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
	END AS position_group,
	SUM(po) AS total_po
FROM fielding
GROUP BY position_group;

