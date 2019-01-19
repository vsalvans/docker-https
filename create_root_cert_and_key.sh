#!/usr/bin/env bash
rm -f certs/*.key
rm -f certs/*.pem
openssl genrsa -out certs/rootCA.key 2048
openssl req -x509 -new -nodes -key certs/rootCA.key -sha256 -days 1024 -out certs/rootCA.pem
