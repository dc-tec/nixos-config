# shellcheck shell=bash

if [[ $# -lt 2 ]]; then
  echo 'usage: verify-ca-bundles POLICY BUNDLE...' >&2
  exit 64
fi
policy=$1
shift
ca_require_policy "$policy"
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
declare -A excluded
while IFS=$'\t' read -r digest name; do
  excluded["$digest"]=$name
done < <(jq --raw-output '.[] | [.sha256, .name] | @tsv' "$policy")

number=0
for bundle in "$@"; do
  number=$((number + 1))
  directory=$work/$number
  ca_split_bundle "$bundle" "$directory"
  count=$(cat "$directory/count")
  : > "$directory/seen"
  : > "$directory/ordinary"
  retained_control=false
  for ((index=1; index<=count; index++)); do
    printf -v record '%s/%06d.pem' "$directory" "$index"
    digest=$(ca_fingerprint "$record")
    printf '%s\n' "$digest" >> "$directory/seen"
    trusted=false
    if grep --quiet '^-----BEGIN TRUSTED CERTIFICATE-----' "$record"; then trusted=true; fi
    if [[ -n ${excluded[$digest]+present} ]]; then
      if [[ $trusted != true ]]; then
        printf 'Distrust policy failed for %s: %s has ordinary trust\n' "$bundle" "${excluded[$digest]}" >&2
        exit 1
      fi
      rejected=$(openssl x509 -in "$record" -noout -text | awk '/Rejected Uses:/{getline; print; exit}')
      if [[ $rejected != *'TLS Web Server Authentication'* ]]; then
        printf 'Distrust policy failed for %s: %s lacks TLS rejection\n' "$bundle" "${excluded[$digest]}" >&2
        exit 1
      fi
    elif [[ $trusted != true ]]; then
      printf '%s\n' "$digest" >> "$directory/ordinary"
      if [[ $retained_control != true ]]; then
        subject=$(openssl x509 -in "$record" -noout -subject)
        if [[ $subject == *'ISRG Root X1'* ]]; then retained_control=true; fi
      fi
    fi
  done
  unique=$(sort --unique "$directory/seen" | wc -l)
  ordinary=$(sort --unique "$directory/ordinary" | wc -l)
  if (( ordinary < 100 )) || [[ $retained_control != true ]]; then
    echo "Unrelated trusted roots are missing or unexpectedly few: $bundle" >&2
    exit 1
  fi
  printf 'Verified %s: %s unique certificates; %s ordinary trusted roots; excluded roots lack TLS trust\n' \
    "$bundle" "$unique" "$ordinary"
done
