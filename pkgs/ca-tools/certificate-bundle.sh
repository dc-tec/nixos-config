# shellcheck shell=bash

export LC_ALL=C

ca_split_bundle() {
  local input=$1 directory=$2
  mkdir -p -- "$directory"
  awk -v directory="$directory" -f "$CA_RECORD_SPLITTER" < "$input"
}

ca_fingerprint() {
  # OpenSSL fingerprints the certificate's DER without auxiliary trust data.
  local fingerprint
  fingerprint=$(openssl x509 -in "$1" -noout -fingerprint -sha256)
  fingerprint=${fingerprint#*=}
  fingerprint=${fingerprint//:/}
  [[ $fingerprint =~ ^[[:xdigit:]]{64}$ ]] || return 1
  printf '%s\n' "${fingerprint,,}"
}

ca_require_policy() {
  jq --exit-status '
    type == "array" and length > 0 and
    all(.[]; (.sha256 | type == "string") and
      (.sha256 | test("^[a-f0-9]{64}$")))
  ' "$1" > /dev/null
}
