#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo -e "\n~~ WORLD CUP DATABASE ~~\n"

#Clear any precious inserts
TRUNCATE_TABLE_RESULT=$($PSQL "TRUNCATE TABLE games,teams");
echo $TRUNCATE_TABLE_RESULT
if [[ $TRUNCATE_TABLE_RESULT = "TRUNCATE TABLE" ]]
then
  echo -e "\nGames table cleared!"
fi

#Loop through all lines in games.csv
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    
    #Fill teams table
    INSERT_INTO_WINNERS_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT(name) DO NOTHING")
    INSERT_INTO_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT(name) DO NOTHING")
    
    if [[ $INSERT_INTO_WINNERS_RESULT = "INSERT 0 0" && $INSERT_INTO_OPPONENT_RESULT = "INSERT 0 0" ]]
    then
      echo "Teams inserted successfully!"
    fi

    #Get team ids
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  
    #Fill games table
    INSERT_INTO_GAMES_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      echo "Games inserted successfully!"
  fi
done
