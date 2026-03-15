#!/bin/bash
scriptfile=$(realpath "$0")
workdir="$(dirname "$scriptfile")"

cd "$workdir"

source .env

ldapsearch -x -H ldap://ldap.oa.internal:389 -D "${ldap_bind_dn}" -w "${ldap_bind_pw}" -b "CN=oa-internal,CN=AIA,CN=Public Key Services,CN=Services,CN=Configuration,DC=oa,DC=internal" -s base "(objectClass=certificationAuthority)" cACertificate