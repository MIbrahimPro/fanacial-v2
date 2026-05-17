#!/usr/bin/env bash
set -euo pipefail

APP_NAME="money-manager"
APP_DIR="/opt/money-manager"
VERSION="1.0.0"
ARCH="amd64"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build/linux/x64/release/bundle"
STAGE_DIR="/tmp/opencode/${APP_NAME}-deb"
OUT_DIR="$ROOT_DIR/build/linux/deb"
PKG_DIR="$STAGE_DIR/${APP_NAME}_${VERSION}_${ARCH}"

flutter build linux --release

rm -rf "$STAGE_DIR"
mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR$APP_DIR"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$OUT_DIR"

cp -r "$BUILD_DIR"/* "$PKG_DIR$APP_DIR/"
cp "$ROOT_DIR/packaging/linux/money-manager.desktop" "$PKG_DIR/usr/share/applications/money-manager.desktop"
cp "$ROOT_DIR/linux/runner/resources/app_icon.png" "$PKG_DIR/usr/share/icons/hicolor/256x256/apps/money-manager.png"

cat > "$PKG_DIR/DEBIAN/control" <<EOF
Package: ${APP_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: mibrahimpro
Description: Offline-first personal finance tracker built with Flutter
EOF

dpkg-deb --build "$PKG_DIR" "$OUT_DIR/${APP_NAME}_${VERSION}_${ARCH}.deb"

echo "Built: $OUT_DIR/${APP_NAME}_${VERSION}_${ARCH}.deb"
