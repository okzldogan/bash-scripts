#!/bin/bash

# Set or pass in the variables from the command line

DESTINATION_CLOUDSQL_INSTANCE=my-destination-cloudsql-instance
SOURCE_CLOUDSQL_INSTANCE=my-source-cloudsql-instance
DESTINATION_PROJECT_ID=my-destination-project-id
SOURCE_PROJECT_ID=my-source-project-id

BUCKET_REGION=europe-west1

BUCKET_NAME=$DESTINATION_CLOUDSQL_INSTANCE-db-import-bucket

# Create the bucket in the destination project
# -p flag for the project id

gsutil mb -p $DESTINATION_PROJECT_ID -l $BUCKET_REGION gs://$BUCKET_NAME


# Set variable to contain only the databases that exists in both source and destination cloudsql instances except for 
# the default databases (information_schema, mysql, performance_schema, sys)

SOURCE_DB_NAMES=$(gcloud sql databases list --instance=$SOURCE_CLOUDSQL_INSTANCE --format="value(name)" --project=$SOURCE_PROJECT_ID | grep -v -e information_schema -e mysql -e performance_schema -e sys)
DESTINATION_DB_NAMES=$(gcloud sql databases list --instance=$DESTINATION_CLOUDSQL_INSTANCE --format="value(name)" --project=$DESTINATION_PROJECT_ID | grep -v -e information_schema -e mysql -e performance_schema -e sys)

# Iterate through values in source_db_names and check if they exist in destination_db_names. If they do, add them to a DB_NAMES variable

for DB_NAME in $SOURCE_DB_NAMES
do
    if [[ $DESTINATION_DB_NAMES =~ (^|[[:space:]])"$DB_NAME"($|[[:space:]]) ]]; then
        DB_NAMES="$DB_NAMES $DB_NAME"
    fi
done

echo "The DB names that are to be migrated are $DB_NAMES"

# Run export and import for each database in DB_NAMES

for DB_NAME in $DB_NAMES
do
    echo "Exporting $DB_NAME from $SOURCE_CLOUDSQL_INSTANCE cloudsql instance to GCS bucket $BUCKET_NAME"
    gcloud sql export sql $SOURCE_CLOUDSQL_INSTANCE gs://$BUCKET_NAME/$DB_NAME.sql.gz --database=$DB_NAME --project=$SOURCE_PROJECT_ID --offload

    # Wait until export is completed to run the import command
    if [ $? -eq 0 ]; then
        echo "$DB_NAME Export completed successfully"
        echo "Importing $DB_NAME to $DESTINATION_CLOUDSQL_INSTANCE cloudsql instance"
        gcloud sql import sql $DESTINATION_CLOUDSQL_INSTANCE gs://$BUCKET_NAME/$DB_NAME.sql.gz --database=$DB_NAME --project=$DESTINATION_PROJECT_ID

        # If import is successful, echo import completed successfully
        if [ $? -eq 0 ]; then
            echo "Import of $DB_NAME completed successfully"
        else
            echo "Import of $DB_NAME failed"
            exit 1
        fi
        
    else
        echo "Export of $DB_NAME failed"
        exit 1
    fi
done

