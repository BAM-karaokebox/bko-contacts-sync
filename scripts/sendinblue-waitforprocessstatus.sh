#!/bin/sh

SENDINBLUE_PROCESS_ID="${1}"
SENDINBLUE_API_KEY="${2}"


STATUS="in_process"
while [ "${STATUS}" = "in_process" ]; do
    echo "... waiting for process ${SENDINBLUE_PROCESS_ID} (${STATUS})"
    sleep 10
    STATUS="$(./sendinblue-getprocessstatus.sh "${SENDINBLUE_PROCESS_ID}" "${SENDINBLUE_API_KEY}")"
done

[ "${STATUS}" = "completed" ]
