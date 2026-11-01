#!/usr/bin/env sh
# Official OpenAI Codex CLI installer; no bundled or modified Codex binary.
set -eu
if ! command -v curl >/dev/null 2>&1; then
  echo 'curl is required to fetch the official OpenAI installer' >&2
  exit 1
fi
installer=$(mktemp)
trap 'rm -f "$installer"' EXIT HUP INT TERM
curl --proto '=https' --tlsv1.2 -fsSL 'https://chatgpt.com/codex/install.sh' -o "$installer"
[ "$(wc -c < "$installer")" -ge 1000 ] || { echo 'Unexpected installer response' >&2; exit 1; }
CODEX_NON_INTERACTIVE=1 sh "$installer"
printf '%s\n' 'Codex official installer finished. Run: codex --version'
