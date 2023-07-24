#!/bin/bash 

# Create domains.txt and paste a list of domains, one per line/row.
# Once done, you can run  the script to only get the domain and registrar name printed out
   
for domain in $(cat domains.txt); do
    echo "Domain Name: $domain"
    whois $domain | awk -F ':' '/Registrar:/ {print "Registrar: " $2}' | head -n 1
    echo "--------------------------"
done

