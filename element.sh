if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

ELEMENT_NUMBER=''
ELEMENT_NAME=''
ELEMENT_SYMBOL=''


if [[ $1 =~ ^[0-9]+$ ]] 
then
  ELEMENT_NUMBER=$1
else
  if [[ ${#1} -ge 3 ]]
  then
    ELEMENT_NAME=$1
  else
    ELEMENT_SYMBOL=$1
  fi
fi
if [[ -z $ELEMENT_NUMBER ]] && [[ -z $ELEMENT_NAME ]]
then
  ELEMENT_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$ELEMENT_SYMBOL'")
  ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$ELEMENT_SYMBOL'")
else
  if [[ -z $ELEMENT_NUMBER ]] && [[ -z $ELEMENT_SYMBOL ]]
  then
    ELEMENT_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$ELEMENT_NAME'")
    ELEMENT_SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$ELEMENT_NAME'")
  else
    if [[ -z $ELEMENT_NAME ]] && [[ -z $ELEMENT_SYMBOL ]]
    then
      ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number='$ELEMENT_NUMBER'")
      ELEMENT_SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number ='$ELEMENT_NUMBER'")
    fi
  fi
fi

if [[ -z $ELEMENT_NUMBER ]]
then
  echo "I could not find that element in the database."
  exit
fi


DATA=$($PSQL "SELECT types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number=$ELEMENT_NUMBER")
  
  # Read the pipe-separated data into variables
  echo "$DATA" | while IFS="|" read TYPE MASS MELT BOIL
  do
    echo "The element with atomic number $ELEMENT_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $TYPE, with a mass of $MASS amu. $ELEMENT_NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
  done


