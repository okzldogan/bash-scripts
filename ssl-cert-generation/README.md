1. Clone the acme.sh github repo and initiate the account

git clone https://github.com/acmesh-official/acme.sh.git
cd ./acme.sh
./acme.sh --install -m my-email@my-domain.com --no-cron --no-profile --cert-home ./certificates

-m: email address for the account
--no-cron: do not install a cron job
--no-profile: do not set acme.sh path in the profile
--cert-home: path to the certificates folder

2. Initiate the DNS challenge

acme.sh --issue --dns -d '<DOMAIN>' --yes-I-know-dns-manual-mode-enough-go-ahead-please

Example:

./acme.sh --issue --dns -d 'ssl-test.my-domain.cloud'  --yes-I-know-dns-manual-mode-enough-go-ahead-please

This command will return a TXT record that needs to be added to the DNS zone of the domain. The TXT record will be in the following format:

_acme-challenge.<DOMAIN> IN TXT "<TXT RECORD>"

Example:

_acme-challenge.ssl-test.my-domain.com

TXT record: '<some-text>'

After making the TXT type DNS record, wait for a minute ( depends on the TTL of the DNS record) and then run the following command:

acme.sh --renew -d '<DOMAIN>' --yes-I-know-dns-manual-mode-enough-go-ahead-please

This command will return the path of the certificate files and files will be in the following format:

./certificates/<DOMAIN>/<DOMAIN>.cer
./certificates/<DOMAIN>/<DOMAIN>.key
./certificates/<DOMAIN>/ca.cer
./certificates/<DOMAIN>/fullchain.cer

3. Convert the .key and .cer files to PEM format by running the following commands:

openssl x509 -in <DOMAIN>.cer -out <DOMAIN>.pem -outform PEM

openssl -ec -in <DOMAIN>.key -out <DOMAIN-PRIVATE-KEY>.pem

4. Upload the certificates to Google by using the gcloud command (Before running the command make sure you have the permissions to upload SSL certificate):

gcloud compute ssl-certificates create <CERTIFICATE-NAME> \
    --certificate=<DOMAIN>.pem 
    --private-key=<DOMAIN-PRIVATE-KEY>.pem
    --project=<PROJECT-ID>
    --global

5. Check from the Google console if the certificate is uploaded successfully and verify its validity.

6. Reserve a static IP address for the ingress via Terraform.

7. Make the DNS 'A' entry with the reserved static IP address for the domain name.

8. Generate the ingress configuration yaml file with kustomize and save its output to a file:

kustomize build <path-to-kustomization-folder> > <ingress-config>.yaml

The generated ingress-config.yaml file will contain managed certificate section and a managed certificate annotation field. Comment those as in the below example, while adding the 'ingress.gcp.kubernetes.io/pre-shared-cert' annotation field and leaving the rest of the ingress configuration as it is:

# apiVersion: networking.gke.io/v1
# kind: ManagedCertificate
# metadata:
#   name: ssl-test-certificates
#   namespace: ssl-test
# spec:
#   domains:
#   - ssl-test.my-domain.com
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    ingress.gcp.kubernetes.io/pre-shared-cert: <CERTIFICATE-NAME>  <<<<<<< Add this line
    kubernetes.io/ingress.class: gce
    kubernetes.io/ingress.global-static-ip-name: ssl-cert-testing-dev-static-ip
    # networking.gke.io/managed-certificates: ssl-test-certificates    <<<<<<< Comment this line
    networking.gke.io/v1beta1.FrontendConfig: ssl-test-frontendconfig
  name: ssl-test-ingress
  namespace: ssl-test
spec:
  defaultBackend:
    service:
      name: ssl-test-service
      port:
        number: 80


9. Apply the ingress configuration yaml file and wait for 2 minutes until the ingress is up.

10. When the ingress is up, visit from the browser the domain name and check if the certificate is valid.

11. If the certificate is valid, uncomment the managed certificate section and the managed certificate annotation field in the ingress configuration yaml file and apply it again.

Now the related fields of the manifest should look like this:

apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
   name: ssl-test-certificates
   namespace: ssl-test
 spec:
   domains:
   - ssl-test.my-domain.com
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    ingress.gcp.kubernetes.io/pre-shared-cert: <CERTIFICATE-NAME>  
    kubernetes.io/ingress.class: gce
    kubernetes.io/ingress.global-static-ip-name: ssl-cert-testing-dev-static-ip
    networking.gke.io/managed-certificates: ssl-test-certificates 
    networking.gke.io/v1beta1.FrontendConfig: ssl-test-frontendconfig
  name: ssl-test-ingress
  namespace: ssl-test
spec:
  defaultBackend:
    service:
      name: ssl-test-service
      port:
        number: 80

12. Check from the Google console if the managed certificate is in provisioned state.

13. After the provisioning of the managed certificate is completed, check if the managed certificate is in "Active" state and visit the Load Balancers 
page from the GCP GUI to verify if both managed certificate and uploaded SSL certificate names are indicated in the "Details" section under the 'Certificate' Column.

14. If both SSL certificates are mounted to the ingress, then remove the 'ingress.gcp.kubernetes.io/pre-shared-cert' annotation field from the ingress configuration yaml file and apply it again.

Example for the related fields:

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    # ingress.gcp.kubernetes.io/pre-shared-cert: <CERTIFICATE-NAME>  <<<<<<< Comment or delete this line
    kubernetes.io/ingress.class: gce
    kubernetes.io/ingress.global-static-ip-name: ssl-cert-testing-dev-static-ip
    networking.gke.io/managed-certificates: ssl-test-certificates 
    networking.gke.io/v1beta1.FrontendConfig: ssl-test-frontendconfig
  name: ssl-test-ingress
  namespace: ssl-test
spec:
  defaultBackend:
    service:
      name: ssl-test-service
      port:
        number: 80

15. Check from the Google console, Load Balancer's page if the uploaded SSL is unmounted from the ingress.
Please note that upon applying the ingress configuration.yaml file where the pre-shared-cert line is commented,
it may happen that from the browser when you visit the URL, you get a 502 error temporarily for 15-20 seconds.