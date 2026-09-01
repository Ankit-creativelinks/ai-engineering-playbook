#!/usr/bin/env bash
# Verify every relative Markdown link in this repository resolves to a file that
# exists, and that every anchor it targets is actually present in that file.
#
# No external dependencies, so it cannot break because someone else shipped a
# release. Run locally with: bash scripts/check-links.sh
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

anchors=$(mktemp)
links=$(mktemp)
trap 'rm -f "$anchors" "$links"' EXIT

# --- Build an index of the anchors every file offers -------------------------
# GitHub derives a heading anchor by lowercasing, dropping anything that is not
# alphanumeric/space/hyphen, then replacing spaces with hyphens. Explicit
# <a name="..."> tags are used verbatim.
while IFS= read -r file; do
  abs=$(realpath "$file")

  sed -nE 's/^#{1,6} +//p' "$file" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9 -]//g; s/ /-/g' \
    | sed -E "s#^#${abs}\t#" >> "$anchors"

  grep -oE '<a name="[^"]+"' "$file" 2>/dev/null \
    | sed -E 's/<a name="//; s/"$//' \
    | sed -E "s#^#${abs}\t#" >> "$anchors"
done < <(find . -name '*.md' -not -path './.git/*')

# --- Collect every relative link ---------------------------------------------
while IFS= read -r file; do
  grep -oE '\]\([^)]+\)' "$file" 2>/dev/null \
    | sed -E 's/^\]\(//; s/\)$//' \
    | sed -E "s#^#${file}\t#" >> "$links"
done < <(find . -name '*.md' -not -path './.git/*')

# --- Check ------------------------------------------------------------------
broken=0
checked=0

while IFS=$'\t' read -r src target; do
  case "$target" in
    http://*|https://*|mailto:*|'#!'*) continue ;;
  esac

  checked=$((checked + 1))
  dir=$(dirname "$src")

  path="${target%%#*}"
  anchor=""
  case "$target" in *'#'*) anchor="${target#*#}" ;; esac

  if [ -n "$path" ]; then
    resolved="$dir/$path"
    if [ ! -e "$resolved" ]; then
      echo "BROKEN  $src -> $target"
      echo "        no such file: $resolved"
      broken=$((broken + 1))
      continue
    fi
  else
    resolved="$src"
  fi

  if [ -n "$anchor" ] && [ -f "$resolved" ]; then
    abs=$(realpath "$resolved")
    if ! grep -qxF "$(printf '%s\t%s' "$abs" "$anchor")" "$anchors"; then
      echo "BROKEN  $src -> $target"
      echo "        no anchor '#$anchor' in $resolved"
      broken=$((broken + 1))
      continue
    fi
  fi
done < "$links"

echo
echo "checked $checked relative links, $broken broken"
[ "$broken" -eq 0 ] || exit 1
echo "all links resolve"
