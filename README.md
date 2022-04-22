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

