#!/bin/bash
set -euo pipefail

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "Installing XcodeGen via Homebrew..."
  brew install xcodegen
fi

xcodegen generate
echo "Generated CONCEarth.xcodeproj"
