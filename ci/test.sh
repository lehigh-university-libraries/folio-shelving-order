#!/usr/bin/env bash

docker build -t fso:latest .
docker run --rm -d --name fso -p 8080:8080 fso:latest
sleep 10

declare -A tests=(
  ["792.0944+T374+v.1"]="3792.0944 T374 V 11"
  ["792.0944+T374+v.2"]="3792.0944 T374 V 12"
  ["792.0944+T3741"]="3792.0944 T3741"
)

BASE_URL="http://localhost:8080/folio-shelving-order/shelf-key?callNumber="
PASS=true

for callNumber in "${!tests[@]}"; do
  expected="${tests[$callNumber]}"
  response=$(curl -fs "${BASE_URL}${callNumber}")
  status=OK
  if [[ "$response" != "$expected" ]]; then
    status=FAIL
    PASS=false
  fi
  echo "$callNumber => $response $status"
done

# docker stop fso > dev/null  2>&1

if ! $PASS; then
  exit 1
fi
