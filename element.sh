#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Query element data
ELEMENT_INFO=$($PSQL "SELECT atomic_number, name, symbol, type, 
                             TO_CHAR(atomic_mass, 'FM999999999.999') AS atomic_mass, 
                             melting_point_celsius, boiling_point_celsius 
                      FROM elements 
                      JOIN properties USING(atomic_number) 
                      JOIN types USING(type_id) 
                      WHERE atomic_number::text = '$1' OR symbol = '$1' OR name = '$1'")

# Check if element was found
if [[ -z $ELEMENT_INFO ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Read query result into variables
IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT_INFO"

# Display result
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."

