#!/bin/bash -xe

# TODO(luan) make it generic for any number of files
pub run coverage:format_coverage \
  --lcov \
  --in=coverage/test/ordered_set_test.dart.vm.json \
  --in=coverage/test/comparing_test.dart.vm.json \
  --out=coverage/lcov.info \
  --packages=.packages \
  --report-on=lib