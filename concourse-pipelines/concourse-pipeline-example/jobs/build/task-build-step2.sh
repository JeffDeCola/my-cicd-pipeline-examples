#!/bin/sh
# task-build-step2.sh

echo "WELCOME TO TASK BUILD STEP 2"
echo " "

pwd
ls -lat .
echo " "

echo "ADD TO DATE AND TIME FILE my-artifacts/todays-date.txt"
printf "Hello from Task Build Step 2\n" >> my-artifacts/todays-date.txt
date "+%a, %b %d, %Y - %I:%M%p" >> my-artifacts/todays-date.txt
cat my-artifacts/todays-date.txt
echo " "

echo "COPY my-go-tests-private-update TO my-go-tests-private-push"
cp -rT my-go-tests-private-update my-go-tests-private-push
echo " "

echo "Copy my-artifacts/message TO my-go-tests-private-push/."
echo "Will create if it doesn't exist"
cat my-artifacts/todays-date.txt >> my-go-tests-private-push/todays-date.txt
echo " "

# CONFIGURE GIT
echo "Update some global git variables"
echo "git config --global user.email \"jeffdecola@gmail.com\""
echo "git config --global user.name \"Jeff DeCola (Concourse)\""
git config --global user.email "jeffdecola@gmail.com"
git config --global user.name "Jeff DeCola (Concourse)"
#echo "git config --list"
#git config --list
echo " "

echo "cd my-go-tests-private-push"
cd my-go-tests-private-push || exit
ls -lat .
echo " "

echo "git status"
git status
echo " "

# GIT ADD AND COMMIT
echo "git add ."
git add .
echo "git commit -m \"Added todays date from concourse ci\""
git commit -m "Added todays date from concourse ci"
echo " "

echo "END OF TASK BUILD STEP 2"
