#!/bin/bash

: HEADER = <<'EOL'
██████╗  ██████╗  ██████╗██╗  ██╗███████╗████████╗███╗   ███╗ █████╗ ███╗   ██╗
██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝╚══██╔══╝████╗ ████║██╔══██╗████╗  ██║
██████╔╝██║   ██║██║     █████╔╝ █████╗     ██║   ██╔████╔██║███████║██╔██╗ ██║
██╔══██╗██║   ██║██║     ██╔═██╗ ██╔══╝     ██║   ██║╚██╔╝██║██╔══██║██║╚██╗██║
██║  ██║╚██████╔╝╚██████╗██║  ██╗███████╗   ██║   ██║ ╚═╝ ██║██║  ██║██║ ╚████║
╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
       Name: Upload Jamf Logs
Description: Uploads useful Jamf logs to the computer's inventory record in Jamf.
 Created By: Chris Schasse
 Parameters: $1-$3 - Reserved by Jamf (Mount Point, Computer Name, Username)
                $4 - API Authentication (Base64 encoded '[username]:[password]')
                      
  Created By: Chris Schasse
     Version: 1.0
     License: Copyright (c) 2022, Rocketman Management LLC. All rights reserved. Distributed under MIT License.
   More Info: For Documentation, Instructions and Latest Version, visit https://www.rocketman.tech/jamf-toolkit
   
EOL

##
## Defining Variables
##

APIHASH="$4" # Base64 encoded string of API credentials in "USER:PASSWORD" format

##
## Main Script Functions
##

## System variables
osMajor=$(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') # Major OS Version
osMinor=$(/usr/bin/sw_vers -productVersion | awk -F . '{print $2}') # Minor OS Version
serialnumber=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}') # Computer's Serial Number
APIURL=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url) # Jamf Pro URL

## Basic API Call that's getting information for the computer.
computerXML=$(curl -s -H "Authorization: Basic ${APIHASH}" -H "accept: text/xml" ${APIURL}JSSResource/computers/serialnumber/${serialnumber} -X GET)

## Depending on the OS version, xpath requires the -e flag
if [[ "${osMajor}" -ge 11 ]]; then
  opt='-e'
fi

## Get the ID of the computer
id=$(echo ${computerXML} | xpath ${opt} "//computer/general/id/text()")

curl -s -H "Authorization: Basic ${APIHASH}" -H "accept: text/xml" ${APIURL}JSSResource/fileuploads/computers/id/${id} -F name=@/var/log/jamf.log -X POST
curl -s -H "Authorization: Basic ${APIHASH}" -H "accept: text/xml" ${APIURL}JSSResource/fileuploads/computers/id/${id} -F name=@/var/log/install.log -X POST
curl -s -H "Authorization: Basic ${APIHASH}" -H "accept: text/xml" ${APIURL}JSSResource/fileuploads/computers/id/${id} -F name=@/var/log/system.log -X POST
