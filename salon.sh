#!/bin/bash

# You MUST define this variable at the top for the lines below to work
PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

echo '~~~~~ MY SALON ~~~~~'

echo 'Welcome to My Salon, how can I help you?'
row_count=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT COUNT(*) FROM services")
while true; do
  while IFS='|' read -r id name; do
      echo "$id) $name"
  done < <(psql --username=freecodecamp --dbname=salon -t -A -F'|' -c "SELECT service_id, name FROM services")
  read SERVICE_ID_SELECTED
  if (( SERVICE_ID_SELECTED <=  row_count && SERVICE_ID_SELECTED > 0)); then
    break
  else
    echo 'I could not find that service. What would you like today?'
  fi
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# If not found
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # Insert new customer
  $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
fi

# Get the service name for the final message
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# FIX: Use the variable $CUSTOMER_NAME instead of hardcoding "Fabio"
# Also use $SERVICE_NAME instead of hardcoding "cut"
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Get customer_id (works for both new and returning customers now)
CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# FIX: Added single quotes around '$SERVICE_TIME' because it's a string (e.g., '10:30')
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUST_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."