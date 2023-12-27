#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo $($PSQL "truncate appointments,customers;alter sequence customers_customer_id_seq restart with 1;alter sequence appointments_appointment_id_seq restart with 1;")

MENU(){
    echo -e "\n ~~~~~ SALON ~~~~~ \n"
    # Get num of rows from services table
      SERVICE_COUNT=$($PSQL "select count(name) from services")
    # Get list of services the salon provides
      SERVICES=$($PSQL "select * from services order by service_id")
    # List available services
    echo -e "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
      do
        echo "$SERVICE_ID) $SERVICE_NAME"
      done
    read SERVICE_ID_SELECTED
    # select service_id from services where service_id = input
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    SERVICE_MATCH=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
    # If the input !matches service_id (in services table)
    if [[ -z $SERVICE_MATCH ]]
      then 
      MENU
      # If the input matches service_id (in services table)
      else
      echo -e "\n$SERVICE_ID_SELECTED)$SERVICE_NAME"
    fi
    # echo -e "\nEnter phone number"
    # read CUSTOMER_PHONE
    # CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$PHONE_NUMBER'")
    # if [[ -z $CUSTOMER_NAME ]]
    # then
    # # get new customer name
    # echo -e "\nWhat's your name?"
    # read CUSTOMER_NAME
    # # insert new customer
    # INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    # # When would you like to come?
    # # echo -e "\nChoose a service-time. (10:00 or 5:35pm or 11:15am)"
    
  # fi
}
MENU