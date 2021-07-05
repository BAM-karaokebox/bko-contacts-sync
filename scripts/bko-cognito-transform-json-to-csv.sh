#!/bin/sh

FILE="${1}"
MODE="${2:-full}"


if [ "${MODE}" = "full" ]; then
    echo "Email,NOM,PRENOM,BKO_USERNAME,BKO_COGNITO_ID,BKO_STRIPE_ID,BKO_LAST_MODIFIED_DATE,BKO_CREATION_DATE,BKO_EMAIL_VERIFIED,BKO_USER_STATUS,BKO_ENABLED,BKO_FREE_TRIAL_END,Last_changed,Date_added"
    cat "${FILE}" \
        | jq --raw-output '.[] | [(.Attributes[] | select(.Name == "email")).Value // "", (.Attributes[] | select(.Name == "custom:lastname")).Value // "", (.Attributes[] | select(.Name == "custom:firstname")).Value // "", .Username, (.Attributes[] | select(.Name == "sub")).Value // "", (.Attributes[] | select(.Name == "custom:stripeId")).Value // "", (.UserLastModifiedDate | sub(".[0-9]+Z$"; "Z") | fromdate | strftime("%d-%m-%Y")), (.UserCreateDate | sub(".[0-9]+Z$"; "Z") | fromdate | strftime("%d-%m-%Y")), (((.Attributes[] | select(.Name == "email_verified")).Value // "") | if . == "true" then . = "Yes" else . = "No" end), (.UserStatus), (.Enabled | if . == true then . = "Yes" else . = "No" end), (.Attributes[] | ((select(.Name == "custom:freeTrialEnd")).Value | sub("[.:][0-9]+Z$"; ":00Z") | fromdate | strftime("%d-%m-%Y"))) // "", "", "" ] | @csv'
else
    echo "BKO_USERNAME,BKO_COGNITO_ID,BKO_STRIPE_ID,BKO_CREATION_DATE,BKO_EMAIL_VERIFIED,BKO_USER_STATUS,BKO_ENABLED,BKO_FREE_TRIAL_END"
    cat "${FILE}" \
        | jq --raw-output '.[] | [.Username, (.Attributes[] | select(.Name == "sub")).Value // "", (.Attributes[] | select(.Name == "custom:stripeId")).Value // "", (.UserCreateDate | sub(".[0-9]+Z$"; "Z") | fromdate | strftime("%d-%m-%Y")), (((.Attributes[] | select(.Name == "email_verified")).Value // "") | if . == "true" then . = "Yes" else . = "No" end), (.UserStatus), (.Enabled | if . == true then . = "Yes" else . = "No" end), (.Attributes[] | select(.Name == "custom:freeTrialEnd")).Value // "" ] | @csv'
fi
