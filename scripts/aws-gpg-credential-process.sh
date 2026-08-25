#!/usr/bin/env bash
set -euo pipefail

encrypted_credentials="${HOME}/.aws/webdyne-fortune-deploy-credentials.json.gpg"

if [[ ! -f "${encrypted_credentials}" ]]; then
    echo "Missing encrypted AWS credentials: ${encrypted_credentials}" >&2
    exit 1
fi

exec gpg --quiet --decrypt "${encrypted_credentials}"
