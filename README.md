# bko-contacts-sync
Cognito to SendInBlue Contacts Automation

## Description

This repository contains scripts used by our organization to automatically sync our userbase from an AWS Cognito userpool to our SendInBlue CRM system, and to perform periodic exports.

Feel free to check it out and reuse for your own usage.

## Usage

The scripts require a number of environment variables to be defined to run properly.
Please refer to the scripts' comments.


## Maintenance

We need to periodically check the following conditions:

 * This repository is updated (to prevent GitHub Actions from switchig off).
 * The drive data storage is cleared (to prevent the allocated drive storage for the service account storing exports to reach the quota limits).
 
 ### GitHub Action Update
 
 Unfortunately, there's no other choice than to regularly do a commit to add a timestamp somewhere to extend the activity period.
 We could do something like our bam-upptime repository and auto-commit to our own repository, to prevent having to do this.
 
 ### Drive Data Storage
 
As we use a Google Cloud Platform service account for storage, this account has its own drive data storage, but no Google Drive UI we can access.
The Drive storage needs to be maintained through the API. To this effect, we can use a script to regularly delete obsolete reports and only keep one monthly report (e.g. the first of each month).

Something like this, although far from perfect, does the trick:

```
# extract the list user reports that have been exported
# and hosted to the GCP service account's drive
gdrive list -m 20000 --service-account "${SERVICE_ACCOUNT_KEYFILE}" > bko-users-reports-20000.lst

# extract from that list of service accounts the file IDs of all
# reports we want to purge for a given month (except for the 1st one):
cat bko-users-reports-20000.lst
  | grep -i 202205
  | awk -F' ' '{print $1, $2}'
  | sort -k2 -t ' '
  | tail --lines=+2
  | cut -f 1 -d' '
  | while read FILE_ID; do
      gdrive delete --service-account "${SERVICE_ACCOUNT_KEYFILE}" "${FILE_ID}" ;
    done
```

