#!/usr/bin/env bash
set -euo pipefail

: "${VERIFY_GO_COMMAND:?}" "${GO_POLICY:?}"
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/package/bin"
touch "$work/package/bin/application"
ln -s application "$work/package/bin/duplicate"
printf '%s\n' "$work/package" > "$work/closure"
{
  printf '#!%s\n' "$(command -v bash)"
  cat <<'COMPILER'
set -euo pipefail
[[ $GOTOOLCHAIN == local && $GOENV == off ]]
[[ $1 == version && $2 == -m ]]
if [[ ${WRONG_PATH:-false} == true ]]; then
  printf 'unexpected-file: %s\n' "$TEST_GO_VERSION"
else
  printf '%s: %s\n' "$3" "$TEST_GO_VERSION"
fi
COMPILER
} > "$work/compiler"
chmod +x "$work/compiler"

count=0
for version in go1.26.10 go1.26.11 go1.27.3 go1.28.0; do
  TEST_GO_VERSION=$version "$VERIFY_GO_COMMAND" "$work/compiler" "$work/closure" "$GO_POLICY" > "$work/result"
  grep --quiet '^Verified 1 cached Go executables$' "$work/result"
  printf 'PASS accept %s and deduplicate symlinks\n' "$version"
  count=$((count + 1))
done
for version in go1.25.12 go1.26.9 go1.27.2 go1.27.3rc1 devel; do
  if TEST_GO_VERSION=$version "$VERIFY_GO_COMMAND" "$work/compiler" "$work/closure" "$GO_POLICY" > "$work/result" 2>&1; then
    echo "Accepted an unqualified compiler: $version" >&2
    exit 1
  fi
  printf 'PASS reject %s\n' "$version"
  count=$((count + 1))
done
if WRONG_PATH=true TEST_GO_VERSION=go1.27.3 \
  "$VERIFY_GO_COMMAND" "$work/compiler" "$work/closure" "$GO_POLICY" > "$work/result" 2>&1; then
  echo 'Accepted mismatched executable metadata' >&2
  exit 1
fi
count=$((count + 1))
printf 'Passed %s Go metadata regression tests\n' "$count"
