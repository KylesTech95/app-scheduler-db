#! /bin/bash
PSQL="psql --username=postgres --dbname=salon --tuples-only -c "
#clear tables & reset sequence
# echo $($PSQL "truncate appointments,customers;alter sequence customers_customer_id_seq restart with 1;alter sequence appointments_appointment_id_seq restart with 1;")
# insert data
ENTER_DATA(){
  #instantiate customer-phone
  CUSTOMER_PHONE=$1
  #instantiate service-name
  SERVICE_ID_SELECTED=$2
  #instantiate customer-name
  CUSTOMER_NAME=$3
  #instantiate service-time
  #retrieve service name
  SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  SERVICE_TIME=$4
  #instantiate customer_id
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE' and name='$CUSTOMER_NAME'")
  #if cutomer is not found in the database
  if [[ -z $CUSTOMER_ID ]]
    then
    #insert into customers
      INSERT_CUSTOMER=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    #instantiate customer_id
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE' and name='$CUSTOMER_NAME'")
    #insert into appointments
      INSERT_APPOINTMENT=$($PSQL "insert into appointments(service_id,customer_id,time) values($SERVICE_ID_SELECTED,$CUSTOMER_ID,'$SERVICE_TIME')")
      if [[ $INSERT_CUSTOMER == 'INSERT 0 1' ]]
      then
        # echo -e "\nName: $CUSTOMER_NAME\nPhone: $CUSTOMER_PHONE\nService: $SERVICE_NAME\nAppointed-time: $SERVICE_TIME"
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
}
# enter phone number
ENTER_PHONE(){
  SERVICE_ID_SELECTED=$1
  # List of phones
  PHONES_PROGRAMMED=$($PSQL "select phone from customers")
  echo -e "\nWhat is your phone number? (1234567890 or 12343452345)."
  sleep 1
  read CUSTOMER_PHONE
  PHONE_MATCHES=$($PSQL "select phone from customers where phone='$CUSTOMER_PHONE'")
    if [[ ! $CUSTOMER_PHONE =~ ^[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]]
        then
        echo -e "\nEnter a valid phone number"
        sleep 1
        ENTER_PHONE
        else
        # If phone is already programmed
        if [[ -z $PHONE_MATCHES ]]
          then
          ENTER_NAME $CUSTOMER_PHONE $SERVICE_ID_SELECTED
          else
          # "\nThis number is already in our database./nEnter another number"
          echo -e "\nThis number is already in our database./nEnter another phone number."
          sleep 1
          ENTER_PHONE
          fi
      fi

    
}
# Enter Name
ENTER_NAME(){
  #instantiate customer-phone
  CUSTOMER_PHONE=$1
  #instantiate service-name
  SERVICE_ID_SELECTED=$2
  # What is your name?
    echo -e "\nWhat is your name?"
    sleep 1
      read CUSTOMER_NAME
      if [[ ! $CUSTOMER_NAME =~ ^[a-zA-Z]+$ ]]
        then
          # PLACE YOUR STATEMENT
          ENTER_NAME
        else
          ENTER_SERVICE_TIME  $CUSTOMER_PHONE $SERVICE_ID_SELECTED $CUSTOMER_NAME
      fi
}
ENTER_SERVICE_TIME(){
  #instantiate customer-phone
  CUSTOMER_PHONE=$1
  #instantiate service-name
  SERVICE_ID_SELECTED=$2
  #instantiate customer-name
  CUSTOMER_NAME=$3

  # When would you like to come? (format: 1:35 or 12:30)?
    echo -e "\nWhen would you like to come? (format: 1:35 or 12:30)?"
    sleep 1
      read SERVICE_TIME
      if [[ ! $SERVICE_TIME =~ ^([0-9])?[0-9]:[0-9]{2}$ ]]
        then
          # PLACE YOUR STATEMENT
          ENTER_SERVICE_TIME
        else
          echo -e "\nYour service time is $SERVICE_TIME"
          sleep 1
          ENTER_DATA $CUSTOMER_PHONE $SERVICE_ID_SELECTED $CUSTOMER_NAME $SERVICE_TIME
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
      CUSTOMER_INFORMATION $SERVICE_ID_SELECTED
    fi
  
}
#What is the customer's information (serviceName)
CUSTOMER_INFORMATION(){
  SERVICE_ID_SELECTED=$1
  ENTER_PHONE $SERVICE_ID_SELECTED
}

WELCOME