#!/bin/sh
# task-test-step1.sh

echo "WELCOME TO TASK TEST STEP 1"
echo " "

pwd
ls -lat .
echo " "

echo "cd my-go-tests-private-resource"
cd my-go-tests-private-resource || exit
ls -lat .
echo " "

cat todays-date.txt
echo " "

echo "END OF TASK TEST STEP 1"
