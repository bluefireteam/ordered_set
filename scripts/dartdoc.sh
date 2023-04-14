#!/usr/bin/env bash

dart pub get
dart pub run dartdoc --no-auto-include-dependencies --quiet
