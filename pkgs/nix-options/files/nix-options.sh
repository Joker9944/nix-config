#!/usr/bin/env bash

# Query a pinned options.json. $JSON is injected by the packaged wrapper
# (writeShellApplication) that vendors a specific dataset's options.json — so
# there is no flake evaluation here, just jq. Subcommands mirror the old hm-doc.

tool="${0##*/}"

usage() {
	cat <<EOF
$tool — query a pinned options.json

Usage:
  $tool path             Print the baked options.json path (pipe through jq yourself).
  $tool get <option>     Full record for one option (type, default, example, description, declarations).
  $tool list <prefix>    All option keys starting with <prefix> (dot-separated).
  $tool search <keyword> Options whose key or description contains <keyword> (case-insensitive; multi-word = AND).

Examples:
  $tool get programs.neovim.enable
  $tool list programs.gpg
  $tool search "ssh agent"
EOF
}

cmd="${1:-}"
case "$cmd" in
"" | -h | --help | help)
	usage
	;;
path)
	printf '%s\n' "$JSON"
	;;
get)
	[[ $# -ge 2 ]] || {
		echo "$tool get: missing <option>" >&2
		usage
		exit 2
	}
	result="$(jq --arg k "$2" '.[$k] // empty' "$JSON")"
	if [[ -z $result ]]; then
		echo "$tool: no option '$2' in $JSON" >&2
		echo "Try: $tool list <prefix>   or   $tool search <keyword>" >&2
		exit 1
	fi
	printf '%s\n' "$result"
	;;
list)
	[[ $# -ge 2 ]] || {
		echo "$tool list: missing <prefix>" >&2
		usage
		exit 2
	}
	jq -r --arg p "$2" '
      keys[]
      | select(. == $p or startswith($p + "."))
    ' "$JSON"
	;;
search)
	[[ $# -ge 2 ]] || {
		echo "$tool search: missing <keyword>" >&2
		usage
		exit 2
	}
	# Multi-word queries: every whitespace-separated token must appear somewhere
	# in the key or description (case-insensitive), so `search "gpg agent"`
	# behaves the way a human expects.
	jq -r --arg kw "$2" '
      ($kw | ascii_downcase | split(" ") | map(select(length > 0))) as $terms
      | to_entries
      | map(
          . as $entry
          | ((.key + " " + (.value.description // "")) | ascii_downcase) as $hay
          | select($terms | all(. as $t | $hay | contains($t)))
        )
      | .[]
      | "\(.key)\t\(.value.type // "")\t\((.value.description // "") | gsub("\n"; " ") | .[0:120])"
    ' "$JSON"
	;;
*)
	echo "$tool: unknown subcommand '$cmd'" >&2
	usage
	exit 2
	;;
esac
