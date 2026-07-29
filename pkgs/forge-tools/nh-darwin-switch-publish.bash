flake="${NH_DARWIN_FLAKE:-${NH_FLAKE:-}}"
dry_run=false

if [[ -z "$flake" ]]; then
  echo "NH_DARWIN_FLAKE or NH_FLAKE must identify the configuration flake" >&2
  exit 2
fi

for argument in "$@"; do
  case "$argument" in
    --) break ;;
    -n | --dry) dry_run=true ;;
    -o | --out-link | --out-link=*)
      echo "the wrapper manages nh's output link" >&2
      exit 2
      ;;
  esac
done

temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/nh-darwin-publish.XXXXXX")"
result_link="${temporary_directory}/system"

cleanup() {
  if [[ -L "$result_link" ]]; then
    unlink "$result_link"
  fi
  rmdir "$temporary_directory" 2>/dev/null || true
}
trap cleanup EXIT

nh darwin switch "$flake" \
  --hostname darwin \
  --out-link "$result_link" \
  "$@"

if [[ "$dry_run" == true ]]; then
  echo "Dry run complete; nothing was activated or published."
  exit 0
fi

if [[ ! -L "$result_link" ]]; then
  echo "nh did not create the expected Darwin system result link" >&2
  exit 1
fi

system_path="$(readlink -f -- "$result_link")"
case "$system_path" in
  /nix/store/*-darwin-system-*) ;;
  *)
    echo "nh produced an unexpected system path: $system_path" >&2
    exit 1
    ;;
esac

printf 'Publishing activated Darwin system closure %s\n' "$system_path"
publish-forge-cache "$system_path"
