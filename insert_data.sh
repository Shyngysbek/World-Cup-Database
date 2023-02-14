#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE TABLE games, teams")"
echo "$($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")"
echo "$($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]]
  then
    #insert winner team
    TEAM_NAME="$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")"
    if [[ -z $TEAM_NAME  ]]
    then
      TEAM_DATA_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
      if [[ $TEAM_DATA_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams: $WINNER"
      fi
    fi

    #insert opponent team
    TEAM_NAME="$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")"
    if [[ -z $TEAM_NAME ]]
    then
      TEAM_DATA_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
      if [[ $TEAM_DATA_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams: $OPPONENT"
      fi
    fi
  fi
done

#insert year, round, winner_id, opponent_id, winner_goals, opponent_goals
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]]
  then
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
    GAME_DATA_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
    if [[ $GAME_DATA_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games: $YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS"
    fi
  fi
done