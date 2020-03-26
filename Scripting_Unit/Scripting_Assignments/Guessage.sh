#!/bin/bash

# Name: Jamie Daniel Kidman 
# Student id: 10510495

# Generates an number between 20 & 70 inclusive and returns that number
gen_age()
{
    x=0
    while [ $x -le 20 ] # Loops if the number is lower than 20
    do
        x=$((RANDOM%70)) # Modulo rules mean the number will always be between 0-70
    done
    return $x
}

gen_age
age=$?

input=0 # initailised the input to 0 which isn't within 20-70 (min_age and max_age) as that could cause issues.
while [ $input -ne $age ]
do
    read -p 'Enter Guess: ' input

    if [ $input -eq $age ]; then
    echo "Correct"
    fi

    if [ $input -gt $age ]; then
    echo "The age is lower"
    fi

    if [ $input -lt $age ]; then
    echo "The age is higher"
    fi

done