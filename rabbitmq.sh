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
        
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash ; curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
validate $? "configure rabbitmq repo by script as rpm" 

dnf list installed rabbitmq-server  &>> $LOGFILE
if [ $? -eq 0 ]
then
    echo -e "$Y mentioned rabbitmq-server  already installed $N"
else
    echo "package not installed yet, so proceeding with installation"
    dnf install rabbitmq-server  -y &>> $LOGFILE
    validate $? "installing rabbitmq-server "
fi

systemctl enable rabbitmq-server; systemctl start rabbitmq-server &>> $LOGFILE
validate $? "starting rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
validate $? "create user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
validate $? "set permissions"