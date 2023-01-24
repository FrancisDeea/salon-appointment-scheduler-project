#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~ Francis_dev's Salon ~~\n"
echo -e "Welcome to my Salon! How can i help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  # SHOW SERVICES AT WELCOME
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | sed -r 's/(^[0-9]+)(\|)(.*$)/\1 \2 \3/' | while read SERVICE_ID BAR NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  # IF YOU PICK A SERVICES NUMBER THAT DOESN'T EXIST, SHOW LIST AGAIN
  case $SERVICE_ID_SELECTED in
    1) GET_APPOINTMENT $SERVICE_ID_SELECTED;;
    2) GET_APPOINTMENT $SERVICE_ID_SELECTED;;
    3) GET_APPOINTMENT $SERVICE_ID_SELECTED;;
    4) GET_APPOINTMENT $SERVICE_ID_SELECTED;;
    *) MAIN_MENU "Please, enter a valid service." ;;
  esac
}

GET_APPOINTMENT() {
  SERVICE_ID=$1
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
  echo -e "\nEnter your phone number"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # IF PHONE DOESN'T EXIST, CREATE NEW CUSTOMER
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nEnter your name"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME
  # INSERT APPOINTMENT INTO DATABASE
  INSERT_APPO=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  if [[ $INSERT_APPO = 'INSERT 0 1' ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  fi
}

MAIN_MENU