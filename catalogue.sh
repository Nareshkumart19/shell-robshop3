#!/bin/bash

check_rootaccess
nodejs
app_name=catalogue

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop    
    VALIDATE $? "creating roboshop system user"
else 
    echo -e "system user roboshop alraedy cretaed .... $Y skipping $N"
fi    
mkdir -p /app 
VALIDATE $? "careating app  directory"


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "Dowlinding catalouge "

rm -rf /app/*
cd /app 

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unziping catlouge"

npm install &>>$LOG_FILE
VALIDATE $?  "installing dependies"


cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copy the calalogue service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue  &>>$LOG_FILE
systemctl start catalogue
VALIDATE $? "starting catalogue"


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing Mongodb client"


#$mongosh --host mongodb.daws84s.space </app/db/master-data.js &>>$LOG_FILE
#VALIDATE $? "loding data into mongdb"

STATUS=$(mongosh --host mongodb.daws84s.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.daws84s.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi