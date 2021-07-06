#!/bin/sh

CSV_FILE_PATH="${1}"
SENDINBLUE_LIST_ID="${2}"
SENDINBLUE_API_KEY="${3}"

csv_file_to_json_payload() {
    echo '
        {
            "listIds": [
                '"${SENDINBLUE_LIST_ID}"'
            ],
            "emailBlacklist": false,
            "smsBlacklist": false,
            "updateExistingContacts": true,
            "emptyContactsAttributes": false,
            "fileBody": ' > input.json
    cat "${CSV_FILE_PATH}" | sed 's/,/;/g' | jq -Rras . >> input.json
    echo '
        }
' >> input.json
}

if [ -n "${CSV_FILE_PATH}" ] && [ -n "${SENDINBLUE_LIST_ID}" ]; then
    if [ -f "${CSV_FILE_PATH}" ]; then
        csv_file_to_json_payload
        curl \
	          -s \
	          --request POST \
	          --url https://api.sendinblue.com/v3/contacts/import \
	          --header "Accept: application/json" \
	          --header "Content-Type: application/json" \
	          --header "api-key: ${SENDINBLUE_API_KEY}" \
	          --data @input.json
    else
        echo "Please provide a valid CSV input file."
        exit 24;
    fi
else
    echo "usage: ${0} <contacts_file> <list_id> <api_key>"
    exit 23;
fi
