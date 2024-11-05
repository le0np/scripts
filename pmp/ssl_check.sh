#!/usr/bin/bash
host=$1

# Use curl to get SSL certificate details and extract relevant lines only
curl --insecure -v https://$host 2>&1 | awk '
    /^\*  subject:/ { print $0 }
    /^\*  issuer:/ { print $0 }
    /^\*  SSL certificate verify ok\./ { print $0; print ""; exit }
'
