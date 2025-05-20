#!/usr/bin/env bash

declare -A tests=(
  ["792.0944+T374+v.1"]="3792.0944 T374 V 11"
  ["792.0944+T374+v.2"]="3792.0944 T374 V 12"
  ["792.0944+T3741"]="3792.0944 T3741"
  ["792.0944+T3741"]="3792.0944 T3742"
)

BASE_URL="http://localhost:8080/folio-shelving-order/shelf-key?callNumber="
PASS=true

for callNumber in "${!tests[@]}"; do
  expected="${tests[$callNumber]}"
  response=$(curl -fs "${BASE_URL}${callNumber}")

  if [[ "$response" != "$expected" ]]; then
    echo "FAIL: '$callNumber' => got '$response', expected '$expected'"
    PASS=false
  fi
done

if ! $PASS; then
  exit 1
fi
