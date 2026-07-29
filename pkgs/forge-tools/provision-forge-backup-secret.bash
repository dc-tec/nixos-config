: "${FORGE_RESTIC_PASSWORD:?Run this script through SecretSpec with the forge-backup scope}"

target="${FORGE_SSH_TARGET:-roelc@10.77.0.1}"
secret_file="/var/lib/forge-secrets/restic-password"

printf '%s' "$FORGE_RESTIC_PASSWORD" | ssh -T "$target" \
  "sudo install -d -m 0700 -o root -g root /var/lib/forge-secrets \
    && sudo install -m 0600 -o root -g root /dev/null ${secret_file}.new \
    && sudo tee ${secret_file}.new >/dev/null \
    && sudo chmod 0400 ${secret_file}.new \
    && sudo mv -- ${secret_file}.new ${secret_file} \
    && sudo test -s ${secret_file}"

ssh -T "$target" \
  "sudo stat --format='provisioned %a %U:%G %n' ${secret_file}"
