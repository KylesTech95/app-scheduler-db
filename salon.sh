#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
# echo $($PSQL "truncate appointments,customers;alter sequence customers_customer_id_seq restart with 1;alter sequence appointments_appointment_id_seq restart with 1;")
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
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE

      
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
          then
          echo -e "\nWhat is your name?"
          read CUSTOMER_NAME
          ISNERT_INTO_CUSTOMERS=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
          CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
          echo -e "\n$CUSTOMER_NAME, when would you like to come for your$SERVICE_NAME? (format: 10:00 10:30pm 10:30am)"
          read SERVICE_TIME
          INSERT_APP=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
          else
          echo -e "\n$CUSTOMER_NAME, when would you like to come for your$SERVICE_NAME? (format: 10:00 10:30pm 10:30am)"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
          INSERT_APP=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        fi
    fi
    
}
MENU