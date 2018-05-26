#!/bin/bash -xe

pub get
pub global activate coverage ">=0.10.0"

OBS_PORT=9292
echo "Collecting coverage on port $OBS_PORT..."

# Start tests in one VM.
echo "Starting tests..."
dart \
  --enable-vm-service=$OBS_PORT \
  --pause-isolates-on-exit \
  test/all.dart &

# Run the coverage collector to generate the JSON coverage report.
echo "Collecting coverage..."
pub global run coverage:collect_coverage \
  --port=$OBS_PORT \
  --out=var/coverage.json \
  --wait-paused \
  --resume-isolates

echo "Generating LCOV report..."
pub global run coverage:format_coverage \
  --lcov \
  --in=var/coverage.json \
  --out=var/lcov.info \
  --packages=.packages \
  --report-on=lib

echo "Uploading to Coveralls..."
coveralls-lcov var/lcov.info
