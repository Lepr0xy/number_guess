#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

RANDOM_INT=$(( $RANDOM % 1000 + 1 ))
echo $RANDOM_INT
GUESS=0
GUESS_COUNT=0

echo "Enter your username:"
read USERNAME

DATABASE_NAME_CHECK=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
if [[ -z $DATABASE_NAME_CHECK ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
  BEST_GAME=0
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', $GAMES_PLAYED, $BEST_GAME)")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

  GAMES_PLAYED_FORMATTED=$(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g')
  BEST_GAME_FORMATTED=$(echo $BEST_GAME | sed -r 's/^ *| *$//g')
  DATABASE_NAME_CHECK_FORMATTED=$(echo $DATABASE_NAME_CHECK | sed -r 's/^ *| *$//g')

  echo "Welcome back, $DATABASE_NAME_CHECK_FORMATTED! You have played $GAMES_PLAYED_FORMATTED games, and your best game took $BEST_GAME_FORMATTED guesses."
fi

echo "Guess the secret number between 1 and 1000:"

while [[ $GUESS -ne $RANDOM_INT ]]
do
  read GUESS
  let "GUESS_COUNT+=1"

  if [[ $GUESS =~ ^[+-]?[0-9]+$ ]]
  then
    if [[ $GUESS == $RANDOM_INT ]]
    then
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_INT. Nice job!"
    elif [[ "$GUESS" -gt "$RANDOM_INT" ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

let "GAMES_PLAYED+=1"
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")

if [[ $GUESS_COUNT -lt $BEST_GAME || $BEST_GAME -eq 0 ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username = '$USERNAME'")
fi
