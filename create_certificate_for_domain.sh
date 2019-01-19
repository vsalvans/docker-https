#!/usr/bin/env bash

if [ -z "$1" ]
then
  echo "Please supply a subdomain to create a certificate for"
  echo "e.g. www.mysite.com"
  return 1
fi

if [ ! -f certs/rootCA.pem ]; then
  echo 'Please run "create_root_cert_and_key.sh" first, and try again!'
  return 1
fi
if [ ! -f v3.ext ]; then
  echo 'Please download the "v3.ext" file and try again!'
  return 1
fi

rm -f "certs/$DOMAIN.csr"
rm -f "certs/$DOMAIN.crt"
rm -f "certs/$DOMAIN.key"

# Create a new private key if one doesnt exist, or use the xeisting one if it does
if [ -f certs/device.key ]; then
  KEY_OPT="-key"
else
  KEY_OPT="-keyout"
fi

DOMAIN=$1
COMMON_NAME=${2:-*.$1}
SUBJECT="/C=CA/ST=None/L=NB/O=None/CN=$COMMON_NAME"
NUM_OF_DAYS=999
openssl req -new -newkey rsa:2048 -sha256 -nodes $KEY_OPT certs/device.key -subj "$SUBJECT" -out certs/device.csr
cat v3.ext | sed s/%%DOMAIN%%/"$COMMON_NAME"/g > /tmp/__v3.ext
echo "Using the following v3.ext file:\n"
cat /tmp/__v3.ext
openssl x509 -req -in certs/device.csr -CA certs/rootCA.pem -CAkey certs/rootCA.key -CAcreateserial -out certs/device.crt -days $NUM_OF_DAYS -sha256 -extfile /tmp/__v3.ext 

# move output files to final filenames
mv certs/device.csr "certs/$DOMAIN.csr"
cp certs/device.crt "certs/$DOMAIN.crt"
cp certs/device.key "certs/$DOMAIN.key"

# remove temp file
rm -f certs/device.crt;

echo 
echo "###########################################################################"
echo Done! 
echo "###########################################################################"
echo "To use these files on your server, simply copy both $DOMAIN.csr and"
echo "device.key to your webserver, and use like so (if Apache, for example)"
echo 
echo "    SSLCertificateFile    /path_to_your_files/$DOMAIN.crt"
echo "    SSLCertificateKeyFile /path_to_your_files/$DOMAIN.key"
