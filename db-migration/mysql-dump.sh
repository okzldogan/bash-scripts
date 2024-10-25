#!/bin/bash

DB_BACKUP_USER=o_kizildogan
SOURCE_BACKUP_USER_PASSWORD=
SOURCE_DB_HOST=<SOURCE_DB_IP>
env=staging

            # Source DB:Destination DB
DB_MAPPING=( "my_source_db1:my_targetdb1_$env" "my_source_db2:my_targetdb2_$env" "my_source_db3:my_targetdb3_$env")

DESTINATION_DB_PASSWORD=
DESTINATION_DB_HOST=<DESTINATION_DB_IP>



for mapping in "${DB_MAPPING[@]}"
do
    echo "Creating backup for ${mapping%%:*} db"
    CREATE_DUMP=$(mysqldump -u $DB_BACKUP_USER -p$SOURCE_BACKUP_USER_PASSWORD -h $SOURCE_DB_HOST ${mapping%%:*} > ${mapping%%:*}-$env-backup.sql)
    if [ $? -eq 0 ] && [ -s ${mapping%%:*}-$env-backup.sql ]; then
        echo "Backup for ${mapping%%:*} created successfully"
        echo "Inserting data to destination db ${mapping##*:}"
        mysql -u $DB_BACKUP_USER -p$DESTINATION_DB_PASSWORD -h $DESTINATION_DB_HOST ${mapping##*:} < ${mapping%%:*}-$env-backup.sql
        if [ $? -eq 0 ]; then
            echo "Data inserted successfully"
        else
            echo "Data insertion failed"
        fi
    else
        echo "Backup failed"
    fi
done
