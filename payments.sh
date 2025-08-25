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

dnf install python36 gcc python3-devel -y
validate $? "installing python"

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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
validate $? "downloading code"

cd /app/; unzip -o /tmp/payment.zip &>> $LOGFILE
validate $? "unzipping code"

cd /app; pip3.6 install -r requirements.txt &>> $LOGFILE
validate $? "installing dependencies"

cp /home/centos/roboshop-shell-script/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
validate $? "copying payment service file"

systemctl daemon-reload; systemctl enable payment; systemctl start payment &>> $LOGFILE
validate $? "starting payment service"