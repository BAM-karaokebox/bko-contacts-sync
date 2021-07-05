#!/bin/sh

CSV_FILE_PATH="${1}"
SENDINBLUE_LIST_ID="${2}"
SENDINBLUE_API_KEY="${3}"

if [ -n "${CSV_FILE_PATH}" ] && [ -n "${SENDINBLUE_LIST_ID}" ]; then
    if [ -f "${CSV_FILE_PATH}" ]; then
        CSV_FILE_CONTENT="$(cat "${CSV_FILE_PATH}" | sed 's/,/;/g' | jq -Rras .)"

        curl \
	          -s \
	          --request POST \
	          --url https://api.sendinblue.com/v3/contacts/import \
	          --header "Accept: application/json" \
	          --header "Content-Type: application/json" \
	          --header "api-key: ${SENDINBLUE_API_KEY}" \
	          --data '
{
  "listIds": [
    '"${SENDINBLUE_LIST_ID}"'
  ],
  "emailBlacklist": false,
  "smsBlacklist": false,
  "updateExistingContacts": true,
  "emptyContactsAttributes": false,
  "fileBody": '"${CSV_FILE_CONTENT}"'
}
';
    else
        echo "Please provide a valid CSV input file."
        exit 24;
    fi
else
    echo "usage: ${0} <contacts_file> <list_id> <api_key>"
    exit 23;
fi
