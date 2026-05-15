#!/usr/bin/env sh
set -eu

IMAGE="${APPIMAGE_BUILDER_IMAGE:-appimagecrafters/appimage-builder:latest}"
RECIPE="${APPIMAGE_BUILDER_RECIPE:-packaging/appimage/AppImageBuilder.yml}"
OUTPUT_NAME="${APPIMAGE_OUTPUT_NAME:-PDF_Diff_Viewer-0.1.0-x86_64.AppImage}"

mkdir -p dist build

docker run --rm --privileged \
  -v "$PWD:/work" \
  -w /work \
  "$IMAGE" \
  appimage-builder --recipe "$RECIPE" --skip-test

mkdir -p dist
APPIMAGE_PATH="$(find . -maxdepth 1 -type f -name '*.AppImage' -print -quit)"
if [ -n "$APPIMAGE_PATH" ]; then
  mv -f "$APPIMAGE_PATH" "dist/$OUTPUT_NAME"
fi
find . -maxdepth 1 -type f -name '*.AppImage.zsync' -exec mv -f {} dist/ \;
