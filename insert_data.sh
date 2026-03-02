#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

while IFS="," read -r col1 col2 col3 col4 col5 col6; do
  $PSQL "INSERT INTO teams(name) VALUES ('$col3') ON CONFLICT (name) DO NOTHING;"
  $PSQL "INSERT INTO teams(name) VALUES ('$col4') ON CONFLICT (name) DO NOTHING;"

  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$col3';")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$col4';")

  $PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($col1,'$col2',$winner_id,$opponent_id,$col5,$col6);"
done < <(tail -n +2 games.csv)