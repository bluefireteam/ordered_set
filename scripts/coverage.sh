#!/bin/bash -xe

pub run coverage:format_coverage \
  --lcov \
  --in=var/coverage.json \
  --out=var/lcov.info \
  --packages=.packages \
  --report-on=lib