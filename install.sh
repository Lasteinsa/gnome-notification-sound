#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UUID="notif-sound@einsa"
EXT_BASE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/gnome-shell/extensions"
TARGET_DIR="${EXT_BASE_DIR}/${UUID}"

case "${1:-install}" in
  --dev)
    mkdir -p "$EXT_BASE_DIR"
    rm -rf "$TARGET_DIR"
    ln -s "$SCRIPT_DIR" "$TARGET_DIR"
    echo "Symlinked ${SCRIPT_DIR} -> ${TARGET_DIR}"
    ;;
  --uninstall)
    gnome-extensions disable "$UUID" 2>/dev/null || true
    rm -rf "$TARGET_DIR"
    echo "Uninstalled ${UUID}"
    ;;
  install|--enable)
    mkdir -p "$EXT_BASE_DIR"
    [ -L "$TARGET_DIR" ] && rm -f "$TARGET_DIR"
    rm -rf "$TARGET_DIR"
    mkdir -p "$TARGET_DIR"
    cp -f "${SCRIPT_DIR}/metadata.json" "${SCRIPT_DIR}/extension.js" "$TARGET_DIR/"
    echo "Installed ${UUID} to ${TARGET_DIR}"
    if [ "${1:-}" = "--enable" ]; then
      gnome-extensions enable "$UUID" || echo "Log out and log back in if GNOME Shell has not discovered ${UUID} yet."
    fi
    ;;
  *)
    echo "Usage: $0 [install|--enable|--dev|--uninstall]" >&2
    exit 1
    ;;
esac
