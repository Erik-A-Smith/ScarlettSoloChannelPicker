#!/usr/bin/env bash
set -Eeuo pipefail

readonly INSTALL_DIR="$HOME/.local/libexec/scarlett-channel-picker"
readonly CONFIG_DIR="$HOME/.config/scarlett-channel-picker"
readonly USER_UNIT_DIR="$HOME/.config/systemd/user"
readonly UNIT_NAME='scarlett-channel-picker.service'
readonly UNIT_FILE="$USER_UNIT_DIR/$UNIT_NAME"

if systemctl --user is-active --quiet "$UNIT_NAME" 2>/dev/null || \
   systemctl --user is-enabled --quiet "$UNIT_NAME" 2>/dev/null; then
  systemctl --user disable --now "$UNIT_NAME"
fi

rm -f "$UNIT_FILE"
rm -f "$INSTALL_DIR/scarlett-channel-source" "$INSTALL_DIR/scarlett-channel-picker-daemon"
rmdir "$INSTALL_DIR" 2>/dev/null || true
systemctl --user daemon-reload
systemctl --user reset-failed "$UNIT_NAME" 2>/dev/null || true

if systemctl --user is-enabled --quiet "$UNIT_NAME" 2>/dev/null; then
  printf 'Failed to disable %s\n' "$UNIT_NAME" >&2
  exit 1
fi
printf '%s is not registered. Saved names remain in %s/config\n' "$UNIT_NAME" "$CONFIG_DIR"
