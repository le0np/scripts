    # Run the Plesk Let's Encrypt command for the domain and its www subdomain
    output=$(plesk bin extension --exec letsencrypt cli.php -d "$domain" -d "www.$domain" -m leon@postmarketpublishing.com --renew 2>&1)

    if [ $? -eq 0 ]; then
        # Log success
        echo "Successfully renewed certificate for $domain" | tee -a letsencrypt.log
        echo ""
    else
        # Log failure with actual error message
        echo "FAILED TO RENEW CERTIFICATE FOR $domain" | tee -a letsencrypt.log
        echo ""
        echo "Error details: $output" | tee -a letsencrypt.log
    fi
done

# Log end time
echo "Let's Encrypt renewal completed: $(date)" | tee -a letsencrypt.log
