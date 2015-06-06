#!/bin/bash


function check {
if [ $1 -ne 0 ]; then
     echo $2
     exit 1
fi
}

function power_on {
    echo 1 > /sys/devices/virtual/gpio/gpio17/value
    check $? "Could not power on"
}

function power_off {
    echo 0 > /sys/devices/virtual/gpio/gpio17/value
    check $? "Could not power off"
}

function open_action {
    echo 1 > /sys/devices/virtual/gpio/gpio22/value
    check $? "Could not open"
    sleep 0.2
    echo 0 > /sys/devices/virtual/gpio/gpio22/value
}

function close_action {
    echo 1 > /sys/devices/virtual/gpio/gpio24/value
    check $? "Could not close"
    sleep 0.2
    echo 0 > /sys/devices/virtual/gpio/gpio24/value
}

function change {
    echo 1 > /sys/devices/virtual/gpio/gpio23/value
    check $? "Could not change"
    sleep 0.2
    echo 0 > /sys/devices/virtual/gpio/gpio23/value
}


# check number of arguments
if [ $# -ne 2 ]; then
    echo "Invalid number of arguments. Usage:"
    echo "   <open/close> <Nr of change>"
    exit 1
fi

# check if argument 1 is open/or close
if [[ "$1" != "open" && "$1" != "close" ]]; then
    echo "Argument 1 is not open or close"
    exit 1
fi

# check if argument 2 is a number
re='^[0-9]+$'
if ! [[ $2 =~ $re ]]; then
   echo "Argument 2 is not a Number"
   exit 1
fi


# execute the required actions
power_off

sleep 1

power_on

sleep 15

for (( c=0; c<$2; c++ ))
do
   change
   sleep 1.5
done

if [[ "$1" == "open" ]]; then
    open_action
elif [[ "$1" == "close" ]]; then
    close_action
fi

sleep 5
