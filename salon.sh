#! /bin/bash
PSQL="psql --username=postgres --dbname=salon --tuples-only -c "
#clear tables & reset sequence
echo $($PSQL "truncate appointments,customers;alter sequence customers_customer_id_seq restart with 1;alter sequence appointments_appointment_id_seq restart with 1;")

# enter phone number
ENTER_PHONE(){
  echo -e "\nWhat is your phone number? (1234567890 or 12343452345)."
  sleep 1
  read CUSTOMER_PHONE
  if [[ ! $CUSTOMER_PHONE =~ ^(1)?[0-9]{3}[0-9]{3}[0-9]{4}$ ]]
    then
    ENTER_PHONE
    else
    ENTER_NAME
  fi
}
# Enter Name
ENTER_NAME(){
  # What is your name?
    echo -e "\nWhat is your name?"
    sleep 1
      read CUSTOMER_NAME
      if [[ ! $CUSTOMER_NAME =~ ^[a-zA-Z]+$ ]]
        then
          # PLACE YOUR STATEMENT
          ENTER_NAME
        else
          ENTER_SERVICE_TIME
      fi
}
# re-enter service number
CHOOSE_AGAIN(){
  # display services again
      echo -e "\nOption #$SERVICE_ID_SELECTED is not available.\nPlease choose again.\n"
  #list of services
      SERVICES=$($PSQL "select * from services")
      echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
      do
        echo "$SERVICE_ID) $NAME"
      done
  SERVICE_COUNT=$($PSQL "select count(name) from services")
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]$ || $SERVICE_ID_SELECTED -gt $SERVICE_COUNT ]]
  then
  # display services again
    echo -e "\nOption #$SERVICE_ID_SELECTED is not available.\nPlease choose again.\n"
    sleep 1
    CHOOSE_AGAIN $SERVICE_ID_SELECTED $SERVICE_COUNT

    else
        NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED");
        IDENTIFY_SERVICE_CHOSEN $NAME
  fi

}
# What service was chosen?
IDENTIFY_SERVICE_CHOSEN(){
  echo -e "Great, you chose $1."
}
WELCOME(){
  echo -e "\n ~~~~~ MY SALON ~~~~~ \n"
    if [[ $1 ]]
    then
      echo -e "\n$1"
      sleep 2
      else
      #list of services
      SERVICES=$($PSQL "select * from services")
      echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
      do
        echo "$SERVICE_ID) $NAME"
      done
      # ask for service to purchase
      echo -e "\nWhich service would you like? (Choose by the number)"
      # Get num of rows from services table
      SERVICE_COUNT=$($PSQL "select count(name) from services")
      #user chooses a service.
      read SERVICE_ID_SELECTED
      # if service does not exist
        if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]$ || $SERVICE_ID_SELECTED -gt $SERVICE_COUNT ]]
        then
          #user chooses a service.
          CHOOSE_AGAIN
        else
      SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED");
      IDENTIFY_SERVICE_CHOSEN $SERVICE_NAME
      fi
      sleep 1
      CUSTOMER_INFORMATION
    fi
  
}

#What is the customer's information (serviceName)
CUSTOMER_INFORMATION(){
  ENTER_PHONE
  ENTER_NAME
  
}

WELCOME