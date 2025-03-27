#!/bin/bash

echo -e "\n~~~~ MY SALON ~~~~\n"

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
# maybe add -c flag to the end

MAIN_MENU () {
  
  if [[ -z $1 ]]
  then
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  else
    echo -e "\n$1"
  fi
  
  SERVICES="$($PSQL "SELECT service_id, name FROM services;")"

  echo "$SERVICES" | while IFS="|" read ID NAME
  do
  echo -e "$ID) $NAME"
  done
  read SERVICE_ID_SELECTED;

  SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")"
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    RESERVE_SERVICE $SERVICE_ID_SELECTED $SERVICE_NAME
  fi
}

RESERVE_SERVICE () {
  echo "What's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER="$($PSQL "SELECT name, customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")"
  IFS='|' read -r CUSTOMER_NAME ID <<< $CUSTOMER

  if [[ -z $CUSTOMER ]]
  then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  NEW_CUSTOMER="$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id;;")"
  IFS=$'\n' read -r ID INPUT_OUTCOME <<< $NEW_CUSTOMER
  fi

  echo -e "\nWhat time would you like your $2, $CUSTOMER_NAME?"
  read SERVICE_TIME

  NEW_APPOINTMENT="$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $ID, $1) ")"
  echo -e "\n I have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."

}

MAIN_MENU
