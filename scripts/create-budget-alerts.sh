#!/usr/bin/env bash
set -euo pipefail

EMAIL="${1:-${BUDGET_EMAIL:-}}"
BUDGET_AMOUNT="${BUDGET_AMOUNT:-5}"
BUDGET_NAME="${BUDGET_NAME:-webdyne-fortune-demo-monthly}"
AWS="${AWS:-aws}"

if [[ -z "$EMAIL" ]]; then
    echo "usage: $0 email@example.com" >&2
    echo "or set BUDGET_EMAIL=email@example.com" >&2
    exit 2
fi

account_id="$($AWS sts get-caller-identity --query Account --output text)"
budget_file="$(mktemp)"
notifications_file="$(mktemp)"

cleanup() {
    rm -f "$budget_file" "$notifications_file"
}
trap cleanup EXIT

cat > "$budget_file" <<JSON
{
  "BudgetName": "${BUDGET_NAME}",
  "BudgetLimit": {
    "Amount": "${BUDGET_AMOUNT}",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "CostTypes": {
    "IncludeTax": true,
    "IncludeSubscription": true,
    "UseBlended": false,
    "IncludeRefund": false,
    "IncludeCredit": false,
    "IncludeUpfront": true,
    "IncludeRecurring": true,
    "IncludeOtherSubscription": true,
    "IncludeSupport": true,
    "IncludeDiscount": true,
    "UseAmortized": false
  }
}
JSON

cat > "$notifications_file" <<JSON
[
  {
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 50,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [
      {
        "SubscriptionType": "EMAIL",
        "Address": "${EMAIL}"
      }
    ]
  },
  {
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [
      {
        "SubscriptionType": "EMAIL",
        "Address": "${EMAIL}"
      }
    ]
  },
  {
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 100,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [
      {
        "SubscriptionType": "EMAIL",
        "Address": "${EMAIL}"
      }
    ]
  },
  {
    "Notification": {
      "NotificationType": "FORECASTED",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [
      {
        "SubscriptionType": "EMAIL",
        "Address": "${EMAIL}"
      }
    ]
  }
]
JSON

if $AWS budgets describe-budget \
    --account-id "$account_id" \
    --budget-name "$BUDGET_NAME" >/dev/null 2>&1; then
    $AWS budgets update-budget \
        --account-id "$account_id" \
        --new-budget "file://${budget_file}" >/dev/null
    echo "Updated budget ${BUDGET_NAME} at \$${BUDGET_AMOUNT}/month."
    echo "Existing notifications were left unchanged."
else
    $AWS budgets create-budget \
        --account-id "$account_id" \
        --budget "file://${budget_file}" \
        --notifications-with-subscribers "file://${notifications_file}" >/dev/null
    echo "Created budget ${BUDGET_NAME} at \$${BUDGET_AMOUNT}/month."
    echo "Alerts will be sent to ${EMAIL}."
fi
