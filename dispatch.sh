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

dnf list installed golang &>> $LOGFILE
if [ $? -eq 0 ]
then
    echo -e "$Y mentioned golang already installed $N"
else
    echo "package not installed yet, so proceeding with installation"
    dnf install golang -y &>> $LOGFILE
    validate $? "installing golang"
fi

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

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE
validate $? "downloading code"

cd /app/; unzip -o /tmp/dispatch.zip &>> $LOGFILE
validate $? "unzipping code"

cd /app; go mod init dispatch; go get; go build &>> $LOGFILE
validate $? "installing dependencies & build software"

cp /home/centos/roboshop-shell-script/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE
validate $? "copying dispatch service file"

systemctl daemon-reload; systemctl enable dispatch; systemctl start dispatch &>> $LOGFILE
validate $? "starting dispatch service"