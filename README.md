# Upload Jamf Pro Logs

## Background
When troubleshooting a client-side issue, it can be helpful to collect logs without needing to physically handle the computer in question. This script performs the action of uploading important logs to the computer's inventory record in Jamf Pro, saving the potential hassle of collecting them manually.

## How It Works
This workflow is deployed through a policy, either in Self Service or another trigger. There is no effect on the Mac unless User Interaction is configured. When executed, the script uses a Jamf Pro account with least required permissions and a randomized password to authorize the data upload.

## Parameters
- Parameter 4: This string will be used in an API call to file upload the logs at the end
  - Label: API Basic Authentication
  - Type: String (must be a base64 hash)
  - Requirements: API User with the following permissions
      - Computers - Create | Read | Update
      - File Attachments - Create | Read | Update
  - Instructions: Generate a hash with a command like: echo -n 'jamfapi:Jamf1234' | base64 | pbcopy
  
## Deployment Instructions
- Add the Upload-Jamf-Logs.sh Script to Jamf Pro with the parameter label above
- Create a Jamf Pro User Account with the following permissions:
  - Computers - Create | Read | Update
  - File Attachments - Create | Read | Update
- Create a base64 encoded username/password string by running the following command in Terminal:
  - echo -n "USERNAME:PASSWORD" | base64 | pbcopy
- Create a Policy with the  parameter 4 set to the Base64 encoded string you created previously
  - This policy can either be deployed automatically, or made on demand through Self Service
