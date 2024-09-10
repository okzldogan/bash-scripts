# List all directories with changes in the current directory in last 60 minutes

#!/bin/bash

# Get the file paths in which changes have been made in last 60 minutes

DIRECTORIES=$(find . -type f -mmin -60 | sed 's/^\.\///g' | sed 's/\/[^\/]*$//g' | sort | uniq)


echo "Directories with changes in last 60 minutes:"
echo $DIRECTORIES