#!/bin/sh

SENDINBLUE_API_KEY="${1}"

curl \
    -s \
    --request GET \
    --url "https://api.sendinblue.com/v3/processes?limit=10&offset=0&sort=desc" \
    --header "Accept: application/json" \
    --header "api-key: ${SENDINBLUE_API_KEY}"
