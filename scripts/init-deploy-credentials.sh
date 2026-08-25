#!/usr/bin/env bash
set -euo pipefail

user_name="${DEPLOY_IAM_USER:-webdyne-fortune-deployer}"
encrypted_credentials="${HOME}/.aws/webdyne-fortune-deploy-credentials.json.gpg"

if [[ -e "${encrypted_credentials}" ]]; then
    echo "Refusing to overwrite existing encrypted credentials: ${encrypted_credentials}" >&2
    exit 1
fi

mkdir -p "${HOME}/.aws"
chmod 700 "${HOME}/.aws"
umask 077

if [[ -t 0 ]]; then
    export GPG_TTY
    GPG_TTY="$(tty)"
fi

echo "Creating access key for IAM user ${user_name}" >&2
key_json="$(
    aws iam create-access-key \
        --user-name "${user_name}" \
        --query 'AccessKey.{Version:`1`,AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}' \
        --output json
)"

key_id="$(
    printf '%s' "${key_json}" |
        perl -MJSON::PP=decode_json -0777 -ne 'print decode_json($_)->{AccessKeyId}'
)"

cleanup_key() {
    if [[ -n "${key_id:-}" ]]; then
        echo "Deleting access key ${key_id} because encrypted storage was not completed" >&2
        aws iam delete-access-key --user-name "${user_name}" --access-key-id "${key_id}" || true
    fi
}
trap cleanup_key ERR INT TERM

printf '%s' "${key_json}" |
    gpg --symmetric --cipher-algo AES256 --output "${encrypted_credentials}"

trap - ERR INT TERM
chmod 600 "${encrypted_credentials}"

echo "Encrypted deploy credentials written to ${encrypted_credentials}" >&2
