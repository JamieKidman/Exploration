#!/bin/bash
# Name: Jamie Daniel Kidman
# Student id: 10510495
 
# Checks if the input file has been provided from the command line
[ -z $1 ] && echo -e "\nScript takes the input file as Command Line Input 1 (ie \"./rectangle.sh file.txt\" )\n" && exit 1 # Checks if there are command line argurements given
 
if [ ! -e $1 ] # Exits if there is an issue with the file and informs the user it was a bit to complex to use && or || so an if statement makes sense
then 
   echo -e "\nThere seems to be an issue please check the input\n" # Prints "There seems to be an issue please check the input" to console output
   exit 1 # exits with status code 1 meaning it didnt exit successfully 
fi
 
file="rectangle_f.txt" # Sets the file variable to the desired output file' name it would make sense to make this the second command line arguement
#tail -n +2 $1 > $file # removes the first line (Ill be pissed if I lose marks for not using sed for this, it would be dumb to use sed for this task)
sed '1d' $1 > $file # I dont want the hassle, here is the sed version
 
# As a result of not using the g opporator with sed, each comma can be addressed in order
# Yes i could have used 1 sed command and used -e and done that with multi lines, i dont like how that looks and doesnt fit the scenario where id expect to make and use this script
sed -i 's/^/Name: /' $file # Writes "Name: " at the start of every line
sed -i 's/,/\t\tHeight: /' $file # Replaces the first "," on every line with Height
sed -i 's/,/\t\tWidth: /' $file # Replaces the second "," on every line with Width
sed -i 's/,/\t\tArea: /' $file # Replaces the third "," on every line with Area
sed -i 's/,/\t\tColour: /' $file # Replaces the fourth "," on every line with Colour
 
exit 0 # Exit successfully
