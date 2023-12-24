#! /bin/bash
PSQL="psql --username=postgres --dbname=salon --tuples-only -c "
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
# re-enter name
NAME_AGAIN(){
    echo -e "\nWhat is your name? "
  sleep 1
      read CUSTOMER_NAME
  if [[ ! $CUSTOMER_NAME =~ ^[a-zA-Z]+$ ]]
  then
  NAME_AGAIN
  else
    echo -e "\nYour name is $CUSTOMER_NAME"
    sleep 1
    SERVICE_AGAIN
  fi
}
# re-enter phone number
PHONE_AGAIN(){
  echo -e "\nWhat is your phone number? (format: 012-345-6789) "
  read CUSTOMER_PHONE
  if [[ ! $CUSTOMER_PHONE =~ ^(1-)?[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]
  then
  PHONE_AGAIN
  else
    echo -e "\nYour phone number is $CUSTOMER_PHONE"
    sleep 1
    NAME_AGAIN
  fi
}
# re-enter service time
SERVICE_AGAIN(){
        echo -e "\nWhen would you like to come? (format: 1:45 or 01:45)"
        read SERVICE_TIME
        if [[ ! $SERVICE_TIME =~ ^[0-9]{1,2}:([0]{2}|[0-9]{2})$ ]]
        then
          SERVICE_AGAIN
        else
          echo -e "\nYour Service Appointed time is $SERVICE_TIME" | sed -E 's/^([0-9]{1}):/0\1:/'
            sleep 1
        fi
}
#What is the customer's information
CUSTOMER_INFORMATION(){
  # What is your phone number?
  echo -e "\nWhat is your phone number? (format: 012-345-6789)"
  sleep 1
  read CUSTOMER_PHONE
  if [[ ! $CUSTOMER_PHONE =~ ^(1-)?[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]
  then
  #invalid phone number
  echo -e "\nThis is not a vaild phone number. Try again."
  PHONE_AGAIN
  else
  # What is your name?
  echo -e "\nWhat is your name?"
    sleep 1
    read CUSTOMER_NAME
      if [[ ! $CUSTOMER_NAME =~ ^[a-zA-Z]+$ ]]
      then
        NAME_AGAIN
      else
        # What is your service appointment TIME?
      echo -e "\nWhen would you like to come? (format: 1:45 or 01:45)"
        sleep 1
        read SERVICE_TIME
        if [[ ! $SERVICE_TIME =~ ^[0-9]{1,2}:([0]{2}|[0-9]{2})$ ]]
        then
        echo -e "\nChoose a valid time from our format (format: 1:45 or 01:45)"
          SERVICE_AGAIN
        else
          #enter time appointed
          echo -e "\nYour Service Appointed time is $SERVICE_TIME" | sed -E 's/([0-9]{1}):/0\1:/g'
        fi
      fi
  fi
  
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
      NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED");
      IDENTIFY_SERVICE_CHOSEN $NAME
      fi
      sleep 1
      CUSTOMER_INFORMATION
    fi
  
}

WELCOME