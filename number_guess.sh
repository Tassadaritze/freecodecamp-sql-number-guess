#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
ATTEMPTS=0

echo Enter your username:
read USERNAME
PLAYER_INFO=$($PSQL "SELECT games_played, best_game FROM player WHERE username='$USERNAME'")
if [[ -z $PLAYER_INFO ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
  NEW_PLAYER_INSERT=$($PSQL "INSERT INTO player(username) VALUES('$USERNAME')")
  PLAYER_INFO=$($PSQL "SELECT games_played, best_game FROM player WHERE username='$USERNAME'")
else
  echo $PLAYER_INFO | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  done
fi

GUESS_LOOP () {
  if [[ -z $1 ]]
  then
    echo Guess the secret number between 1 and 1000:
  else
    echo $1
  fi

  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    GUESS_LOOP "That is not an integer, guess again:"
    return
  fi

  ATTEMPTS=$(( $ATTEMPTS + 1 ))

  if [[ $GUESS > $SECRET_NUMBER ]]
  then
    GUESS_LOOP "It's lower than that, guess again:"
  elif [[ $GUESS < $SECRET_NUMBER ]]
  then
    GUESS_LOOP "It's higher than that, guess again:"
  else
    echo You guessed it in $ATTEMPTS tries. The secret number was $SECRET_NUMBER. Nice job!
    echo $PLAYER_INFO | while IFS="|" read GAMES_PLAYED BEST_GAME
    do
      GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
      if [[ -z $BEST_GAME || $ATTEMPTS < $BEST_GAME ]]
      then
        BEST_GAME=$ATTEMPTS
      fi
      PLAYER_UPDATE=$($PSQL "UPDATE player SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'")
    done
  fi
}

GUESS_LOOP
