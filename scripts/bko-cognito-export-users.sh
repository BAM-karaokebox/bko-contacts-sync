#!/bin/sh

usage() {
    echo "usage: $0"
    echo ""
    echo "Please configure these environment variables:"
    echo "  - AWS_ACCESS_KEY"
    echo "  - AWS_SECRET_KEY"
    echo "  - AWS_PROFILE (if not providing keys as variables)"
    echo "  - AWS_REGION"
    echo "  - AWS_COGNITO_POOL_ID"
}

if cbr --help> /dev/null 2>&1; then
    CBR_EXEC="cbr"
else
    CBR_EXEC="npx cbr"
fi

if [ -n "${AWS_PROFILE}" ]; then
    ${CBR_EXEC} \
        backup \
        --profile "${AWS_PROFILE}" \
        --region "${AWS_REGION}" \
        --userpool "${AWS_COGNITO_POOL_ID}" \
        --directory .
else
    if [ -n "${AWS_ACCESS_KEY}" ] && \
           [ -n "${AWS_SECRET_KEY}" ] && \
           [ -n "${AWS_REGION}" ] && \
           [ -n "${AWS_COGNITO_POOL_ID}" ]; then
        ${CBR_EXEC} \
            backup \
            --aws-access-key "${AWS_ACCESS_KEY}" \
            --aws-secret-key "${AWS_SECRET_KEY}" \
            --region "${AWS_REGION}" \
            --userpool "${AWS_COGNITO_POOL_ID}" \
            --directory .
    else
        usage
        exit 23
    fi
fi
