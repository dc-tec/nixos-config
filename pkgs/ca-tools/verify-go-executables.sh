# shellcheck shell=bash

if [[ $# -ne 3 ]]; then
  echo 'usage: verify-go-executables COMPILER CLOSURE POLICY' >&2
  exit 64
fi
compiler=$1
closure=$2
policy=$3
declare -A minimum_versions seen
while IFS=$'\t' read -r series minimum; do
  minimum_versions["$series"]=$minimum
done < <(jq --raw-output 'to_entries[] | [.key, .value] | @tsv' "$policy")
latest=$(jq --exit-status --raw-output 'to_entries | max_by(.value | split(".") | map(tonumber)) | .value' "$policy")

version_at_least() {
  local -a actual required
  local index
  IFS=. read -r -a actual <<< "$1"
  IFS=. read -r -a required <<< "$2"
  for index in 0 1 2; do
    if (( 10#${actual[index]} > 10#${required[index]} )); then return 0; fi
    if (( 10#${actual[index]} < 10#${required[index]} )); then return 1; fi
  done
  return 0
}

verified=0
while IFS= read -r package; do
  directory=$package/bin
  [[ -d $directory ]] || continue
  for candidate in "$directory/"*; do
    [[ -f $candidate ]] || continue
    executable=$(readlink -f -- "$candidate")
    [[ -z ${seen[$executable]+present} ]] || continue
    seen["$executable"]=1
    if ! metadata=$(GOTOOLCHAIN=local GOENV=off "$compiler" version -m "$executable" 2>/dev/null); then continue; fi
    [[ -n $metadata ]] || continue
    first=${metadata%%$'\n'*}
    if [[ $first != "$executable: "* ]]; then
      echo "Unexpected Go metadata: $first" >&2
      exit 1
    fi
    version=${first#"$executable: "}
    version=${version%% *}
    if [[ ! $version =~ ^go([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
      echo "Cached Go binary lacks a qualified compiler: $first" >&2
      exit 1
    fi
    release=${version#go}
    series=${BASH_REMATCH[1]}.${BASH_REMATCH[2]}
    minimum=${minimum_versions[$series]:-$latest}
    if ! version_at_least "$release" "$minimum"; then
      echo "Cached Go binary lacks a qualified compiler: $first" >&2
      exit 1
    fi
    verified=$((verified + 1))
    printf '%s\n' "$first"
  done
done < "$closure"
printf 'Verified %s cached Go executables\n' "$verified"
