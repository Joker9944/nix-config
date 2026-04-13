#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATE_FILE="$STATE_DIR/gamemoderun-pause-level"

MUTED_PAUSE_LEVEL="${MUTED_PAUSE_LEVEL:-100}"

function get_current_pause_level() {
	dunstctl get-pause-level
}

function save_pause_level() {
	if [[ ! -f $STATE_FILE ]]; then
		touch "$STATE_FILE"
	fi

	echo -n "$1" >"$STATE_FILE"
}

function delete_state_file() {
	if [[ -f $STATE_FILE ]]; then
		rm "$STATE_FILE"
	fi
}

current_pause_level=$(get_current_pause_level)

if [[ $current_pause_level -lt $MUTED_PAUSE_LEVEL ]]; then
	# The current level is smaller than the one we want to set.
	# -> do it
	save_pause_level "$current_pause_level"
	dunstctl set-pause-level "$MUTED_PAUSE_LEVEL"
else
	# Just in case we cleanup the state file if it exists
	delete_state_file
fi
