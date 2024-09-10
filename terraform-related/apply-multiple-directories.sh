#!/bin/bash

# List all directories with changes in the current root directory

# Get the current directory
MAIN_DIR=$(pwd)

# Get the file paths with changes based on git diff
DIRECTORIES=$(git diff --name-only)

# Get the full directory names from the file paths removing the current current directory

DIRECTORIES=$(echo "$DIRECTORIES" | sed 's/infra\///g' | sed 's/\/main.tf//g'|sort -u|grep -v "apply"|grep -v "modules")


echo $DIRECTORIES

# Run terraform init, plan and apply for each directory
for folder in $DIRECTORIES; do 
    echo "------------------------"
    cd $MAIN_DIR
    echo "Moving to Folder $folder"
    cd $folder
    echo "Running terraform init from the folder $folder"

    terraform init
    # Wait for terraform init to complete
    if [ $? -eq 0 ]; then
        echo "Terraform init completed successfully"
        echo "Running terraform plan in the folder $folder"

        terraform plan|grep -v "state"
        # Wait for terraform plan to complete
        if [ $? -eq 0 ]; then
            echo "Terraform plan completed successfully"
            
            # Ask for user input to continue or not
            echo "--------------"

            read -p "Do you want to continue with the apply? Type in (yes/no) " answer
            if [ "$answer" == "yes" ]; then
                echo "Running terraform apply"

                terraform apply -auto-approve
                # Wait for terraform apply to complete
                if [ $? -eq 0 ]; then
                    echo "Terraform apply completed successfully"
                else
                    echo "Terraform apply failed"
                    exit 1
                fi
            else
                echo "Skipping terraform apply"
            fi


        else
            echo "Terraform plan failed"
            exit 1
        fi

    else
        echo "Terraform init failed"
        exit 1
    fi

done
    