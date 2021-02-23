#!/usr/bin/env bash

FORMAT_ISSUES=$(dart format --output=none --set-exit-if-changed .)
if [ $? -eq 1 ]; then
  echo "dart format issues on"
  echo $FORMAT_ISSUES
  exit 1
fi
