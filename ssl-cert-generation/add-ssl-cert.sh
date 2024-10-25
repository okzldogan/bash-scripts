#!/bin/bash


# ./add-ssl-cert.sh ENV no my-domain.com
# ./add-ssl-cert.sh prod www my-domain.com


# Generate SSL certificate using acme.sh

ENVIRONMENT=$1
SUBDOMAIN=$2
DOMAIN_NAME=$3

# Set the path to the acme.sh script

export ACME_PATH=~/path/to/acme.sh

# Change directory to where the acme.sh script is located

cd $ACME_PATH

# Run the issue domain command to start the DNS challenge
# If SUBDOMAIN is equal to "no" then set the ISSUE_DOMAIN to the domain name, else set the ISSUE_DOMAIN to the subdomain and domain name

if [ $SUBDOMAIN == "no" ]; then
    export ISSUE_DOMAIN=$(./acme.sh --issue --dns -d "$DOMAIN_NAME" --yes-I-know-dns-manual-mode-enough-go-ahead-please)
    # Add "_acme-challenge." before the subdomain and domain name
    export DNS_RECORD_NAME=$(echo _acme-challenge.$DOMAIN_NAME)
else
    export ISSUE_DOMAIN=$(./acme.sh --issue --dns -d "$SUBDOMAIN.$DOMAIN_NAME" --yes-I-know-dns-manual-mode-enough-go-ahead-please)
    # Add "_acme-challenge." before the subdomain and domain name
    export DNS_RECORD_NAME=$(echo _acme-challenge.$SUBDOMAIN.$DOMAIN_NAME)
fi


# ISSUE_DOMAIN contains the TXT record that needs to be added to the DNS record in a line, 
# where you find the 'TXT value: ' string get the next string after it, while removing all the rest after the contained string

export TXT_RECORD=$(echo $ISSUE_DOMAIN | sed 's/.*TXT value: //g')

# Remove all the values after the first string in TXT_RECORD

export TXT_RECORD=$(echo $TXT_RECORD | sed 's/ .*//g')

# Remove the first character and last character in TXT_RECORD ( This is the remove quotes)

export TXT_RECORD=$(echo $TXT_RECORD | sed 's/^.//g' | sed 's/.$//g')

# Re-set the DOMAIN_NAME as ZONE_NAME by changing the '.' to '-''

export ZONE_NAME=$(echo $DOMAIN_NAME | sed 's/\./-/g')
# export ZONE_NAME=carbonsink-it-new


echo "Making the TXT type DNS Record"


# Make the TXT type DNS Record

gcloud dns record-sets create "$DNS_RECORD_NAME." \
    --zone=$ZONE_NAME \
    --project=southpole-dns \
    --ttl=60 \
    --type=TXT \
    --rrdatas=$TXT_RECORD

echo "DNS entry made. Waiting for the DNS record to propagate"

# Wait for the DNS record to propagate

sleep 10

# Launch the renew domain command to get the certificate
# if SUBDOMAIN is equal to "no" then set the RENEW_DOMAIN to the domain name, else set the RENEW_DOMAIN to the subdomain and domain name

if [ $SUBDOMAIN == "no" ]; then
    export RENEW_DOMAIN=$(./acme.sh --renew --dns -d "$DOMAIN_NAME" --yes-I-know-dns-manual-mode-enough-go-ahead-please)
else
    export RENEW_DOMAIN=$(./acme.sh --renew --dns -d "$SUBDOMAIN.$DOMAIN_NAME" --yes-I-know-dns-manual-mode-enough-go-ahead-please)
fi

# Wait until the RENEW_DOMAIN command completes execution

if [ $? -eq 0 ]; then
    # If the RENEW_DOMAIN returns lines that contains .cer and .key files, then the certificate has been generated,
    if [[ $RENEW_DOMAIN == *".cer"* && $RENEW_DOMAIN == *".key"* ]]; then
        echo "Certificate generation successful, changing directory to convert .cer and .key files to .pem files"
        if [ $SUBDOMAIN == "no" ]; then
            cd $ACME_PATH/certificates/$DOMAIN_NAME\_ecc
        else
            cd $ACME_PATH/certificates/$SUBDOMAIN.$DOMAIN_NAME\_ecc
        fi
    else
        echo "Certificate generation failed .cer and .key files not found"
    fi
else
    echo "Certificate generation failed."
fi

# Convert .cer file to .pem file using openssl

if [ $SUBDOMAIN == "no" ]; then
    openssl x509 -in $DOMAIN_NAME.cer -out $ZONE_NAME.pem -outform PEM
else
    openssl x509 -in $SUBDOMAIN.$DOMAIN_NAME.cer -out $SUBDOMAIN-$ZONE_NAME.pem -outform PEM
fi

# Convert ec .key file to .pem file using openssl

if [ $SUBDOMAIN == "no" ]; then
    openssl ec -in $DOMAIN_NAME.key -out $ZONE_NAME-private-key.pem
else
    openssl ec -in $SUBDOMAIN.$DOMAIN_NAME.key -out $SUBDOMAIN-private-key.pem
fi


if [ $ENVIRONMENT == "exception" ]; then
    export PROJECT_NAME=exception
else
    export PROJECT_NAME=gke-$ENVIRONMENT
fi

# Run gcloud compute ssl-certificates create command

if [ $SUBDOMAIN == "no" ]; then
    gcloud compute ssl-certificates create $ZONE_NAME-cert \
    --certificate=$ZONE_NAME.pem \
    --private-key=$ZONE_NAME-private-key.pem \
    --global \
    --project=$PROJECT_NAME
else
    gcloud compute ssl-certificates create $SUBDOMAIN-$ZONE_NAME-cert \
    --certificate=$SUBDOMAIN-$ZONE_NAME.pem \
    --private-key=$SUBDOMAIN-private-key.pem \
    --global \
    --project=$PROJECT_NAME
fi
