: "${FORGE_NIX_CACHE_PRIVATE_KEY:?Run this script through SecretSpec with the forge-cache scope}"
: "${FORGE_CACHE_PUBLIC_KEY:?The packaged public cache key is missing}"

target="${FORGE_SSH_TARGET:-roelc@10.77.0.1}"
secret_file="/var/lib/forge-secrets/nix-cache-private-key"
expected_public_key="$FORGE_CACHE_PUBLIC_KEY"
actual_public_key="$(
  printf '%s\n' "$FORGE_NIX_CACHE_PRIVATE_KEY" \
    | nix key convert-secret-to-public
)"

if [[ "$actual_public_key" != "$expected_public_key" ]]; then
  echo "the SecretSpec key does not match public-keys.nix" >&2
  exit 1
fi

printf '%s\n' "$FORGE_NIX_CACHE_PRIVATE_KEY" | ssh -T "$target" \
  "sudo install -d -m 0700 -o root -g root /var/lib/forge-secrets \
    && sudo install -m 0600 -o root -g root /dev/null ${secret_file}.new \
    && sudo tee ${secret_file}.new >/dev/null \
    && sudo chmod 0400 ${secret_file}.new \
    && sudo mv -- ${secret_file}.new ${secret_file}"

remote_public_key="$(
  ssh -T "$target" \
    "sudo sh -c 'nix key convert-secret-to-public < ${secret_file}'"
)"

if [[ "$remote_public_key" != "$expected_public_key" ]]; then
  echo "the provisioned key does not match public-keys.nix" >&2
  exit 1
fi

ssh -T "$target" \
  "sudo stat --format='provisioned %a %U:%G %n' ${secret_file}"
printf 'verified public key %s\n' "$remote_public_key"
