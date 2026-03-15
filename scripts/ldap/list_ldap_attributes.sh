#!/bin/bash
scriptfile=$(realpath "$0")
workdir="$(dirname "$scriptfile")"

source "${workdir}/.env"

# search for user
ldapsearch -x -LLL -H ldap://192.168.2.36:389 -D "${ldap_bind_dn}" -w "${ldap_bind_pw}" -b "dc=oa,dc=internal" "(sAMAccountName=${1})"


# search for schema entry
#1. ldapsearch -x -LLL -H ldap://192.168.2.36:389 -D "${ldap_bind_dn}" -w "${ldap_bind_pw}" -s base -b "" subschemasubentry
#2. ldapsearch -x -LLL -H ldap://192.168.2.36:389 -D "${ldap_bind_dn}" -w "${ldap_bind_pw}" -b "CN=Aggregate,CN=Schema,CN=Configuration,DC=oa,DC=internal" "(objectClass=*)" objectClasses


# search all contexts (base)
#ldapsearch -x -LLL -H ldap://192.168.2.36:389 -D "${ldap_bind_dn}" -w "${ldap_bind_pw}" -s base -b ""


# find all objects of specific object class
#ldapsearch -x -LLL -H ldap://192.168.2.36:389 -D "${ldap_bind_dn}" -w "${ldap_bind_pw}" -E pr=1000/noprompt -b "dc=oa,dc=internal" "(objectClass=${1})"
