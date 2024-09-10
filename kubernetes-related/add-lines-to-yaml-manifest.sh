#!/bin/bash

# Get all the files in the current directory

ALL_FILES=$(ls)

# Set the lines to be added

LINE_TO_ADD1="\        securityContext:"
LINE_TO_ADD2="\          allowPrivilegeEscalation: false"
LINE_TO_ADD3="\          runAsNonRoot: true"
LINE_TO_ADD4="\          runAsUser: 1001"

# Run a for loop for only .yaml files

for FILE in $ALL_FILES
do
  if [[ $FILE == *.yaml ]]
  then
    echo "Adding lines to $FILE"
    # Add Lines before the line that contains the second string "terminationMessagePath"
    sed -i "/terminationMessagePath/i $LINE_TO_ADD1" $FILE
    sed -i "/terminationMessagePath/i $LINE_TO_ADD2" $FILE
    sed -i "/terminationMessagePath/i $LINE_TO_ADD3" $FILE
    sed -i "/terminationMessagePath/i $LINE_TO_ADD4" $FILE
  fi
done
