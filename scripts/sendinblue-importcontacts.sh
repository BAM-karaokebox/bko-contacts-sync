#!/bin/sh

CSV_FILE_PATH="${1}"
SENDINBLUE_LIST_ID="${2}"
SENDINBLUE_API_KEY="${3}"

# there are simpler ways to do this, but we get a segmentation fault
# in jq on GitHub actions, so we build this gradually.
csv_file_to_json_payload() {
    # transform csv to tsv
    cat "${CSV_FILE_PATH}" | sed 's/,/;/g' > data.csv

    # transform to JSON data field
    # ensure correct escaping for JSON for each TSV line (with jq)
    # then remove trailing/leading " added by JQ on each line
    # then regroup all lines with awk using literal newlines
    jq --stream -R '.' data.csv         \
	| sed -e 's/^"//' -e 's/"$//'   \
	| awk '{printf "%s\\n", $0}' > payload.data.json

    # inject data into payload template
    cat payload.template.json | \
	sed 's/__LIST_ID__/'"${SENDINBLUE_LIST_ID}"'/' | \
	awk 'BEGIN{getline l < "payload.data.json"}/__DATA__/{gsub("__DATA__",l)}1' \
	    > payload.json
}

if [ -n "${CSV_FILE_PATH}" ] && [ -n "${SENDINBLUE_LIST_ID}" ]; then
    if [ -f "${CSV_FILE_PATH}" ]; then
        csv_file_to_json_payload
        curl                                                            \
                  -s                                                    \
                  -o output.json                                        \
                  --request POST                                        \
                  --url https://api.sendinblue.com/v3/contacts/import   \
                  --header "Accept: application/json"                   \
                  --header "Content-Type: application/json"             \
                  --header "api-key: ${SENDINBLUE_API_KEY}"             \
                  --data @payload.json
    else
        echo "Please provide a valid CSV input file."
        exit 24;
    fi
else
    echo "usage: ${0} <contacts_file> <list_id> <api_key>"
    exit 23;
fi
