#!/bin/bash

regex='refs/heads/(.*)'
[[ "$BRANCH" =~ $regex ]]
SIMPLE_BRANCH=${BASH_REMATCH[1]}
echo "Will post result: {\"project\":\"fat_free_crm\",\"branch\":\"$SIMPLE_BRANCH\",\"sha\":\"$SHA\",\"status\":\"$STATUS\"}"

curl -H "Content-Type: application/json" -H "X-API-Key: $YELLR_KEY" -X POST $YELLR_URL -d "{\"project\":\"fat_free_crm\",\"branch\":\"$SIMPLE_BRANCH\",\"sha\":\"$SHA\",\"status\":\"$STATUS\"}"