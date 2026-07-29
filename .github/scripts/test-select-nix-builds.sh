#!/usr/bin/env bash

set -euo pipefail

selector="${CI_SELECTOR:-$(dirname "$0")/select-nix-builds.sh}"
test_root="$(mktemp -d)"
trap 'rm -rf -- "$test_root"' EXIT

mock_nix="$test_root/nix"
printf '#!%s\n' "$BASH" > "$mock_nix"
cat >> "$mock_nix" <<'EOF'
set -euo pipefail

target=""
for argument in "$@"; do
  case "$argument" in
    base#* | head#*)
      target="$argument"
      ;;
  esac
done

if [[ "${MOCK_MODE:-same}" == fail ]]; then
  exit 1
fi

jq --compact-output --null-input \
  --arg mode "${MOCK_MODE:-same}" \
  --arg target "$target" '
    {
      legion: ["legion"],
      chad: ["chad"],
      ghost: ["ghost"],
      forge: ["forge", "forge-disko", "forge-alert-rules"]
    }
    | if ($target | startswith("head#")) and $mode == "forge" then
        .forge += ["changed"]
      elif ($target | startswith("head#")) and $mode == "chad" then
        .chad += ["changed"]
      else
        .
      end
  '
EOF
chmod +x "$mock_nix"

assert_selection() {
  local name="$1"
  local changed="$2"
  local mode="$3"
  local expected="$4"
  local changed_file="$test_root/$name.changed"

  printf '%s\n' "$changed" > "$changed_file"
  actual="$({
    MOCK_MODE="$mode" NIX_COMMAND="$mock_nix" \
      bash "$selector" base head "$changed_file"
  } | jq --compact-output --sort-keys '.')"

  if [[ "$actual" != "$expected" ]]; then
    printf '%s: expected %s, got %s\n' "$name" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_selection \
  docs-only \
  docs/machine-forge.md \
  fail \
  '{"darwin":false,"hosts":[]}'

assert_selection \
  forge-only \
  modules/nixos/server/forge/tangled.nix \
  forge \
  '{"darwin":false,"hosts":["forge"]}'

assert_selection \
  shared-chad \
  modules/shared/system.nix \
  chad \
  '{"darwin":true,"hosts":["chad"]}'

assert_selection \
  unchanged-lock \
  flake.lock \
  same \
  '{"darwin":true,"hosts":[]}'

assert_selection \
  linux-evaluation-failure \
  modules/nixos/server/forge/tangled.nix \
  fail \
  '{"darwin":false,"hosts":["legion","chad","ghost","forge"]}'

assert_selection \
  workflow-change \
  .github/workflows/nix.yml \
  fail \
  '{"darwin":true,"hosts":["legion","chad","ghost","forge"]}'

printf 'CI build selection tests passed\n'
