#!/usr/bin/env bash
set -euo pipefail

FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_HOME="${PWD}/.render/flutter"

if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
  rm -rf "${FLUTTER_HOME}"
  mkdir -p "$(dirname "${FLUTTER_HOME}")"
  git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    --branch "${FLUTTER_CHANNEL}" \
    "${FLUTTER_HOME}"
fi

export PATH="${FLUTTER_HOME}/bin:${PATH}"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release
