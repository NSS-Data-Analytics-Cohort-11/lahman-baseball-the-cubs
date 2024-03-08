WITH
  steroid_chart AS (
    SELECT
      CASE
        WHEN yearid BETWEEN '1985' AND '1994'  THEN 'Pre Roid'
        WHEN yearid BETWEEN '1995' AND '2004'  THEN 'Roid Era'
        WHEN yearid BETWEEN '2005' AND '2014'  THEN 'Post Roid'
      END AS Era,
      SUM(hr) AS total_hr
    FROM
      teams
	 where yearid between 1985 and 2014
    GROUP BY
      yearid
  )
SELECT
  Era,
 sum(total_hr) as total_hr
FROM
  steroid_chart
GROUP BY
  Era
ORDER BY
  Era;
  
---

SELECT
  Era,
  COUNT(DISTINCT playerid) AS total_players
FROM
  (
    SELECT
      playerid,
      CASE
        WHEN yearid BETWEEN '1983' AND '1992'  THEN 'Pre Roid'
        WHEN yearid BETWEEN '1993' AND '2002'  THEN 'Roid Era'
        WHEN yearid BETWEEN '2003' AND '2012'  THEN 'Post Roid'
      END AS Era
    FROM
      batting
    WHERE
      hr >= 40
      AND yearid BETWEEN '1983' AND '2012'
  ) AS subquery
GROUP BY
  Era;
  
  --
  
  
WITH hit_avg AS (
  SELECT
    playerid,
    SUM(h) AS total_hits,
	SUM(hr)as total_hr,
	yearid,
    SUM(ab) AS total_at_bats,
    ROUND(SUM(h) * 1.0 / SUM(ab), 3) AS batting_avg,
    CASE
      WHEN SUM(hr) >= 40 AND yearid BETWEEN '1983' AND '1992' THEN 'Pre Roid'
      WHEN SUM(hr) >= 40 AND yearid BETWEEN '1993' AND '2002' THEN 'Roid Era'
      WHEN SUM(hr) >= 40 AND yearid BETWEEN '2003' AND '2012' THEN 'Post Roid'
    END AS era
  FROM
    batting
	where yearid between 1983 and 2012
  GROUP BY
    playerid,yearid
  HAVING
    SUM(hr) >= 40
  ORDER BY
    yearid,playerid
)
SELECT * FROM hit_avg;
