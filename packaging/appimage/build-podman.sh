#!/usr/bin/env sh
set -eu

IMAGE="${APPIMAGE_BUILDER_IMAGE:-docker.io/appimagecrafters/appimage-builder:latest}"
RECIPE="${APPIMAGE_BUILDER_RECIPE:-packaging/appimage/AppImageBuilder.yml}"
OUTPUT_NAME="${APPIMAGE_OUTPUT_NAME:-PDF_Diff_Viewer-0.1.0-x86_64.AppImage}"
PODMAN_FLAGS="${APPIMAGE_BUILDER_PODMAN_FLAGS---network=host}"

mkdir -p dist build

# Host networking avoids rootless Podman DNS/egress issues seen in restricted
# environments. Override APPIMAGE_BUILDER_PODMAN_FLAGS to use different flags.
# If the final AppImage assembly fails because of FUSE or namespace limits,
# retry with:
# APPIMAGE_BUILDER_PODMAN_FLAGS="--network=host --privileged" packaging/appimage/build-podman.sh
podman run --rm $PODMAN_FLAGS \
  -v "$PWD:/work:Z" \
  -w /work \
  "$IMAGE" \
  appimage-builder --recipe "$RECIPE" --skip-test

mkdir -p dist
APPIMAGE_PATH="$(find . -maxdepth 1 -type f -name '*.AppImage' -print -quit)"
if [ -n "$APPIMAGE_PATH" ]; then
  mv -f "$APPIMAGE_PATH" "dist/$OUTPUT_NAME"
fi
find . -maxdepth 1 -type f -name '*.AppImage.zsync' -exec mv -f {} dist/ \;
