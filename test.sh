#!/usr/bin/env bash

clear
source ./.env

TEMP_FILE=$(mktemp)

cat ./vault-config-intention.json | jq ".event.url=\"$GITHUB_SERVER_URL$GITHUB_ACTION_PATH\" | \
            .user.id=\"$GITHUB_ACTOR\" \
        " > $TEMP_FILE

cat $TEMP_FILE

RESPONSE=$(curl -s -X POST $BROKER_URL/v1/intention/open \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $BROKER_JWT" \
    -d @$TEMP_FILE \
    )

echo "$BROKER_URL/v1/intention/open"

#echo $RESPONSE

INTENTION_TOKEN=$(echo $RESPONSE | jq -r '.token')
echo "INTENTION_TOKEN=$INTENTION_TOKEN"

ACTION_TOKEN=$(echo $RESPONSE | jq -r '.actions.provision.token')
echo "ACTION_TOKEN=$ACTION_TOKEN"

# Get wrapped id for db access
VAULT_TOKEN_WRAP=$(curl -s -X POST $BROKER_URL/v1/provision/approle/secret-id -H 'x-broker-token: '"$ACTION_TOKEN"'' -H 'x-vault-role-id: '"$PROVISION_ROLE_ID"'')
echo $BROKER_URL/v1/provision/approle/secret-id
echo "VAULT_TOKEN_WRAP=$VAULT_TOKEN_WRAP"
#WRAPPED_VAULT_TOKEN=$(echo $VAULT_TOKEN_WRAP | jq -r '.wrap_info.token')

#UNWRAPPED_VAULT_TOKEN=$(curl -s -X POST $VAULT_ADDR/v1/sys/wrapping/unwrap -H 'X-Vault-Token: '"$WRAPPED_VAULT_TOKEN"'')

#VAULT_TOKEN=$(echo -n $UNWRAPPED_VAULT_TOKEN | jq -r '.auth.client_token')
#echo "VAULT_TOKEN=$UNWRAPPED_VAULT_TOKEN" >> $ENV_VAULT_TOKEN


CLOSE_RESPONSE=$(curl -s -X POST $BROKER_URL/v1/intention/close \
    -H 'Content-Type: application/json' \
    -H "x-broker-token: $INTENTION_TOKEN" \    
    )

echo "$BROKER_URL/v1/intention/close"
echo $CLOSE_RESPONSE