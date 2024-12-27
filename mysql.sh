#!/bin/bash

source ./common.sh

check_root()

echo "Please enter DB Password:: "
read -s mysql_root_password

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installation of MySQL-Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySQL-Server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting MySQL-Server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
# VALIDATE $? "Set up MySQL-Server root password"

#Below code will be useful for idempotent nature
mysql -h db.surya-devops.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOG_FILE
    VALIDATE $? "Setting up root password"
else
    echo -e "Root password for MySQL server is already set..... $Y SKIPPING $N"
fi

# # Check if root password is set
# mysql -h db.surya-devops.online -uroot -e 'SELECT user, host, authentication_string FROM mysql.user WHERE user="root";' >>$LOG_FILE 2>&1

# # Check if root password is empty (empty authentication_string means no password set)
# if [ $? -ne 0 ] || grep -q 'root.*''\s*$' $LOG_FILE; then
#     # Root password is not set or there is an issue
#     mysql_secure_installation --set-root-pass ExpenseApp@1 >>$LOG_FILE 2>&1
#     VALIDATE $? "Setting up root password"
# else
#     echo -e "Root password for MySQL server is already set..... $Y SKIPPING $N"
# fi