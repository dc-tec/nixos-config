: "${FORGE_RADICLE_PRIVATE_KEY:?Run this script through SecretSpec with the forge-radicle scope}"
: "${FORGE_RADICLE_PUBLIC_KEY:?The packaged Radicle public key is missing}"

target="${FORGE_SSH_TARGET:-roelc@10.77.0.1}"
secret_file="/var/lib/forge-secrets/radicle-node"
expected_public_key="$FORGE_RADICLE_PUBLIC_KEY"
ssh_options=(
  -F /dev/null
  -o BatchMode=yes
)
temporary_directory="$(mktemp --directory)"
temporary_key="$temporary_directory/radicle-node"

cleanup() {
  if [[ -f "$temporary_key" ]]; then
    key_size="$(wc --bytes < "$temporary_key")"
    dd if=/dev/zero of="$temporary_key" bs=1 count="$key_size" conv=notrunc status=none
    rm --force -- "$temporary_key"
  fi
  rmdir "$temporary_directory"
}
trap cleanup EXIT

umask 0077
printf '%s\n' "$FORGE_RADICLE_PRIVATE_KEY" > "$temporary_key"
actual_public_key="$(ssh-keygen -y -f "$temporary_key")"

if [[ "$actual_public_key" != "$expected_public_key" ]]; then
  echo "the SecretSpec key does not match public-keys.nix" >&2
  exit 1
fi

ssh "${ssh_options[@]}" -T "$target" \
  "set -eu
    cleanup_candidate() {
      sudo rm -f -- ${secret_file}.new
    }
    trap cleanup_candidate EXIT
    sudo install -d -m 0700 -o root -g root /var/lib/forge-secrets
    sudo install -m 0600 -o root -g root /dev/null ${secret_file}.new
    sudo tee ${secret_file}.new >/dev/null
    sudo chmod 0400 ${secret_file}.new
    trap - EXIT" \
  < "$temporary_key"

if ! candidate_public_key="$(
  ssh "${ssh_options[@]}" -T "$target" \
    "sudo ssh-keygen -y -f ${secret_file}.new"
)"; then
  ssh "${ssh_options[@]}" -T "$target" \
    "sudo rm -f -- ${secret_file}.new"
  echo "the uploaded Radicle key is invalid; the active key was not changed" >&2
  exit 1
fi

if [[ "$candidate_public_key" != "$expected_public_key" ]]; then
  ssh "${ssh_options[@]}" -T "$target" \
    "sudo rm -f -- ${secret_file}.new"
  echo "the uploaded Radicle key does not match public-keys.nix; the active key was not changed" >&2
  exit 1
fi

ssh "${ssh_options[@]}" -T "$target" \
  "sudo mv -- ${secret_file}.new ${secret_file}"

remote_public_key="$(
  ssh "${ssh_options[@]}" -T "$target" \
    "sudo ssh-keygen -y -f ${secret_file}"
)"

if [[ "$remote_public_key" != "$expected_public_key" ]]; then
  echo "the active Radicle key does not match public-keys.nix after installation" >&2
  exit 1
fi

ssh "${ssh_options[@]}" -T "$target" \
  "sudo stat --format='provisioned %a %U:%G %n' ${secret_file}"
printf 'verified public key %s\n' "$remote_public_key"
