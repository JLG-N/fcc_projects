#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Truncate tables to start fresh
$PSQL "TRUNCATE TABLE games, teams;"

# Read the CSV file and insert teams
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
    # Skip the header line
    if [[ $winner != "winner" ]]; then
        # Insert winner into teams table
        INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT (name) DO NOTHING;")
        
        # Insert opponent into teams table
        INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT (name) DO NOTHING;")
    fi
done

# Insert games into the games table
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
    # Skip the header line
    if [[ $winner != "winner" ]]; then
        # Get the IDs of the winner and opponent
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
        
        # Insert the game into the games table
        $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals);"
    fi
done