#!/bin/bash

# 1. Generate CA key and certificate:
# Generate root CA private key
openssl genrsa -out zooDeveloperPlatformRootCA.key 4096
# Generate root CA certificate
openssl req -x509 -new -noenc -key zooDeveloperPlatformRootCA.key -sha256 -out zooDeveloperPlatformRootCA.crt -subj "/CN=ZOO Developer Platform Root CA" -days 7300


# 2. Generate wildcard key and certificate by root CA
# Generate private key for the wildcard certificate
openssl genrsa -out zooWildcard-svc.key 4096
# Create a certificate signing request (CSR) for the wildcard
openssl req -new -key zooWildcard-svc.key -out zooWildcard-svc.csr -subj "/CN=*.svc.internal"
# Create a config file for SAN (Subject Alternative Name)
cat > zooWildcard-svc.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = DNS:*.svc.internal, DNS:svc.internal
EOF

# Generate the wildcard certificate using rootCA(optional)
#openssl x509 -req -in zooWildcard-svc.csr -CA zooDeveloperPlatformRootCA.crt -CAkey zooDeveloperPlatformRootCA.key -CAcreateserial -out zooWildcard-svc.crt -days 90 -sha256 -extfile zooWildcard-svc.ext
# 2.1 Create TLS secret in k8s(optional)
#kubectl create secret tls zooWildcard-svc-tls --key zooWildcard-svc.key --cert zooWildcard-svc.crt


# 3. Generate Intermediate CA key and certificate Using the Root CA
# Generate intermediate CA private key
openssl genrsa -out zooDeveloperPlatformIntermediateCA.key 4096
# Create a certificate signing request (CSR) for the intermediate CA
openssl req -new -key zooDeveloperPlatformIntermediateCA.key -out zooDeveloperPlatformIntermediateCA.csr -subj "/CN=ZOO Developer Platform Intermediate CA"
# Create a config file for the intermediate CA
cat > zooDeveloperPlatformIntermediateCA.ext <<EOF
[v3_intermediate_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF
# Sign the intermediate CA certificate with the root CA (valid for 1 years)
openssl x509 -req -in zooDeveloperPlatformIntermediateCA.csr -CA zooDeveloperPlatformRootCA.crt -CAkey zooDeveloperPlatformRootCA.key -CAcreateserial -out zooDeveloperPlatformIntermediateCA.crt -days 365 -sha256 -extfile zooDeveloperPlatformIntermediateCA.ext -extensions v3_intermediate_ca


# 4. Generate Service Certificates Using the Intermediate CA
# Generate the service certificate signed by the intermediate CA (valid for 1 year)
openssl x509 -req -in zooWildcard-svc.csr -CA zooDeveloperPlatformIntermediateCA.crt -CAkey zooDeveloperPlatformIntermediateCA.key -CAcreateserial -out zooWildcard-svc.crt -days 90 -sha256 -extfile zooWildcard-svc.ext
# Create Certificate Chain
cat zooWildcard-svc.crt zooDeveloperPlatformIntermediateCA.crt > zooWildcard-svc-chain.crt
# 4.1 Create TLS secret in k8s
#kubectl create secret tls zooWildcard-svc-tls --key zooWildcard-svc.key --cert zooWildcard-svc-chain.crt
