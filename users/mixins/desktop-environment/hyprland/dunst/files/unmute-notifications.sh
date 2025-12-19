#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATE_FILE="$STATE_DIR/gamemoderun-pause-level"

function get_current_pause_level() {
	dunstctl get-pause-level
}

function load_notification_level() {
	cat "$STATE_FILE"
	rm "$STATE_FILE"
}

if [[ ! -f $STATE_FILE ]]; then
	# The state file is missing,
	# this means it either got lost or we did not set a level.
	# Either way we don't want to change the pause level.
	exit 0
fi

saved_pause_level=$(load_notification_level)
current_pause_level=$(get_current_pause_level)

if [[ $saved_pause_level -eq $current_pause_level ]]; then
	# The saved level and the current level are the same
	# -> nothing to do
	exit 0
fi

# Finally we can reset the pause level to the old level
dunstctl set-pause-level "$saved_pause_level"
