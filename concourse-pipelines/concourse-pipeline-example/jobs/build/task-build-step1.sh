#!/bin/sh
# task-build-step1.sh

echo "WELCOME TO TASK BUILD STEP 1"
echo " "

pwd
ls -lat .
echo " "

echo "CREATE DATE AND TIME FILE my-artifacts/todays-date.txt"
printf "Hello from Task Build Step 1\n" >> my-artifacts/todays-date.txt
date "+%a, %b %d, %Y - %I:%M%p" >> my-artifacts/todays-date.txt
cat my-artifacts/todays-date.txt
echo " "

echo "COPY my-cicd-pipeline-examples-resource TO my-cicd-pipeline-examples-update"
cp -rT my-cicd-pipeline-examples-resource my-cicd-pipeline-examples-update
echo " "

echo "cd my-cicd-pipeline-examples-update"
cd my-cicd-pipeline-examples-update || exit
ls -lat .
echo " "

echo "END OF TASK BUILD STEP 1"
