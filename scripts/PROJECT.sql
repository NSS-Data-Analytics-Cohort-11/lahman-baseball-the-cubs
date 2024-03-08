

--- total hrs by region steroid vs non steroid
WITH pre_roid
     AS (SELECT Sum(teams.hr) AS total_hrs,
                'Pre-Roid 1973 to 1982'       AS era,
                CASE
                  WHEN franchid IN ( 'ANA', 'SFG', 'SEA', 'SDP',
                                     'OAK', 'LAD' ) THEN 'West Coast'
                  WHEN franchid IN ( 'CHC', 'CHW', 'CIN', 'CLE',
                                     'KCR', 'MIL', 'MIN', 'STL' ) THEN
                  'Midwest'
                  WHEN franchid IN ( 'ARI', 'HOU', 'TEX', 'COL' ) THEN
                  'Southwest'
                  WHEN franchid IN ( 'ATL', 'WSN', 'FLA', 'TBD', 'BAL' ) THEN
                  'Southeast'
                  WHEN franchid IN ( 'PIT', 'PHI', 'NYY', 'NYM',
                                     'TOR', 'BOS','DET' ) THEN 'Northeast'
                END           AS region
         FROM   teams
         WHERE  yearid BETWEEN 1973 AND 1982
         GROUP  BY region
		 order by total_hrs ),
     roid_era
     AS (SELECT Sum(teams.hr) AS total_hrs,
                'Roid Era 1993 to 2002'        AS era,
                CASE
                  WHEN franchid IN ( 'ANA', 'SFG', 'SEA', 'SDP',
                                     'OAK', 'LAD' ) THEN 'West Coast'
                  WHEN franchid IN ( 'CHC', 'CHW', 'CIN', 'CLE',
                                     'KCR', 'MIL', 'MIN', 'STL' ) THEN
                  'Midwest'
                  WHEN franchid IN ( 'ARI', 'HOU', 'TEX', 'COL' ) THEN
                  'Southwest'
                  WHEN franchid IN ( 'ATL', 'WSN', 'FLA', 'TBD', 'BAL' ) THEN
                  'Southeast'
                  WHEN franchid IN ( 'PIT', 'PHI', 'NYY', 'NYM',
                                     'TOR', 'BOS','DET' ) THEN 'Northeast'
                END           AS region
         FROM   teams
         WHERE  yearid BETWEEN 1993 AND 2002
         GROUP  BY region
		 order by total_hrs desc)
SELECT *
FROM   pre_roid
UNION all
SELECT *
FROM   roid_era  

--40 hr hitters




WITH pre_roid
     AS (SELECT COUNT(batting.hr) AS total_40_hr_hitter,
                'Pre-Roid 1973 to 1982'       AS era,
                CASE
                  WHEN teamid IN ( 'ANA', 'SFG', 'SEA', 'SDP',
                                     'OAK', 'LAD','SFN','CAL','SDN','LAN' ) THEN 'West Coast'
                  WHEN teamid IN ( 'CHC', 'CHW', 'CIN', 'CLE',
                                     'KCR', 'MIL', 'MIN', 'STL', 'DET','CHN','KCA','CHA','ML4','SLN' ) THEN
                  'Midwest'
                  WHEN teamid IN ( 'ARI', 'HOU', 'TEX', 'COL' ) THEN
                  'Southwest'
                  WHEN teamid IN ( 'ATL', 'WSN', 'FLA', 'TBD', 'BAL','FLO' ) THEN
                  'Southeast'
                  WHEN teamid IN ( 'PIT', 'PHI', 'NYY', 'NYM',
                                     'TOR', 'BOS','NYN','NYA','MON' ) THEN 'Northeast'
                END          AS region
         FROM batting
         WHERE  yearid BETWEEN 1983 AND 1992 and hr > 40
         GROUP  BY region ),
     roid_era
    AS (SELECT COUNT(batting.hr) AS total_40_hr_hitter,
                'Roid era 1993 to 2002'       AS era,
                CASE
                   WHEN teamid IN ( 'ANA', 'SFG', 'SEA', 'SDP',
                                     'OAK', 'LAD','SFN','CAL','SDN','LAN' ) THEN 'West Coast'
                  WHEN teamid IN ( 'CHC', 'CHW', 'CIN', 'CLE',
                                     'KCR', 'MIL', 'MIN', 'STL', 'DET','CHN','KCA','CHA','ML4','SLN' ) THEN
                  'Midwest'
                  WHEN teamid IN ( 'ARI', 'HOU', 'TEX', 'COL' ) THEN
                  'Southwest'
                  WHEN teamid IN ( 'ATL', 'WSN', 'FLA', 'TBD', 'BAL','FLO' ) THEN
                  'Southeast'
                  WHEN teamid IN ( 'PIT', 'PHI', 'NYY', 'NYM',
                                     'TOR', 'BOS','NYN','NYA','MON' ) THEN 'Northeast'
                END          AS region
         FROM   batting
         WHERE  yearid BETWEEN 1993 AND 2002 and hr >40 
         GROUP  BY region ) 
SELECT *
FROM   pre_roid
UNION all
SELECT *
FROM   roid_era 
---
SELECT