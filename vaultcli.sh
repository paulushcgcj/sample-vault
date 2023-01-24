clear
source ./.env

DATA='{"yes":"no"}'

THEWRAP=$(
  curl -s -X POST $VAULT_ADDR/v1/sys/wrapping/wrap \
  -H 'x-vault-token: '"$VAULT_TOKEN"'' \
  -H 'Content-Type: application/json'\
  -H 'X-Vault-Wrap-TTL: 30m' \
  -d $DATA | jq '.wrap_info.token'|sed 's/"//g')


echo "Wrapped $DATA to $THEWRAP"

echo "#####################################################################################################"

sleep 1
vault unwrap -format "json" $THEWRAP | jq '.data'
echo "#####################################################################################################"

sleep 1
vault unwrap -format "json" $THEWRAP | jq '.data'
echo "#####################################################################################################"

