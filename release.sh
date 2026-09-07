#!/usr/bin/env bash
set -euo pipefail

KEY_ID="Onpier DevOps"
WORKDIR=$(mktemp -d)
OP_VAULT="DevOps"
OP_ITEM="Helm plugins PGP keys"
OP_PRIVATE_KEY_FILE="private.asc"
OP_PASSPHRASE_FIELD="passphrase"

export GNUPGHOME="${WORKDIR}/gnupg"
export GPG_TTY=$(tty)

VERSION=$(yq -r '.version' plugin.yaml)
if [[ -z "$VERSION" || "$VERSION" == "null" ]]; then
  echo "Error: could not read version from plugin.yaml" >&2
  exit 1
fi

mkdir -m 700 "$GNUPGHOME"

cleanup() {
  gpgconf --homedir "$GNUPGHOME" --kill gpg-agent 2>/dev/null || true
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

git tag "v${VERSION}"
git push --tags

echo "allow-loopback-pinentry" >>"${GNUPGHOME}/gpg-agent.conf"
gpgconf --reload gpg-agent

PASSFILE="${WORKDIR}/${OP_PASSPHRASE_FIELD}"
op read "op://${OP_VAULT}/${OP_ITEM}/${OP_PASSPHRASE_FIELD}" >"$PASSFILE"
chmod 600 "$PASSFILE"

gpg --batch --pinentry-mode loopback --passphrase-file "$PASSFILE" \
  --import <(op read "op://${OP_VAULT}/${OP_ITEM}/${OP_PRIVATE_KEY_FILE}")

SECRING="${WORKDIR}/secring.gpg"
gpg --pinentry-mode loopback --passphrase-file "$PASSFILE" --export-secret-keys "$KEY_ID" >"$SECRING"

PUBKEY="${WORKDIR}/pubkey.asc"
gpg --armor --export "$KEY_ID" >"$PUBKEY"

helm plugin package . --sign --key "$KEY_ID" --keyring "$SECRING" \
  --passphrase-file "$PASSFILE" -d "$WORKDIR"

gh release create "v${VERSION}" \
  "${WORKDIR}"/*.tgz "${WORKDIR}"/*.tgz.prov "$PUBKEY" \
  --title "v${VERSION}" \
  --generate-notes
