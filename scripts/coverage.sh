#!/bin/bash -xe

# TODO(luan) make it generic for any number of files
pub run coverage:format_coverage \
  --lcov \
  --in=coverage/test/ \
  --out=coverage/lcov.info \
  --packages=.packages \
  --report-on=lib