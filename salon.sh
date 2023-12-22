#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "

echo -e "\n ~~~~~ MY SALON ~~~~~ \n"
#list of services
SERVICES=$($PSQL "select * from services")
echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # ask for service to purchase
  echo -e "\nWhich service would you like? (Choose by the number)"
  #user chooses a service.
  read SERVICE_TO_BUY
  # if service does not exist
  SERVICE_COUNT=$($PSQL "select count(name) from services")
  if [[ ! $SERVICE_TO_BUY =~ ^[0-9]$ || $SERVICE_TO_BUY > $SERVICE_COUNT ]]
  then
  # display services again
    echo -e "\nOption #$SERVICE_TO_BUY is not available.\nPlease choose again.\n"
      #list of services
      SERVICES=$($PSQL "select * from services")
      echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
      do
        echo "$SERVICE_ID) $NAME"
      done
  fi
  