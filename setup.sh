#!/usr/bin/env sh
# Portable starter setup. Installs no GUI or CLI without explicit flags.
set -eu
repo=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
apply=false
install_cli=false
for arg in "$@"; do
  case "$arg" in
    --apply) apply=true ;;
    --install-cli) install_cli=true ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done
command -v python3 >/dev/null || { echo 'Python 3.9+ required' >&2; exit 1; }
if [ "$apply" = true ]; then
  python3 "$repo/scripts/bootstrap.py" --apply
else
  python3 "$repo/scripts/bootstrap.py"
fi
if [ "$install_cli" = true ]; then
  [ "$apply" = true ] || { echo '--install-cli requires --apply' >&2; exit 2; }
  sh "$repo/scripts/install-official.sh"
fi
printf '%s\n' 'Official Linux Desktop installation: https://learn.chatgpt.com/docs/linux/linux-app'
