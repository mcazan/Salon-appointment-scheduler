#!/bin/bash

echo -e "\n~~~~~ Michelle Hair Salon ~~~~~\n"
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

BOOK_APPOINTMENT() {

  # list of available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # formatted list of services
  # version 1
  #AVAILABLE_SERVICES_FORMATTED=$(echo "$AVAILABLE_SERVICES" | sed 's/ |/)/g')
  
  # version 2
  AVAILABLE_SERVICES_FORMATTED=$(echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do 
    echo "$SERVICE_ID) $SERVICE_NAME"
  done)

  echo "Welcome to Michelle Hair Salon, how can I help you?"
  echo -e "\n$AVAILABLE_SERVICES_FORMATTED\n"
  
  # ask user for service_id
  read SERVICE_ID_SELECTED

  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo "Please enter a valid option. Service id should be a number."
    echo -e "\n$AVAILABLE_SERVICES_FORMATTED\n"
    read SERVICE_ID_SELECTED
  fi

  # search for inputed service_id
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # if not found
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    # redirect to list of available services
    echo -e "\nI could not find that service. What would you like today?"
    echo -e "\n$AVAILABLE_SERVICES_FORMATTED\n"
    read SERVICE_ID_SELECTED
  else
    # ask user for phone number
    echo -e "\nWhat's your phone number?\n"
    read CUSTOMER_PHONE

    # search for customer
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")  

    # if not found
    if [[ -z $CUSTOMER_NAME ]]
    then
      # ask for name 
      echo -e "\nI don't have a record for that phone number, what's your name?\n"
      read CUSTOMER_NAME

      #insert client in customers table
      INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # ask for time
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *| *$//g'), $CUSTOMER_NAME?\n"
    read SERVICE_TIME

    # insert appointment into appointments table
    INSERT_SERVICE_TIME=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    # insert successful 
    if [[ $INSERT_SERVICE_TIME == 'INSERT 0 1' ]]
    then
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    fi
  
  fi
}

BOOK_APPOINTMENT

