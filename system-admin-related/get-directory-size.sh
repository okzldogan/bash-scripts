#!/bin/bash

MAIN_DIRECTORY=$1

cd $MAIN_DIRECTORY

# Get the subdirectories in the main directory

SUB_DIRECTORIES=$(ls -d */|sed 's/\///g')

# Get the disk usage for each directory

for DIRECTORY in $SUB_DIRECTORIES
do
    DISK_USAGE=$(du -sh $DIRECTORY)
    # If disk usage is in MB, convert it to GB
    if [[ $DISK_USAGE == *M* ]]; then
        DISK_USAGE=$(echo $DISK_USAGE | awk '{ GB = $1 / 1024 ; print GB "GB" }')
        echo $DIRECTORY, $DISK_USAGE
    else if [[ $DISK_USAGE == *G* ]]; then
        DISK_USAGE=$(echo $DISK_USAGE | awk '{ GB = $1 ; print GB }')
        echo $DIRECTORY, $DISK_USAGE
    else if [[ $DISK_USAGE == *K* ]]; then
        DISK_USAGE=$(echo $DISK_USAGE | awk '{ GB = $1 / 1024 / 1024 ; print GB "GB" }')
        echo $DIRECTORY, $DISK_USAGE
    fi
    fi
    fi
done
