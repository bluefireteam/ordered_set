#!/usr/bin/env bash

pub get

result=$(pub run dart_code_metrics:metrics .)
if [ "$result" != "" ]; then
  echo "dart code metrics issues: $1"
  echo "$result"
  exit 1
fi

result=$(dart analyze .)
if ! echo "$result" | grep -q "No issues found!"; then
  echo "$result"
  echo "dart analyze issue: $1"
fi

exit 0
