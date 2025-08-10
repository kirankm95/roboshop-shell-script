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

dnf install nginx -y &>> $LOGFILE
validate $? "installing ngx"

systemctl enable nginx &>> $LOGFILE
validate $? "enabling ngx"

systemctl start nginx &>> $LOGFILE
validate $? "starting ngx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
validate $? "removing default content of ngx"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
validate $? "downloading code of ngx"

unzip /tmp/web.zip /usr/share/nginx/html/ &>> $LOGFILE
validate $? "unzipping code of ngx"

cp /home/centos/roboshop-shell-script/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
validate $? "copying code of ngx"

systemctl restart nginx &>> $LOGFILE
validate $? "restarting service for ngx"