#!/usr/bin/env bash
set -euo pipefail

: "${TEST_CA_BUNDLE:?}" "${FILTER_CA_BUNDLE_SCRIPT:?}" "${FILTER_CA_BUNDLE_COMMAND:?}"
: "${VERIFY_CA_BUNDLES_COMMAND:?}"
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT
mkdir "$test_root/certificates"
awk -v directory="$test_root/certificates" '
  /^-----BEGIN CERTIFICATE-----$/ {
    count++
    destination = sprintf("%s/%03d.pem", directory, count)
    active = 1
  }
  active { print > destination }
  /^-----END CERTIFICATE-----$/ {
    close(destination)
    active = 0
    if (count == 102) exit
  }
  END { if (count < 102) exit 1 }
' "$TEST_CA_BUNDLE"

excluded=$test_root/certificates/001.pem
openssl x509 -in "$excluded" -trustout -addreject serverAuth > "$test_root/trusted.pem"
fingerprint=$(openssl x509 -in "$excluded" -noout -fingerprint -sha256)
fingerprint=${fingerprint#*=}
fingerprint=${fingerprint//:/}
jq --null-input --arg fingerprint "${fingerprint,,}" \
  '[{name: "test exclusion", sha256: $fingerprint}]' > "$test_root/policy.json"
for ((index=2; index<=102; index++)); do
  printf -v certificate '%s/certificates/%03d.pem' "$test_root" "$index"
  cat "$certificate" >> "$test_root/unrelated.pem"
done
{
  printf '# public test bundle\n'
  cat "$excluded"
  printf '# trusted record\n'
  cat "$test_root/trusted.pem"
  printf '# unrelated roots\n'
  cat "$test_root/unrelated.pem"
  printf '# end without a newline'
} > "$test_root/original.pem"
{
  # The fixture PEM files end with a newline; the removed record does not.
  printf '# public test bundle\n\n# trusted record\n\n# unrelated roots\n'
  cat "$test_root/unrelated.pem"
  printf '# end without a newline'
} > "$test_root/expected.pem"

filter() {
  bash "$FILTER_CA_BUNDLE_SCRIPT" "$test_root/policy.json" "$bundle" "$@"
}

reject() {
  if filter "$@" > "$directory/error.log" 2>&1; then
    echo 'Expected filtering to fail' >&2
    return 1
  fi
}

no_temporaries() {
  [[ -z $(find "$directory" -maxdepth 1 -name '.ca-filter-*' -print) ]]
}

preserves_data() {
  filter --output "$directory/candidate.pem"
  cmp "$directory/candidate.pem" "$test_root/expected.pem"
  cmp "$bundle" "$test_root/original.pem"
  [[ ! -e $backup ]]
}

packaged_command() {
  "$FILTER_CA_BUNDLE_COMMAND" "$test_root/policy.json" "$bundle" --output "$directory/candidate.pem"
  cmp "$directory/candidate.pem" "$test_root/expected.pem"
}

preserves_crlf() {
  awk 'BEGIN { RS="\n" } { printf "%s%s", $0, (RT == "" ? "" : "\r\n") }' \
    "$test_root/original.pem" > "$bundle"
  awk 'BEGIN { RS="\n" } { printf "%s%s", $0, (RT == "" ? "" : "\r\n") }' \
    "$test_root/expected.pem" > "$directory/expected.pem"
  filter --output "$directory/candidate.pem"
  cmp "$directory/candidate.pem" "$directory/expected.pem"
}

rejects_ordinary_trust() {
  if "$VERIFY_CA_BUNDLES_COMMAND" "$test_root/policy.json" "$bundle" > "$directory/error.log" 2>&1; then
    echo 'Verifier accepted ordinary trust for an excluded root' >&2
    return 1
  fi
  grep --quiet 'has ordinary trust' "$directory/error.log"
}

rejects_missing_tls_rejection() {
  cat "$test_root/expected.pem" > "$bundle"
  printf '\n' >> "$bundle"
  openssl x509 -in "$excluded" -trustout >> "$bundle"
  if "$VERIFY_CA_BUNDLES_COMMAND" "$test_root/policy.json" "$bundle" > "$directory/error.log" 2>&1; then
    echo 'Verifier accepted a trusted record without TLS rejection' >&2
    return 1
  fi
  grep --quiet 'lacks TLS rejection' "$directory/error.log"
}

atomic_permissions() {
  chmod 0640 "$bundle"
  before=$(stat --format='%i' "$bundle")
  owner=$(stat --format='%u:%g' "$bundle")
  filter --backup "$backup"
  [[ $(stat --format='%i' "$bundle") != "$before" ]]
  [[ $(stat --format='%a' "$bundle") == 640 ]]
  [[ $(stat --format='%u:%g' "$bundle") == "$owner" ]]
  [[ $(stat --format='%a' "$backup") == 600 ]]
  [[ $(stat --format='%a' "$(dirname "$backup")") == 700 ]]
  cmp "$bundle" "$test_root/expected.pem"
  cmp "$backup" "$test_root/original.pem"
  no_temporaries
}

idempotent() {
  filter --backup "$backup"
  before=$(stat --format='%i:%y' "$bundle")
  backup_before=$(stat --format='%i:%y' "$backup")
  filter --backup "$backup" > "$directory/second.log"
  grep --quiet 'removed 0' "$directory/second.log"
  [[ $(stat --format='%i:%y' "$bundle") == "$before" ]]
  [[ $(stat --format='%i:%y' "$backup") == "$backup_before" ]]
  cmp "$backup" "$test_root/original.pem"
}

keeps_backup() {
  mkdir -p "$(dirname "$backup")"
  printf 'previous backup' > "$backup"
  filter --backup "$backup"
  [[ $(cat "$backup") == 'previous backup' ]]
  cmp "$bundle" "$test_root/expected.pem"
}

refuses_symlink() {
  mv "$bundle" "$directory/target.pem"
  ln -s "$directory/target.pem" "$bundle"
  reject --backup "$backup"
  [[ -L $bundle && ! -e $backup ]]
  cmp "$directory/target.pem" "$test_root/original.pem"
}

malformed_record() {
  printf '%s\n' '-----BEGIN CERTIFICATE-----' '%%%' '-----END CERTIFICATE-----' >> "$bundle"
  cp "$bundle" "$directory/invalid.pem"
  reject --backup "$backup"
  cmp "$bundle" "$directory/invalid.pem"
  [[ ! -e $backup ]]
  no_temporaries
}

truncated_der() {
  printf '\n-----BEGIN CERTIFICATE-----\nMIIQAAE=\n-----END CERTIFICATE-----\n' >> "$bundle"
  cp "$bundle" "$directory/invalid.pem"
  reject --backup "$backup"
  cmp "$bundle" "$directory/invalid.pem"
  [[ ! -e $backup ]]
}

unterminated_record() {
  printf '\n-----BEGIN CERTIFICATE-----\n' >> "$bundle"
  cp "$bundle" "$directory/invalid.pem"
  reject --backup "$backup"
  cmp "$bundle" "$directory/invalid.pem"
  [[ ! -e $backup ]]
}

small_input() {
  cp "$excluded" "$bundle"
  reject --backup "$backup"
  cmp "$excluded" "$bundle"
  [[ ! -e $backup ]]
}

small_output() {
  cat "$excluded" > "$bundle"
  for ((index=2; index<=100; index++)); do
    printf -v certificate '%s/certificates/%03d.pem' "$test_root" "$index"
    cat "$certificate" >> "$bundle"
  done
  cp "$bundle" "$directory/small.pem"
  reject --backup "$backup"
  cmp "$bundle" "$directory/small.pem"
  [[ ! -e $backup ]]
}

failed_replace() {
  mkdir "$directory/stubs"
  printf '#!%s\nexit 1\n' "$(command -v bash)" > "$directory/stubs/mv"
  chmod +x "$directory/stubs/mv"
  PATH="$directory/stubs:$PATH" reject --backup "$backup"
  cmp "$bundle" "$test_root/original.pem"
  cmp "$backup" "$test_root/original.pem"
  no_temporaries
}

concurrent_update() {
  local filtered=$1
  mkdir "$directory/stubs"
  if [[ $filtered == true ]]; then
    cp "$test_root/expected.pem" "$directory/os-update.pem"
  else
    cp "$test_root/original.pem" "$directory/os-update.pem"
  fi
  printf '\n# concurrent OS update\n' >> "$directory/os-update.pem"
  # Replace the bundle after the helper sets ownership on its temporary file.
  # The packaged application pins its PATH; injection only tests its raw body.
  {
    printf '#!%s\nset -euo pipefail\n' "$(command -v bash)"
    printf '%q "$@"\n' "$(command -v chown)"
    printf '%q %q %q\n' "$(command -v cp)" "$directory/os-update.pem" "$directory/replacement.pem"
    printf '%q -T %q %q\n' "$(command -v mv)" "$directory/replacement.pem" "$bundle"
  } > "$directory/stubs/chown"
  chmod +x "$directory/stubs/chown"
  if [[ $filtered == true ]]; then
    PATH="$directory/stubs:$PATH" filter --backup "$backup"
  else
    PATH="$directory/stubs:$PATH" reject --backup "$backup"
    grep --quiet 'changed during filtering; retry' "$directory/error.log"
  fi
  cmp "$bundle" "$directory/os-update.pem"
  no_temporaries
}

concurrent_filtered() { concurrent_update true; }
concurrent_unfiltered() { concurrent_update false; }

count=0
for test in preserves_data packaged_command preserves_crlf rejects_ordinary_trust \
  rejects_missing_tls_rejection atomic_permissions idempotent keeps_backup \
  refuses_symlink malformed_record truncated_der unterminated_record small_input \
  small_output failed_replace concurrent_filtered concurrent_unfiltered; do
  directory=$test_root/$test
  mkdir "$directory"
  bundle=$directory/bundle.pem
  backup=$directory/backup/original.pem
  cp "$test_root/original.pem" "$bundle"
  ( "$test" )
  printf 'PASS %s\n' "$test"
  count=$((count + 1))
done
printf 'Passed %s CA filter regression tests\n' "$count"
