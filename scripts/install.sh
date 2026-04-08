#!/usr/bin/env bash
# install.sh — Install NixOS on a target machine using nixos-anywhere.
#
# Usage:
#   ./scripts/install.sh [hostname] [ip]
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
    echo "mkpasswd not found on PATH — running via nix-shell (this may take a moment)..." >&2
    nix-shell -p whois --run "mkpasswd -m sha-512 '$1'"
  fi
}

# --- Arguments ---------------------------------------------------------------

HOSTNAME="${1:-}"
IP="${2:-}"

if [[ -z "$HOSTNAME" ]]; then
  read -rp "Hostname: " HOSTNAME
fi

if [[ -z "$IP" ]]; then
  read -rp "Target IP address: " IP
fi

[[ -n "$HOSTNAME" ]] || die "hostname must not be empty"
[[ -n "$IP" ]]       || die "ip address must not be empty"

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

echo "Starting nixos-anywhere install of '$HOSTNAME' on root@$IP ..."

nix run github:nix-community/nixos-anywhere -- \
  --extra-files "$WORK_DIR" \
  --flake ".#$HOSTNAME" \
  "root@$IP"
