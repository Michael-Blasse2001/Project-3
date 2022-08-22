#!/bin/bash

#title: Build Script 3-Multifunction Script

#Description: A script that handles the various situations described by the
# Build script 3 outline:
#-Create a new user and place them in the group GitAcc
#-Handles adding and committing changes to a repo
#-Will check a file for sensitive information before pushing it to the main repo
#Author: Michael Blase

#Date: 8/18/2022- August 18th 2022

#Version: 0.1

#Usage: To satisfy to the scenarios of Build-Script 3

#Inorder for the script to relocate to a valid repo it must be run like this
#. Buildscript3.sh
#===============================================================#
emailFormat="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}"

phoneNoFormat="\+[0-9]+\s\([0-9]{3}+\)+\s[0-9]{3}+-[0-9]{4}|\([0-9]{3}+\)+\s[0-9]{3}+-[0-9]{4}|[0-9]{3}+-[0-9]{4}|[0-9]{7}"

sSN="[0-9]{3}+\-[0-9]{2}+\-[0-9]{4}|[0-9]{9}|[0-9]{3}+\s[0-9]{2}+\s[0-9]{3}"

printf "Welcome user what can I 'do' 'for' you today?\n"

PS3="Please 'Select' Your operation: "
printf "\n "
operations=("Create User" "Add '&' Commit files" "File checker" "Exit")
select opt in "${operations[@]}"
 do
case $opt in
    "Create User")
   echo -e "\nCreate User Selected"
break
;;
    "Add '&' Commit files")
   echo -e "\nChecking for repo...\n"
break
;;
    "File checker")
    echo -e "\nAcknowledged"
break
;;
    "Exit")
    echo -e "Exiting..."
    exit 0
;;
    *)
    echo "Unknown response"
;;
esac
done

case $opt in
    "Create User")
while true 
  do
   read -p "Please specify a username: " userName
  if [ -z "$userName"  ]
      then
     echo "This user name is blank. Please enter desired username"
     else
     echo -e "\nCreating user...\n"
       if [ $(getent group GitAcc) ] 
       then
         echo -e "Group exists.\n"
         sudo useradd -s "/bin/bash" -d "/home/$userName/" -m -G "GitAcc" $userName
        else
        echo -e "Group GitAcc does not exist. Creating group...\n"
         sudo groupadd "GitAcc"
         sudo useradd -s "/bin/bash" -d "/home/$userName/" -m -G "GitAcc" $userName
        fi
       displayUser=$(getent passwd | grep $userName)
       UsersGroup=$(groups $userName)
     echo "User has been created:"
     echo "$displayUser"
     echo -e "$UsersGroup\n"
     break
  fi
done
;;
    "Add '&' Commit files")
while true; do
   if (ls -a | grep -E '^(.git)$') 
    then 
   echo -e "\nRepo Found\n"
    git branch
   read -p "Are we in your working branch?(y/n): " branchAnswer
   break
  else 
  echo -e "\nChecking for repo...\n"
 read -p "Seems this isn't a git repository? Please specify your git respository location:" repoLocation
    cd $repoLocation
   echo -e "\nYou are here\n" &&  pwd
fi
done
case $branchAnswer in
    "y")
  echo -e "Acknowledged\n"
;;
   "n")
while true; do
   read -p "Please type the branch name: " branchName
   git switch $branchName
  check=$(git branch | grep -c -E '^* $branchName')
   if [ $check = 0 ]
    then
    echo -e "\nBranch Found\n"
    break
    else
    echo $check
    echo $branchName
    echo -e "\nBranch Not Found\n"
  fi
done
;;
esac
read -p "What file would you like to commit changes to?" fileName
ls
git add $fileName 
read -p "Type note here: " commitNote
git commit -m "$commitNote" && echo "Commit complete"
;;
    "File checker")
while true; do
    read -p "Please specify which file(path if necessary) you'd like to be checked: " checkFile
if (find $checkFile); then
emailVar=$(grep -E -o $emailFormat $checkFile)

phoneVar=$(grep -E -o $phoneNoFormat $checkFile)

SSNvar=$(grep -E -o $sSN $checkFile)

if [ -z "$SSNvar" -a -z "$phoneVar" -a -z "$emailVar" ] ; then
  echo "File is clear."
  read -p "Would you like to push this file(y/n) to the remote repo?: " checkAnswer
case $checkAnswer in
     "y")
       echo "Acknowledged"
      if ( ! ls -a | grep -E '^(.git)$' )
    then
    echo "Repo not found. Please run program in a local git hub repository"
 else
    echo -e "Repo found. \nPushing to remote repo..."
    git push origin main
  fi
     ;;
      "n") 
       echo "Exiting..."
      exit 0
      ;;
esac
else
echo -e "File contains sensitive info\n"
  if [[ ! -z "$SSNvar" ]] ; then
echo -e "Possible match(es) for (a) social security number(s): \n$SSNvar\n"
  fi
  if [[ ! -z "$phoneVar" ]] ; then
   echo -e "Possible match(es) for phone number(s): \n$phoneVar\n"
  fi
  if [[ ! -z "$emailVar" ]] ; then
   echo -e "Possible email match(es) found: \n$emailVar\n"
  fi

fi

break
fi
done
;;
esac

exit 0
