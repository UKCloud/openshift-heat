#!/usr/bin/env python3
"""
Script to retrieve list of EU pingdom servers

xmltodict neeeds to be installed with pip3
 pip3 install xmltodict


Predeployment, output is in the correct format to do:
 ./get_pingdom_ips.py >> environment.yaml
"""

import xmltodict
import requests

pingdomrss = requests.get('https://my.pingdom.com/probes/feed')

datadict = xmltodict.parse(pingdomrss.text)

print("  monitoring_allowed_sources: [", end=" ")
first = True

for probe in datadict['rss']['channel']['item']:
    if probe['pingdom:region'] == "EU":
        if first == True:
            print('\"' + probe['pingdom:ip'] + '/32\"', end="")
            first = False
        else:
            print(", ", end="")
            print('\"' + probe['pingdom:ip'] + '/32\"', end="")
print(" ]")



