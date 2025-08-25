#!/bin/bash
ID=$(id -u)
TIME=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIME.log"
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

echo -e "this script started executing at ${TIME}" &>> $LOGFILE

validate(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is $G success $N"
    else
        echo -e "$2 is $R failed $N"
    fi
}

if [ $ID -ne 0 ]
    then
        echo -e "$Y you are not root user, please re-try with root user $N"
        exit 1
    else
        echo -e "$G you are root user, hence proceeding $N"
fi
        
dnf module disable mysql -y &>> $LOGFILE
validate $? "disable mysql default version"

cp /home/centos/roboshop-shell-script/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
validate $? "setting-up mysql repo"

dnf list installed mysql-community-server &>> $LOGFILE
if [ $? -eq 0 ]
then
    echo -e "$Y mentioned mysql already installed $N"
else
    echo "package not installed yet, so proceeding with installation"
    dnf install mysql-community-server -y &>> $LOGFILE
    validate $? "installing mysql-community-server"
fi

systemctl enable mysqld &>> $LOGFILE
validate $? "enabling mysqld"

systemctl start mysqld &>> $LOGFILE
validate $? "starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
validate $? "set password"

mysql -uroot -pRoboShop@1 &>> $LOGFILE
validate $? "test user connection"