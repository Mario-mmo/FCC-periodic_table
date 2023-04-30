#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# If no args, output text and finish running
if [[ -z $1 ]]
then
	echo "Please provide an element as an argument."

# If args, check arg and output the data
else
	# Check input type
	if [[ $1 =~ [0-9]+ ]]
	then
		ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
		INPUT=1
	elif [[ $1 =~ ^[A-Z][a-z]$|^[A-Z]$ ]]
	then
		SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$1'")
		INPUT=2
	else
		NAME=$($PSQL "SELECT name FROM elements WHERE name = '$1'")
		INPUT=3
	fi

	# DB Queries
	if [[ -z $ATOMIC_NUMBER ]] && [[ -z $SYMBOL ]] && [[ -z $NAME ]]
	then
		echo "I could not find that element in the database."
	else
		case $INPUT in
			1)
				NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $1")
				SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $1")
			;;
			2)
				ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
				NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$1'")
			;;
			3)
				ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
				SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$1'")
		esac
		# Common DB queries
		TYPE=$($PSQL "SELECT type FROM types FULL JOIN properties ON types.type_id = properties.type_id WHERE atomic_number = $ATOMIC_NUMBER")
		MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
		MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
		BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
		# Final output
		echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
	fi
fi
