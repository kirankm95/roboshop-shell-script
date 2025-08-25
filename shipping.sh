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
        exit 1
    fi
}

if [ $ID -ne 0 ]
    then
        echo -e "$Y you are not root user, please re-try with root user $N"
        exit 1
    else
        echo -e "$G you are root user, hence proceeding $N"
fi

dnf install maven -y &>> $LOGFILE
validate $? "installing maven"

id roboshop &>> $LOGFILE
if [ $? -eq 0 ]
then
    echo "roboshop user already exist"
else
    useradd roboshop &>> $LOGFILE
    validate $? "creating roboshop user"
fi

mkdir -p /app &>> $LOGFILE
validate $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
validate $? "downloading code"

cd /app/; unzip -o /tmp/shipping.zip &>> $LOGFILE
validate $? "unzipping code"

cd /app; mvn clean package &>> $LOGFILE
validate $? "installing dependencies"

cd /app; mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
validate $? "installing dependencies"

cp /home/centos/roboshop-shell-script/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
validate $? "copying shipping service file"

systemctl daemon-reload; systemctl enable shipping; systemctl start shipping &>> $LOGFILE
validate $? "starting shipping service"

dnf list installed mysql  &>> $LOGFILE
if [ $? -eq 0 ]
then
    echo -e "$Y mentioned mysql  already installed $N"
else
    echo "package not installed yet, so proceeding with installation"
    dnf install mysql  -y &>> $LOGFILE
    validate $? "installing mysql"
fi

mysql -h mysql.kiranku.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE
validate $? "loading data to mongodb"

systemctl restart shipping &>> $LOGFILE
validate $? "restarting shipping"