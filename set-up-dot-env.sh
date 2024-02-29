#!/bin/bash

set -e

# this script prepares certs for local development and experimentation
# using mkcert (https://github.com/FiloSottile/mkcert), and sets up the
# environment accordingly in .env

# No argument on the command line will create an RSA cert, the default;
# the argument '-ecdsa' will create an ECDSA cert.

if ! ([ "$1" = "" ] || [ "$1" = "-ecdsa" ]) ; then
    echo "Bad argument: must be -ecdsa or empty"
    exit 1
fi

rm -f cert.pem key.pem fullchain.pem

mkcert $1 -cert-file cert.pem -key-file key.pem example.org

cp cert.pem fullchain.pem

CAROOT=$(mkcert -CAROOT)

cat "$CAROOT/rootCA.pem" >> fullchain.pem

CERT_ROOTS=`openssl x509 -noout -in "$CAROOT"/rootCA.pem -fingerprint -sha256 | cut -f 2 -d '=' | sed 's/://g' | awk '{print tolower($0)}'`

cat <<EOF > .env
DOMAIN=example.org
CERTFILE=fullchain.pem
KEYFILE=key.pem
CERT_ROOTS=$CERT_ROOTS
EOF
