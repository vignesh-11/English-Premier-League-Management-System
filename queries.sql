--1)Find the manager name of the youngest player in the league.

SELECT ManagerName
FROM manager
WHERE ManagerName in (
				SELECT ManagerName
                       			FROM manager
                        	    WHERE MgrTeam in(
								SELECT PlayerTeam
                                            				FROM player
                                            				WHERE PlayerDOB = (SELECT MAX(PlayerDOB) f							rom player)
                                        				)
			       ); 

--2)Find venue and attendance of the scheduled matches.

SELECT game.MatchID, StadiumName as Venue, Attendance
FROM ((stadium JOIN game ON Team = HomeTeam)
		RIGHT OUTER JOIN game_stat ON game.MatchID = game_stat.MatchID);

--3)Name, team name and number of goals scored by the oldest player.

SELECT PlayerName, PlayerTeam, GoalsScored
FROM (player join player_stat ON player.PlayerID = player_stat.PlayerID)
WHERE PlayerDOB = (SELECT MIN(PlayerDOB) FROM player);


--4)Broadcaster name in Australia.

SELECT BroadcasterName
FROM broadcaster_info
WHERE BroadcasterID IN ( SELECT BroadcasterID
				FROM regional_broadcaster
                         		WHERE Region = 'Australia');

--5)Find name and team of top goal scorer.

SELECT PlayerName, PlayerTeam, GoalsScored
FROM ( player LEFT OUTER JOIN player_stat ON player.PlayerID =  player_stat.PlayerID )
WHERE GoalsScored = (SELECT MAX(GoalsScored) FROM player_stat);


--6)Find total goals scored by Leicester city at home.							

SELECT TeamName, SUM(HomeTeamGoals) AS HomeGoalsScored
FROM ( (team_stat Join game ON team_stat.TeamName = game.HomeTeam)
RIGHT OUTER JOIN (SELECT MatchID, HomeTeamGoals FROM game_stat)gs ON game.MatchID = gs.MatchID)
WHERE TeamName = 'Leicester City'
GROUP BY TeamName;
