#!/bin/bash


# Import Existing DNS Entries from GCP Cloud DNS to Terraform

# Set the environment variables
export MANAGED_ZONE=$1
export DNS_HOSTING_GCP_PROJECT_ID=$2

# List all the 'A' records in the managed zone

ALL_A_RECORDS=$(gcloud dns record-sets list --zone=$MANAGED_ZONE --project=$PROJECT_ID --filter="type=A" --format="value(name,rrdatas,ttl)")

# Run a for loop after every third space in the ALL_A_RECORDS variable to create a terraform resource for each A record

for i in $(seq 1 3 $(echo $ALL_A_RECORDS | wc -w)); do

    echo -e "####################################################" >> main.tf
    echo -e "#### $(echo $ALL_A_RECORDS | cut -d' ' -f$i) Imported DNS Entry ####" >> main.tf
    echo -e "####################################################\n" >> main.tf

    echo "# terraform import google_dns_record_set."$(echo $ALL_A_RECORDS | cut -d' ' -f$i | sed 's/.$//g' | sed 's/\./_/g')" projects/$DNS_HOSTING_GCP_PROJECT_ID/managedZones/$MANAGED_ZONE/rrsets/"$(echo $ALL_A_RECORDS | cut -d' ' -f$i)"/A" >> main.tf
    # Remove the last dot from $i and convert "." to "_"
    echo -e "resource \"google_dns_record_set\" \"$(echo $ALL_A_RECORDS | cut -d' ' -f$i | sed 's/.$//g' | sed 's/\./_/g')\" {\n" >> main.tf
    echo -e "    project = \"$DNS_HOSTING_GCP_PROJECT_ID\"\n" >> main.tf
    echo -e "    managed_zone = \"$MANAGED_ZONE\"\n" >> main.tf
    echo -e "    name = \"$(echo $ALL_A_RECORDS | cut -d' ' -f$i)\"" >> main.tf
    echo "    type = \"A\"" >> main.tf
    echo -e "    ttl = $(echo $ALL_A_RECORDS | cut -d' ' -f$((i+2)))\n" >> main.tf
    echo "    rrdatas = [\"$(echo $ALL_A_RECORDS | cut -d' ' -f$((i+1)))\"]" >> main.tf
    echo -e "}\n" >> main.tf

    # Run the terraform import command
    terraform import google_dns_record_set."$(echo $ALL_A_RECORDS | cut -d' ' -f$i | sed 's/.$//g' | sed 's/\./_/g')" projects/$DNS_HOSTING_GCP_PROJECT_ID/managedZones/$MANAGED_ZONE/rrsets/"$(echo $ALL_A_RECORDS | cut -d' ' -f$i)"/A
    # Sleep for 3 seconds to wait until the import is complete
    sleep 3
    echo "The DNS entry for $(echo $ALL_A_RECORDS | cut -d' ' -f$i) has been imported"
done



