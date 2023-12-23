#! /bin/bash
PSQL="psql --username=postgres --dbname=salon --tuples-only -c "
# Choose from services (again)
CHOOSE_AGAIN(){
  #list of services
      SERVICES=$($PSQL "select * from services")
      echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
      do
        echo "$SERVICE_ID) $NAME"
      done
  SERVICE_COUNT=$($PSQL "select count(name) from services")
  read SERVICE_TO_BUY
  if [[ ! $SERVICE_TO_BUY =~ ^[0-9]$ || $SERVICE_TO_BUY -gt $SERVICE_COUNT ]]
  then
  # display services again
    echo -e "\nOption #$SERVICE_TO_BUY is not available.\nPlease choose again.\n"
    sleep 1
    CHOOSE_AGAIN $SERVICE_TO_BUY $SERVICE_COUNT

    else
        NAME=$($PSQL "select name from services where service_id=$SERVICE_TO_BUY");
        IDENTIFY_SERVICE_CHOSEN $NAME
  fi

}
# What service was chosen?
IDENTIFY_SERVICE_CHOSEN(){
  echo -e "Great, you chose $1."
}
WELCOME(){
  echo -e "\n ~~~~~ MY SALON ~~~~~ \n"
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
  read SERVICE_TO_BUY
  # if service does not exist
    if [[ ! $SERVICE_TO_BUY =~ ^[0-9]$ || $SERVICE_TO_BUY -gt $SERVICE_COUNT ]]
    then
    # display services again
      echo -e "\nOption #$SERVICE_TO_BUY is not available.\nPlease choose again.\n"
      #user chooses a service.
      CHOOSE_AGAIN
    else
    NAME=$($PSQL "select name from services where service_id=$SERVICE_TO_BUY");
    IDENTIFY_SERVICE_CHOSEN $NAME
    fi
}
WELCOME

  