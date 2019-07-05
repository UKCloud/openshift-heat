#!/bin/bash
# Quick script to retrieve the Pingdom list of EU monitoring IPs and format it for environment.yaml
# Output can be appended to the end of environment.yaml:
#   ./get_pingdom_ips.sh >> environment.yaml
IPLIST=`curl https://help.pingdom.com/hc/en-us/article_attachments/360003037257/EU_IP_list.txt | grep -v ":"`
LAST=`echo $IPLIST | awk '{ print $NF }'`

echo ""
echo -n "  monitoring_allowed_sources: [ "
for IP in $IPLIST; do
    echo -n "\"${IP}/32\""
    if [ $IP != "$LAST" ]; then
        echo -n ", "
    else
        echo -n " "
    fi
done
echo ']'
