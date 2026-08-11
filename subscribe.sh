#!/usr/bin/env bash
set -Eeuo pipefail

readonly SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
readonly INSTALL_DIR="$HOME/.local/libexec/scarlett-channel-picker"
readonly CONFIG_DIR="$HOME/.config/scarlett-channel-picker"
readonly USER_UNIT_DIR="$HOME/.config/systemd/user"
readonly UNIT_NAME='scarlett-channel-picker.service'

for file in scarlett-channel-source scarlett-channel-picker-daemon config.example scarlett-channel-picker.service; do
  [[ -f $SCRIPT_DIR/$file ]] || { printf 'Missing required file: %s\n' "$SCRIPT_DIR/$file" >&2; exit 1; }
done
command -v systemctl >/dev/null || { printf 'systemctl is required\n' >&2; exit 1; }

install -d -m 0755 "$INSTALL_DIR" "$CONFIG_DIR" "$USER_UNIT_DIR"
install -m 0755 "$SCRIPT_DIR/scarlett-channel-source" "$INSTALL_DIR/scarlett-channel-source"
install -m 0755 "$SCRIPT_DIR/scarlett-channel-picker-daemon" "$INSTALL_DIR/scarlett-channel-picker-daemon"
install -m 0644 "$SCRIPT_DIR/scarlett-channel-picker.service" "$USER_UNIT_DIR/$UNIT_NAME"

if [[ ! -e $CONFIG_DIR/config ]]; then
  install -m 0600 "$SCRIPT_DIR/config.example" "$CONFIG_DIR/config"
  printf 'Created persistent name configuration: %s\n' "$CONFIG_DIR/config"
else
  printf 'Preserved existing name configuration: %s\n' "$CONFIG_DIR/config"
fi

systemctl --user daemon-reload
systemctl --user enable "$UNIT_NAME"
systemctl --user restart "$UNIT_NAME"
systemctl --user is-enabled --quiet "$UNIT_NAME"
systemctl --user is-active --quiet "$UNIT_NAME"
printf '%s is enabled and running.\n' "$UNIT_NAME"
