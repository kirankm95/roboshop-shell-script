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
        
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
validate $? "enabling mongodb repo from rpm"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
validate $? "enabling redis6.2" 

dnf list installed redis &>> $LOGFILE
if [ $? -eq 0 ]
then
    echo -e "$Y mentioned redis already installed $N"
else
    echo "package not installed yet, so proceeding with installation"
    dnf install redis -y &>> $LOGFILE
    validate $? "installing redis"
fi

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE
validate $? "allowing remote access"

systemctl enable redis; systemctl start redis &>> $LOGFILE
validate $? "starting redis"