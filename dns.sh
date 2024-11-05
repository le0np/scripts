#!/usr/bin/bash

# This script uses the dig command to retrieve DNS records for a specified domain, displaying NS, A, MX, CNAME, TXT, SOA and CAA records. 
# It outputs each record type in a concise format, showing TTL (time-to-live), record type, and value, mimicking a traditional DNS zone file layout.

host=$1

# NS record
/usr/bin/dig $host NS +noall +answer

# A record
/usr/bin/dig $host A +noall +answer

# MX record
/usr/bin/dig $host MX +noall +answer

# CNAME record
/usr/bin/dig $host CNAME +noall +answer

# TXT record
/usr/bin/dig $host TXT +noall +answer

# SOA record
/usr/bin/dig $host SOA +noall +answer

# CAA record
/usr/bin/dig $host CAA +noall +answer
