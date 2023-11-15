#!/bin/bash

# Set the log file path
log_file="newlog"

# Extract and count IP addresses and SQL-related GET requests from the log file
ip_counts_and_sql=$(grep GET "$log_file" | awk '$7 ~ /(union|select|from|where|information_schema|sleep)/ {print $1, $7}' | sort | uniq -c | sort -rh | head -20)

# Extract and count IP addresses and all POST requests from the log file
ip_counts_and_post=$(grep POST "$log_file" | awk '{print $1, $7}' | sort | uniq -c | sort -rh | head -20)

# Extract and count IP addresses and POST requests with potential SQL injection
ip_counts_and_post2=$(grep POST "$log_file" | awk 'tolower($7) ~ /(union|select|from|where|information_schema|sleep)/ {print $1, $7}' | sort | uniq -c | sort -rh | head -20)

# Process and display SQL-related GET requests with counts
echo -e "\nGET REQUESTS WITH POSSIBLE SQL INJECTION:" 
while read -r count ip sql_request; do
    # Resolve the hostname from the IP
    hostname=$(dig +short -x "$ip")
    if [ -n "$hostname" ]; then
        # If hostname is found, display count, resolved hostname, and SQL request
        echo "$count $hostname $sql_request"
    else
        # If hostname is not found, display count, original IP, and SQL request
        echo "$count $ip $sql_request"
    fi
done <<< "$ip_counts_and_sql"

# Process and display all POST requests with counts
echo -e "\nPOST REQUESTS:" 
while read -r count ip sql_request; do
    # Resolve the hostname from the IP
    hostname=$(dig +short -x "$ip")
    if [ -n "$hostname" ]; then
        # If hostname is found, display count, resolved hostname, and POST request
        echo "$count $hostname $sql_request"
    else
        # If hostname is not found, display count, original IP, and POST request
        echo "$count $ip $sql_request"
    fi
done <<< "$ip_counts_and_post"

# Process and display POST requests with potential SQL injection
echo -e "\nPOST REQUESTS WITH POTENTIAL SQL INJECTION:"
while read -r count ip sql_request; do
    # Resolve the hostname from the IP
    hostname=$(dig +short -x "$ip")
    if [ -n "$hostname" ]; then
        # If hostname is found, display count, resolved hostname, and POST request
        echo "$count $hostname $sql_request"
    else
        # If hostname is not found, display count, original IP, and POST request
        echo "$count $ip $sql_request"
    fi
done <<< "$ip_counts_and_post2"

