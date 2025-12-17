#!/bin/bash
# Script to verify Flutter code quality and run tests
# This script should be run after Flutter SDK is properly installed

set -e

echo "=== Flutter Version ==="
flutter --version

echo ""
echo "=== Installing Dependencies ==="
flutter pub get

echo ""
echo "=== Running Flutter Analyze ==="
flutter analyze

echo ""
echo "=== Running Tests ==="
flutter test

echo ""
echo "=== All checks passed! ==="
