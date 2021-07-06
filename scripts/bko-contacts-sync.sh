#!/bin/sh

TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"

# external config:
#  AWS_COGNITO_POOL_ID
#  SENDINBLUE_LIST_ID
#  SENDINBLUE_API_KEY

usage() {
    echo "usage: $0"
    echo ""
    echo "Please configure these environment variables:"
    echo "  - AWS_COGNITO_POOL_ID"
    echo "  - SENDINBLUE_LIST_ID"
    echo "  - SENDINBLUE_API_KEY"
}

if [ -n "${AWS_COGNITO_POOL_ID}" ] && \
       [ -n "${SENDINBLUE_LIST_ID}" ] && \
       [ -n "${SENDINBLUE_API_KEY}" ]; then

    echo "Synchronizing contacts from Cognito to SendInBlue..." && \
        ( echo "Deleting previous exports for pool ${AWS_COGNITO_POOL_ID}..." && \
	            (rm -fv "${AWS_COGNITO_POOL_ID}".json || true) && \
	            (rm -fv "${AWS_COGNITO_POOL_ID}"_*.csv || true) && \
	            (rm -fv "${AWS_COGNITO_POOL_ID}"_*.import.pid || true) && \
	            echo " > done" ) && \
        ( echo "Exporting contacts from ${AWS_COGNITO_POOL_ID} to JSON..." && \
	            ./bko-cognito-export-users.sh && \
	            echo " > done (${AWS_COGNITO_POOL_ID}.json)" ) && \
        ( echo "Converting JSON export to CSV export..." && \
	            ./bko-cognito-transform-json-to-csv.sh "${AWS_COGNITO_POOL_ID}.json" > "${AWS_COGNITO_POOL_ID}_${TIMESTAMP}.csv" && \
	            echo " > done (${AWS_COGNITO_POOL_ID}_${TIMESTAMP}.csv)") && \
        ( echo "Importing/Updating contacts in SendInBlue (${AWS_COGNITO_POOL_ID}_${TIMESTAMP}.csv)..." && \
	            ./sendinblue-importcontacts.sh "${AWS_COGNITO_POOL_ID}_${TIMESTAMP}.csv" "${SENDINBLUE_LIST_ID}" "${SENDINBLUE_API_KEY}" &&
              cat output.json | jq -r '.processId' > "${AWS_COGNITO_POOL_ID}_${TIMESTAMP}.import.pid"  && \
	            echo " > done (${AWS_COGNITO_POOL_ID}_${TIMESTAMP}.import.pid)") && \
        ( echo "Waiting a few seconds for processing..." && \
	            sleep 10 && \
	            echo " > done") && \
        ( echo "Checking process status ($(cat "${AWS_COGNITO_POOL_ID}_${TIMESTAMP}.import.pid"))..." && \
	            [ "$(./sendinblue-getprocessstatus.sh "$(cat "${AWS_COGNITO_POOL_ID}_${TIMESTAMP}.import.pid")" "${SENDINBLUE_API_KEY}")" = "completed" ] && \
	            echo " > completed") && \
        echo "Synchronization completed successfully."
else
    usage;
    exit 45;
fi
