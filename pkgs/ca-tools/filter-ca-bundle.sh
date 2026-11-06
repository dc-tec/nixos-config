# shellcheck shell=bash

if [[ $# -lt 2 ]]; then
  echo 'usage: filter-ca-bundle POLICY BUNDLE [--backup FILE] [--output FILE]' >&2
  exit 64
fi

policy=$1
bundle=$2
shift 2
backup=""
output=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --backup | --output)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 64; }
      if [[ $1 == --backup ]]; then backup=$2; else output=$2; fi
      shift 2
      ;;
    *) echo "Unknown argument: $1" >&2; exit 64 ;;
  esac
done

if [[ -L $bundle || ! -f $bundle ]]; then
  echo 'Refusing to replace a symlink or non-regular CA bundle' >&2
  exit 1
fi

umask 077
work=$(mktemp -d)
replacement=""
cleanup() {
  rm -rf -- "$work"
  if [[ -n $replacement ]]; then rm -f -- "$replacement"; fi
}
trap cleanup EXIT
ca_require_policy "$policy"
jq --raw-output '.[].sha256' "$policy" > "$work/excluded"

filter_bundle() {
  local input=$1 destination=$2 directory=$3
  local count remaining=0 index record digest
  ca_split_bundle "$input" "$directory"
  count=$(cat "$directory/count")
  if (( count < 100 )); then
    echo 'Refusing to replace an unexpectedly small CA bundle' >&2
    return 1
  fi
  cat "$directory/prefix" > "$destination"
  for ((index=1; index<=count; index++)); do
    printf -v record '%s/%06d' "$directory" "$index"
    digest=$(ca_fingerprint "$record.pem")
    if ! grep --fixed-strings --line-regexp --quiet -- "$digest" "$work/excluded"; then
      cat "$record.pem" >> "$destination"
      remaining=$((remaining + 1))
    fi
    cat "$record.tail" >> "$destination"
  done
  if (( remaining < 100 )); then
    echo 'Filtered CA bundle is unexpectedly small' >&2
    return 1
  fi
  FILTER_REMOVED=$((count - remaining))
}

before=$(stat --format='%d:%i:%y:%s' -- "$bundle")
read -r owner group mode < <(stat --format='%u %g %a' -- "$bundle")
cat -- "$bundle" > "$work/original"
filter_bundle "$work/original" "$work/filtered" "$work/records"
removed=$FILTER_REMOVED

if [[ -n $output ]]; then
  cat "$work/filtered" > "$output"
elif (( removed > 0 )); then
  if [[ -n $backup ]]; then
    # The private umask also protects any newly created parent directories.
    mkdir -p -- "$(dirname -- "$backup")"
    cp --update=none -- "$work/original" "$backup"
  fi
  replacement=$(mktemp "$(dirname -- "$bundle")/.ca-filter-XXXXXX")
  cat "$work/filtered" > "$replacement"
  chmod "$mode" "$replacement"
  chown "$owner:$group" "$replacement"
  sync "$replacement"
  current=$(stat --format='%d:%i:%y:%s' -- "$bundle")
  if [[ $current != "$before" ]]; then
    # Preserve a competing activation or OS update. Retry if it remains unsafe.
    [[ ! -L $bundle && -f $bundle ]] || exit 1
    filter_bundle "$bundle" "$work/concurrent" "$work/concurrent-records"
    if (( FILTER_REMOVED > 0 )); then
      echo 'CA bundle changed during filtering; retry' >&2
      exit 1
    fi
    exit 0
  fi
  mv -T -- "$replacement" "$bundle"
  replacement=""
fi
printf '%s: removed %s excluded certificate records\n' "$bundle" "$removed"
