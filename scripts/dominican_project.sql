SELECT namefirst|| ' ' || namelast, birthcountry
FROM people
WHERE birthcountry ilike '%D.R.%'


SELECT *
FROM awardsplayers


SELECT namefirst|| ' ' || namelast, birthcountry, awardid, ap.yearid
FROM people
INNER JOIN awardsplayers AS ap
USING (playerid)
WHERE birthcountry ilike '%D.R.%'
ORDER BY ap.yearid

--All the Dominican players who won awards, with the earliest award being Juan Marichal in 1963 

SELECT COUNT(DISTINCT awardid)
FROM awardsplayers;
--29 different awards given
SELECT DISTINCT awardid
FROM awardsplayers;

SELECT DISTINCT playerid, namefirst|| ' ' || namelast, birthcountry, appearances.yearid
FROM people
INNER JOIN appearances
USING (playerid)
WHERE birthcountry ilike '%D.R.%'
ORDER BY appearances.yearid

--earliest record of a dominican player was 1956 OZZIE VIRGIL

SELECT playerid, namefirst|| ' ' || namelast, birthcountry, appearances.yearid
FROM people
INNER JOIN appearances
USING (playerid)
WHERE birthcountry ilike '%D.R.%'

SELECT COUNT (DISTINCT playerid)
FROM people
WHERE birthcountry ilike '%D.R.%'

-- There have been 671 dominican players since the beginning of the data set in 1871- 2016

SELECT yearid
FROM teams;


-- Who was the first Dominican to play in American Baseball and when?


SELECT *
FROM people
WHERE namelast ilike 'virgil'
	AND namefirst ilike 'ozzie'
--player id for Ozzie Virgil is virgioz01
WITH ozzie AS (
	SELECT p.playerid, p.namefirst|| ' ' || p.namelast, p.debut, p.finalgame, a.yearid, 			a.teamid, t.name    
	FROM people AS p
	INNER JOIN appearances AS a
	USING (playerid)
	INNER JOIN teams as t
	ON a.teamid = t.teamid
	WHERE p.playerid ilike 'virgioz01'
	ORDER BY a.yearid	)

SELECT distinct teamid, name, yearid
FROM ozzie
ORDER BY yearid

-- What percentage of the baseball players have been Dominican (based on birth, not heritage)?
WITH dominicans AS (
	SELECT *
	FROM people
	WHERE birthcountry ilike '%D.R.%')
	
SELECT COUNT(dominicans.*)*1.0/count(people.*)
*100
FROM people 
INNER JOIN dominicans 
USING (playerid)

--percentage of players from 1871-2016
SELECT 	 a.yearid,
	(SELECT count(*)
	FROM people
	WHERE birthcountry ilike '%D.R.%')
 *1.0 / 
	(SELECT count(*)	
	 FROM people )* 100 
 AS total_dominicans 
FROM people
INNER JOIN appearances AS a
USING(playerid)

-- SELECT count(*) over(partition by a.yearid),
	SELECT a.yearid, a.dominicans, total_players, a.dominicans*1.0/total_players*100.0 as perc_dominican
	FROM
	(SELECT DISTINCT a.yearid, count(*) over(partition by a.yearid)
		AS dominicans
	FROM people
	INNER JOIN appearances as a
	USING (playerid)
	WHERE birthcountry ilike '%D.R.%')AS a	
INNER JOIN (SELECT DISTINCT a.yearid, count(playerid) AS total_players
	FROM people
	INNER JOIN appearances as a
	USING (playerid) 
	GROUP BY a.yearid	   ) as b
ON a.yearid=b.yearid
ORDER BY a.yearid



	 
SELECT DISTINCT playerid
FROM people
INNER JOIN appearances as a
USING (playerid)
where yearid = '2013' --1409 total players
AND people.birthcountry ilike 'D.R.'

--Awards won by Dominicans -255

SELECT DISTINCT a.playerid, p.namefirst|| ' ' || p.namelast, COUNT(a.awardid) AS award_count, a.yearid
FROM people as p
INNER JOIN awardsplayers as a
USING (playerid)
WHERE p.birthcountry ilike 'D.R.'
GROUP BY a.playerid, a.yearid, p.namefirst|| ' ' || p.namelast
ORDER BY award_count DESC;

--which was the most awarded to dominicans- silver slugger in 2004- 7 awards

SELECT a.awardid, COUNT(a.awardid) AS award_count, a.yearid
FROM people as p
INNER JOIN awardsplayers as a
USING (playerid)
WHERE p.birthcountry ilike 'D.R.'
GROUP BY a.awardid, a.yearid
ORDER BY award_count DESC

-- 255 awards -most to dominicans over all awards was 20 in 2004
SELECT COUNT(a.awardid) AS award_count, a.yearid
FROM people as p
INNER JOIN awardsplayers as a
USING (playerid)
WHERE p.birthcountry ilike 'D.R.'
GROUP BY a.yearid
ORDER BY award_count DESC
--of 80 awards given in 2004- 20 were to dominicans 1/4 when the percent of dominicans was only 10.7% 
SELECT count(awardid) as award_count
FROM awardsplayers
where yearid = '2004'


SELECT DISTINCT a.playerid, p.namefirst|| ' ' || p.namelast, COUNT(a.awardid) AS award_count 
FROM people as p
INNER JOIN awardsplayers as a
USING (playerid)
WHERE p.birthcountry ilike 'D.R.'
	AND a.yearid between 1956 and 2016
GROUP BY a.playerid, p.namefirst|| ' ' || p.namelast
ORDER BY award_count DESC;

-- Alberto Pujols awards- 23 0ver 9 year career
SELECT * 
FROM awardsplayers
where playerid = 'pujolal01'
ORDER by awardid

--highest awarded non-dominican- Barry Bonds
SELECT DISTINCT a.playerid, p.namefirst|| ' ' || p.namelast, COUNT(a.awardid) AS award_count 
FROM people as p
INNER JOIN awardsplayers as a
USING (playerid)
-- WHERE p.birthcountry ilike 'D.R.'
GROUP BY a.playerid, p.namefirst|| ' ' || p.namelast
ORDER BY award_count DESC;

--Barry Bonds playerid  bondsba01

WITH barry AS (
	SELECT p.playerid, p.namefirst|| ' ' || p.namelast, p.debut, p.finalgame, a.yearid, 			a.teamid, t.name    
	FROM people AS p
	INNER JOIN appearances AS a
	USING (playerid)
	INNER JOIN teams as t
	ON a.teamid = t.teamid
	WHERE p.playerid ilike 'bondsba01'
	ORDER BY a.yearid	)

SELECT distinct teamid, name, yearid
FROM barry
ORDER BY yearid

-- barry awards
SELECT * 
FROM awardsplayers
where playerid = 'bondsba01'

-- Most recent dominican- Manuel Margot margoma01

SELECT p.playerid, p.namefirst|| ' ' || p.namelast, p.debut, p.finalgame, a.yearid, 			a.teamid, t.name    
	FROM people AS p
	INNER JOIN appearances AS a
	USING (playerid)
	INNER JOIN teams as t
	ON a.teamid = t.teamid
	WHERE p.birthcountry ilike 'D.R.'
		AND a.yearid >=2015
	GROUP BY p.playerid, p.namefirst|| ' ' || p.namelast, p.debut, p.finalgame, a.yearid, 			a.teamid, t.name
	Order by MAX(p.debut)DESC	
	
WITH manuel AS (
	SELECT p.playerid, p.namefirst|| ' ' || p.namelast, p.debut, p.finalgame, a.yearid, 			a.teamid, t.name    
	FROM people AS p
	INNER JOIN appearances AS a
	USING (playerid)
	INNER JOIN teams as t
	ON a.teamid = t.teamid
	WHERE p.playerid ilike 'margoma01'
	ORDER BY a.yearid	)

SELECT distinct teamid, name, yearid
FROM manuel
ORDER BY yearid