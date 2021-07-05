#!/bin/sh

SENDINBLUE_PROCESS_ID="${1}"
SENDINBLUE_API_KEY="${2}"

get_process_status() {
    curl \
        -s \
        --request GET \
        --url "https://api.sendinblue.com/v3/processes/${SENDINBLUE_PROCESS_ID}" \
        --header "Accept: application/json" \
        --header "api-key: ${SENDINBLUE_API_KEY}"
}

get_process_status | jq -r ".status"
