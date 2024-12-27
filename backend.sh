#!/bin/bash

source ./common.sh

check_root

echo "Please enter DB Password::"
read -s mysql_root_password

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling default NodeJS"

dnf module enable  nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS:20 version"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE
    VALIDATE $? "creating expense user"
else
    echo -e "expense user already exists.....$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading Content for Backend"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Unzip backend code"

npm install &>>$LOG_FILE
VALIDATE $? "Downloading noejs dependencies"

cp /home/ec2-user/expense-shell-1/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE $? "copied backend.service to /etc/systemd/system"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOG_FILE
VALIDATE $? "Starting  Backend"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enabling  Backend service"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Client"

mysql -h db.surya-devops.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "Loading backend.sql schema"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarting Backend service"







