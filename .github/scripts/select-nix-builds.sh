#!/usr/bin/env bash

set -euo pipefail

all_hosts=(legion chad ghost forge)

emit_selection() {
  local darwin="$1"
  shift
  local hosts
  hosts="$(jq --compact-output --null-input --args '$ARGS.positional' -- "$@")"
  jq --compact-output --null-input \
    --argjson hosts "$hosts" \
    --argjson darwin "$darwin" \
    '{ hosts: $hosts, darwin: $darwin }'
}

if [[ "${1:-}" == "--all" ]]; then
  emit_selection true "${all_hosts[@]}"
  exit 0
fi

if [[ $# -ne 3 ]]; then
  printf 'usage: %s BASE_FLAKE HEAD_FLAKE CHANGED_FILES\n' "$0" >&2
  exit 64
fi

base_flake="$1"
head_flake="$2"
changed_files="$3"
nix_command="${NIX_COMMAND:-nix}"

if [[ ! -r "$changed_files" ]]; then
  printf 'changed-files list is not readable: %s\n' "$changed_files" >&2
  exit 66
fi

linux_candidate=false
darwin_candidate=false
force_all=false

while IFS= read -r path; do
  [[ -n "$path" ]] || continue

  case "$path" in
    .github/workflows/nix.yml | .github/scripts/select-nix-builds.sh | .github/scripts/test-select-nix-builds.sh)
      force_all=true
      ;;
    flake.nix | flake.lock | public-keys.nix | .sops.yaml | lib/* | overlays/* | pkgs/* | secrets/*)
      linux_candidate=true
      darwin_candidate=true
      ;;
    machines/darwin/* | modules/darwin/* | modules/shared/*)
      darwin_candidate=true
      if [[ "$path" == modules/shared/* ]]; then
        linux_candidate=true
      fi
      ;;
    machines/* | modules/nixos/*)
      linux_candidate=true
      ;;
    *.nix)
      # Unknown Nix sources are treated as cross-platform until their place in
      # the module graph is made explicit above.
      linux_candidate=true
      darwin_candidate=true
      ;;
  esac
done < "$changed_files"

if [[ "$force_all" == true ]]; then
  emit_selection true "${all_hosts[@]}"
  exit 0
fi

if [[ "$linux_candidate" != true ]]; then
  emit_selection "$darwin_candidate"
  exit 0
fi

fingerprints() {
  local flake="$1"
  "$nix_command" eval --json "${flake}#checks.x86_64-linux" --apply '
    checks: {
      legion = [ checks.nixos-legion.drvPath ];
      chad = [ checks.nixos-chad.drvPath ];
      ghost = [ checks.nixos-ghost.drvPath ];
      forge = [
        checks.nixos-forge.drvPath
        checks.forge-disko.drvPath
        checks.forge-alert-rules.drvPath
      ];
    }
  '
}

selected_hosts=()
comparison_failed=false

if ! base_fingerprints="$(fingerprints "$base_flake")"; then
  comparison_failed=true
elif ! head_fingerprints="$(fingerprints "$head_flake")"; then
  comparison_failed=true
else
  for host in "${all_hosts[@]}"; do
    base_host="$(jq --compact-output --arg host "$host" '.[$host]' \
      <<< "$base_fingerprints")"
    head_host="$(jq --compact-output --arg host "$host" '.[$host]' \
      <<< "$head_fingerprints")"
    if [[ "$base_host" != "$head_host" ]]; then
      selected_hosts+=("$host")
    fi
  done
fi

if [[ "$comparison_failed" == true ]]; then
  printf 'warning: derivation comparison failed; selecting every Linux host\n' >&2
  selected_hosts=("${all_hosts[@]}")
fi

emit_selection "$darwin_candidate" "${selected_hosts[@]}"
