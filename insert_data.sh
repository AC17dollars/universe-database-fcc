#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

insert_team() {
  local team_name="$1"

  local query="INSERT INTO teams (name) VALUES ('$team_name');"

  $PSQL "$query"
}

insert_game() {
  local year="$1"
  local round="$2"
  local winner="$3"
  local opponent="$4"
  local winner_goals="$5"
  local opponent_goals="$6"

  local winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  local opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

  local query="INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ('$year', '$round', '$winner_id', '$opponent_id', '$winner_goals', '$opponent_goals');"

  $PSQL "$query"
}

# Read the CSV file, extract unique team names, and insert them into the database
tail -n +2 "games.csv" | cut -d',' -f3,4 | tr ',' '\n' | sort -u | while read -r team_name; do
  insert_team "$team_name"
done

tail -n +2 "games.csv" | while IFS= read -r line; do
  IFS=',' read -ra values <<< "$line"

  year="${values[0]}"
  round="${values[1]}"
  winner="${values[2]}"
  opponent="${values[3]}"
  winner_goals="${values[4]}"
  opponent_goals="${values[5]}"

  insert_game "$year" "$round" "$winner" "$opponent" "$winner_goals" "$opponent_goals"
done