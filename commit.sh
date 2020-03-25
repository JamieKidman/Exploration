#!/bin/bash
# Modified by: Aiden Sehovic

# This a bash script for handling staging, making commits and pushing to git.

# Checks if current repository is a git reposition, if it is not then repository is intialized.

file=./.git
if [ ! -e "$file" ]; then
   git init
fi

# Files are staged and that the status of those files is logged to the terminal.

echo "Stage all files where you have made a change."
git add .

echo "The current status of your branch is:"
git status

# The user is prompted to write their commit message.

echo "If satisfied with your code write your commit below. Pressing enter with confirm your commit. Make sure you are certain!"
read -p "" desc
git commit -m "$desc"

# Asks user if they want to push their commit.
echo "Below is the output from git remote -v, if fatal, there is no remote press ctr-c and add remote. Please wait for server request if there is a delay."
git ls-remote
read -n1 -p "Do you want to push to master? " doit

case $doit in
  y|Y) git push origin master ;;
  n|N) echo " Exiting " exit ;;
  *) echo "dont know" ;;
esac

echo "Done"
exit 0
