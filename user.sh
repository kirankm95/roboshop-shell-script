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

dnf module disable nodejs -y &>> $LOGFILE
validate $? "disabling nodejs default version"

dnf module enable nodejs:18 -y &>> $LOGFILE
validate $? "enabling nodejs 18 version"

dnf install nodejs -y &>> $LOGFILE
validate $? "installing nodejs 18 version"

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

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
validate $? "downloading code"

cd /app/; unzip -o /tmp/user.zip &>> $LOGFILE
validate $? "unzipping code"

cd /app; npm install &>> $LOGFILE
validate $? "installing dependencies"

cp /home/centos/roboshop-shell-script/user.service /etc/systemd/system/user.service &>> $LOGFILE
validate $? "copying user service file"

systemctl daemon-reload; systemctl enable user; systemctl start user &>> $LOGFILE
validate $? "starting user service"

cp /home/centos/roboshop-shell-script/mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
validate $? "settingup mongdb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
validate $? "installing mongodb client"

mongo --host mongodb.kiranku.online </app/schema/user.js &>> $LOGFILE
validate $? "loading data to mongodb"



