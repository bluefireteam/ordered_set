#!/bin/bash -xe

pub run coverage:format_coverage \
  --lcov \
  --in=coverage/test/ \
  --out=coverage/lcov.info \
  --packages=.packages \
  --report-on=lib