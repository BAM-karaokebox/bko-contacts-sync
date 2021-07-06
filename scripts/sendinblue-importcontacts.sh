#!/bin/sh

CSV_FILE_PATH="${1}"
SENDINBLUE_LIST_ID="${2}"
SENDINBLUE_API_KEY="${3}"

# there are simpler ways to do this, but we get a segmentation fault
# in jq on GitHub actions, so we build this gradually.
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
            "fileBody": _PLACEHOLDER_
         }' > payload.template.json
    cat "${CSV_FILE_PATH}" | sed 's/,/;/g' > data.csv
    cat data.csv | jq --stream -Rr '. | @json' | \
        sed -e 's/^"//' -e 's/"$//' | sed '1s/^/"/' | sed '$s/$/"/' > payload.data.json
    sed -e "/_PLACEHOLDER_/r payload.data.json" \
        -e "s///" payload.template.json \
        > payload.json
}

if [ -n "${CSV_FILE_PATH}" ] && [ -n "${SENDINBLUE_LIST_ID}" ]; then
    if [ -f "${CSV_FILE_PATH}" ]; then
        csv_file_to_json_payload
        curl \
	          -s \
            -o output.json \
	          --request POST \
	          --url https://api.sendinblue.com/v3/contacts/import \
	          --header "Accept: application/json" \
	          --header "Content-Type: application/json" \
	          --header "api-key: ${SENDINBLUE_API_KEY}" \
	          --data @payload.json
    else
        echo "Please provide a valid CSV input file."
        exit 24;
    fi
else
    echo "usage: ${0} <contacts_file> <list_id> <api_key>"
    exit 23;
fi
