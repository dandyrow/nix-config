#!/usr/bin/env bash
# install.sh — Install NixOS on a target machine using nixos-anywhere.
#
# Usage:
#   ./scripts/install.sh [hostname] [ip] [ssh-user] [build-on]
#
# Arguments are optional — the script will prompt for any that are missing.
# The user account password is always prompted for interactively and is never
# written to disk in plaintext.

set -euo pipefail

# --- Helpers -----------------------------------------------------------------

die() { echo "error: $*" >&2; exit 1; }

# Run mkpasswd, falling back to nix-shell if it is not on PATH.
run_mkpasswd() {
  if command -v mkpasswd &>/dev/null; then
    mkpasswd -m sha-512 "$1"
  else
    echo "mkpasswd not found on PATH — running via nix shell (this may take a moment)..." >&2
    nix shell nixpkgs#mkpasswd --command mkpasswd -m sha-512 "$1"
  fi
}

# --- Arguments ---------------------------------------------------------------

HOSTNAME="${1:-}"
IP="${2:-}"
SSH_USER="${3:-}"

if [[ -z "$HOSTNAME" ]]; then
  read -rp "Hostname: " HOSTNAME
fi

if [[ -z "$IP" ]]; then
  read -rp "Target IP address: " IP
fi

if [[ -z "$SSH_USER" ]]; then
  read -rp "SSH user (default: root): " SSH_USER
  SSH_USER="${SSH_USER:-root}"
fi

BUILD_ON="${4:-}"

if [[ -z "$BUILD_ON" ]]; then
  read -rp "Build location — local, remote, auto (default: auto): " BUILD_ON
  BUILD_ON="${BUILD_ON:-auto}"
fi

[[ -n "$HOSTNAME" ]] || die "hostname must not be empty"
[[ -n "$IP" ]]       || die "ip address must not be empty"
[[ "$BUILD_ON" == "local" || "$BUILD_ON" == "remote" || "$BUILD_ON" == "auto" ]] \
  || die "build-on must be one of: local, remote, auto"

# --- Validate hostname against flake -----------------------------------------

echo "Validating hostname against flake outputs..."

VALID_HOSTS=$(nix eval .#nixosConfigurations --apply builtins.attrNames --json 2>/dev/null \
  | tr -d '[]"' | tr ',' '\n' | tr -d ' ') \
  || die "failed to evaluate flake — make sure you are running this from the repo root"

if ! echo "$VALID_HOSTS" | grep -qx "$HOSTNAME"; then
  echo "error: '$HOSTNAME' is not a known nixosConfiguration." >&2
  echo "Available hosts:" >&2
  echo "  ${VALID_HOSTS//$'\n'/$'\n'  }" >&2
  exit 1
fi

echo "Hostname '$HOSTNAME' confirmed."

# --- Password ----------------------------------------------------------------

while true; do
  read -rsp "Password for dandyrow: " PASSWORD
  echo
  read -rsp "Confirm password: " PASSWORD_CONFIRM
  echo
  [[ "$PASSWORD" == "$PASSWORD_CONFIRM" ]] && break
  echo "Passwords do not match — please try again." >&2
done

HASH=$(run_mkpasswd "$PASSWORD")
unset PASSWORD PASSWORD_CONFIRM

# --- Temp directory (cleaned up on exit) -------------------------------------

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "$WORK_DIR/etc/secrets"
echo "$HASH" > "$WORK_DIR/etc/secrets/dandyrow-password"
chmod 600 "$WORK_DIR/etc/secrets/dandyrow-password"
unset HASH

# --- Install -----------------------------------------------------------------

echo "Starting nixos-anywhere install of '$HOSTNAME' on $SSH_USER@$IP ..."

nix run github:nix-community/nixos-anywhere -- \
  --build-on "$BUILD_ON" \
  --extra-files "$WORK_DIR" \
  --flake ".#$HOSTNAME" \
  "$SSH_USER@$IP"
