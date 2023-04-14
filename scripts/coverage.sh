#!/bin/bash -xe

dart pub get

dart test --coverage=coverage .

dart pub run coverage:format_coverage \
  --lcov \
  --in=coverage/test/ \
  --out=coverage/lcov.info \
  --report-on=lib
