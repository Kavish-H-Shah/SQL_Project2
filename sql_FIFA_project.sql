-- FIFA WORLD CUP DATASET PROJECT

-- GENERAL INFORMATION: 
-- 1) Due to World War II, the 1942 and 1946 FIFA World Cups were not held.
-- 2) West Germany and Germany are considered to be two different regions.

USE fifa_project; 
-- -------------------------------------------------------

-- 1) THE FOLLOWING QUERY DEPICTS NUMBER OF TIMES WORLD CUPS WON BY COUNTRIES
SELECT winner AS Country, COUNT(winner) AS Times_Won
FROM fifa_stats
WHERE Stage_Name = "final"
GROUP BY winner
ORDER BY Times_Won DESC;
-- -------------------------------------------------------

-- 2) THE FOLLOWING QUERY DEPICTS TOTAL NUMBER OF MATCHES WON BY TOP 10 COUNTRIES
SELECT winner AS Country, COUNT(winner) AS Times_Won
FROM fifa_stats
WHERE winner != "draw"
GROUP BY winner
ORDER BY Times_Won DESC
LIMIT 10;
-- -------------------------------------------------------

-- 3) THE FOLLOWING QUERY DEPICTS COUNTRIES TO REACH THE MOST IN FINALS
SELECT team, SUM(Times_reached_finals) AS Times_reached_finals FROM (
SELECT COUNT(team1) AS Times_reached_finals, team1 AS team
FROM fifa_stats
WHERE Stage_Name = "final"
GROUP BY team1
UNION
SELECT COUNT(team2) AS Times_reached_finals, team2 AS team
FROM fifa_stats
WHERE Stage_Name = "final"
GROUP BY team2) AS combined
GROUP BY team
ORDER BY Times_reached_finals DESC;
-- -------------------------------------------------------

-- 4) THE FOLLWING QUERY ILLUSTRATES HOME TEAM ADVANTAGE IN TERMS OF MATCHES WON
SELECT 
COUNT(Key_Id) AS Total_Matches, 
SUM(Home_Team_Win) AS Home_Team_Won, 
SUM(Home_Team_Win) / COUNT(Key_Id) * 100 AS "% Home_Team_Won", 
SUM(Away_Team_Win) AS Away_Team_Won,
SUM(Away_Team_Win) / COUNT(Key_Id) * 100 AS "% Away_Team_Won", 
SUM(Draw) AS Draw
FROM fifa_stats;

-- 5) THE FOLLWING QUERY ILLUSTRATES WHICH HOST COUNTRY HAVE WON THE TOURNAMENT
-- NOTE: HERE WEST GERMANY AND GERMANY ARE CONSIDERED AS A SINGLE COUNTRY.
SELECT year,
winner AS Country
FROM fifa_stats
WHERE Stage_Name = "final" AND winner LIKE CONCAT("%", Country_Name, "%");

-- 6) HOW HAVE THE NUMBER OF TEAMS AND MATCHES IN THE WORLD CUP CHANGED OVER TIME? 
CREATE VIEW no_of_teams_per_wc AS 
SELECT year, COUNT(team) AS Number_of_teams FROM
(SELECT year, team1 AS team FROM fifa_stats
UNION
SELECT year, team2 AS team FROM fifa_stats) AS combined
GROUP BY year;

CREATE VIEW no_of_matches_per_wc AS 
SELECT year, COUNT(*) AS Matches_per_WC
FROM fifa_stats 
GROUP BY year;

SELECT m.year, m.Matches_per_WC, t.Number_of_teams 
FROM no_of_matches_per_wc AS m 
INNER JOIN 
no_of_teams_per_wc AS t 
ON m.year = t.year;

-- 7) THE FOLLOWING QUERY DEPICTS WHICH TEAMS HAVE SCORED THE MOST GOALS IN WORLD CUP HISTORY?
SELECT team, Sum(Goals_Scored) AS Goals_Scored FROM (
SELECT team1 AS team, SUM(fifa_stats.home_team_score) AS Goals_Scored
FROM fifa_stats
GROUP BY team1
UNION
SELECT team2 AS team, SUM(fifa_stats.away_team_score) AS Goals_Scored
FROM fifa_stats
GROUP BY team2) AS combined
GROUP BY team
ORDER BY Goals_Scored DESC;

-- 8) THE FOLLOWING QUERY DEPICTS PLAYERS WHO WON GOLDEN_BOOT
SELECT DISTINCT fs.year, fa.Golden_BootS, fa.Goals 
FROM fifa_stats AS fs 
INNER JOIN fifa_awards AS fa 
ON fs.Year = fa.WC_Year;

-- 9) THE FOLLOWING QUERY ILLUSTRATES AVERAGE GOALS SCORED PER TOURNAMENT 
SELECT year, ROUND(AVG(Home_Team_Score + Away_Team_Score), 2) AS Avg_Goals_per_Tournament 
FROM fifa_stats 
GROUP BY year
ORDER BY Avg_Goals_per_Tournament DESC;

-- 10) THE FOLLOWING QUERY ILLUSTRATES THE STADIUMS TO HOST THE MOST WORLD CUPS
SELECT Country_name, City_Name, Stadium_Name, COUNT(Stadium_Name) AS Times_played 
FROM fifa_stats 
GROUP BY Stadium_Name
ORDER BY Times_played DESC
LIMIT 10;

-- 11) THE FOLLOWING QUERY ILLUSTRATES MATCHES ILLUSTRATES BEST AND WORST CASE SCENARIO 
SELECT year, Home_Team_Name, Away_Team_Name, winner AS Winner, Home_Team_Score, Away_Team_Score 
FROM fifa_stats
WHERE winner != "Draw"
ORDER BY ABS(Home_Team_Score - Away_Team_Score) DESC
LIMIT 40;

-- 12) FOLLOWING QUERY ILLUSTRATES WHICH MATCHES HAVE GONE IN PENALTIES 
SELECT year, team1, team2, Score_Penalties, winner, 
if(Home_Team_Score_Penalties < Away_Team_Score_Penalties, "Home_Team_Won", "Away_Team_Won") AS Who_Won ,
Stage_Name
FROM fifa_stats 
WHERE Penalty_Shootout != 0
ORDER BY year; 
