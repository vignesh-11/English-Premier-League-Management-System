 DELIMITER $$

CREATE TRIGGER exceed_team_count
    BEFORE INSERT
    ON team FOR EACH ROW
BEGIN
   DECLARE teamCount INT;
    
    SELECT COUNT(*)
    INTO teamcount
    FROM team;
    
		IF teamcount>20 THEN
		set new.TeamName = NULL;
	END IF;

END$$    

DELIMITER ;


DELIMITER $$
CREATE TRIGGER update_team_stat
    AFTER INSERT
    ON game_stat FOR EACH ROW
BEGIN

	DECLARE HomeTeam VARCHAR(30);
    DECLARE AwayTeam VARCHAR(30);

	SELECT g.HomeTeam, g.AwayTeam
    INTO HomeTeam, AwayTeam
    FROM game as g
    where g.MatchID = new.MatchID;

	IF new.HomeTeamGoals>new.AwayTeamGoals THEN
		UPDATE team_stat
        set Wins = Wins + 1
        where TeamName = HomeTeam;
        
        UPDATE team_stat
        set Points = Points + 3
        where TeamName = HomeTeam;
        
        UPDATE team_stat
        set Losses = Losses + 1
        where TeamName = AwayTeam;
        
	END IF;
	IF new.HomeTeamGoals<new.AwayTeamGoals THEN
		UPDATE team_stat
        set Wins = Wins + 1
        where TeamName = AwayTeam;
        
        UPDATE team_stat
        set Points = Points + 3
        where TeamName = AwayTeam;
        
        UPDATE team_stat
        set Losses = Losses + 1
        where TeamName = HomeTeam;
        
	END IF;
	IF new.HomeTeamGoals=new.AwayTeamGoals THEN
		UPDATE team_stat
        set Draws = Draws + 1
        where TeamName = AwayTeam;
        
        UPDATE team_stat
        set Points = Points + 1
        where TeamName = AwayTeam;

        UPDATE team_stat
        set Points = Points + 1
        where TeamName = HomeTeam;
        
        UPDATE team_stat
        set Draws = Draws + 1
        where TeamName = HomeTeam;
        
	END IF;

	UPDATE team_stat
    set GoalDiff = GoalDiff + (new.HomeTeamGoals - new.AwayTeamGoals)
    where TeamName = HomeTeam;

    UPDATE team_stat
    set GoalDiff = GoalDiff + (new.AwayTeamGoals - new.HomeTeamGoals)
    where TeamName = AwayTeam;

    UPDATE team_stat T 
    JOIN (
           SELECT *,
			ROW_NUMBER() OVER (ORDER BY Points DESC, GoalDiff DESC, TeamName ASC) AS RN
			FROM team_stat
          )T1
    ON T1.TeamName=T.TeamName
    SET T.LeaguePosition=RN ;

END$$    

DELIMITER ;




DELIMITER $$

CREATE TRIGGER attendance_check
    BEFORE INSERT
    ON game_stat FOR EACH ROW
BEGIN
   DECLARE HomeTeam Varchar(50);
   DECLARE capacity INT;
   
   SELECT g.HomeTeam
   INTO HomeTeam
   FROM game as g
   WHERE g.MatchID = new.MatchID;
   
   SELECT s.Capacity 
   INTO capacity
   FROM stadium as s
   WHERE s.Team = HomeTeam;
   
   if capacity<new.Attendance then
     set new.Attendance = NULL;
   end if;

END$$    

DELIMITER ;