#!/bin/bash


start_time=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD


# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf install mysql-server -y  &>>$LOG_FILE
VALIDATE $? "installing mysql"

systemctl enable mysqld  &>>$LOG_FILE
VALIDATE $? "enabling mysql"


systemctl start mysqld   &>>$LOG_FILE
VALIDATE $? "starrting mysql"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting MySQL root password"


end_time=$(date +%s)

total_time=$((end_time - start_time))
echo  -e "Total execution time:   Y $total_time seconds" $N | tee -a &>>$LOG_FILE