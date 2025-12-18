#!/usr/bin/env bash
set -euo pipefail
# Since we inherit the fail for command substitutions we can safely ignore SC2155
shopt -s inherit_errexit

CHANNEL="$1"
MAILBOX="$2"

# imapnotify uses canonical imap box names but mbsync uses a human readable
# representation. So let's convert to the human readable one.
if [[ $MAILBOX == "INBOX" ]]; then
	MAILBOX="Inbox"
fi

NEW_MAIL_DIR="${MAILDIR:-$HOME/Maildir}/$CHANNEL/$MAILBOX/new"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/mbsync-notify"
STATE_FILE="$STATE_DIR/$CHANNEL-$MAILBOX-last-run"

mkdir -p "$STATE_DIR"
if [[ ! -f $STATE_FILE ]]; then
	touch -t 197001010000.00 "$STATE_FILE"
fi

function update_state_file() {
	touch "$STATE_FILE"
}

function new_messages() {
	find "$NEW_MAIL_DIR" -maxdepth 1 -type f -newer "$STATE_FILE"
}

function count_messages() {
	printf '%s' "$1" | awk 'END{print NR}'
}

function generate_summary() {
	printf '%s - %s' "$CHANNEL" "$MAILBOX"
}

function trim_whitespace() {
	sed 's/^ //' | tr -d '\n'
}

function escape_html() {
	sed \
		-e 's/&/\&amp;/g' \
		-e 's/</\&lt;/g' \
		-e 's/>/\&gt;/g'
}

function format_message_field() {
	printf '%s' "$(formail -x "$1" <"$2" | trim_whitespace | escape_html)"
}

function generate_body() {
	local count="$1"

	if [[ $count -gt 1 ]]; then
		printf '%s new messages' "$count"
		return
	fi

	# Since we only have one message we can safely assume that we only have one message
	local messages="$2"

	printf '<b>From:</b> %s\n<b>Subject:</b> %s' \
		"$(format_message_field "From:" "$messages")" \
		"$(format_message_field "Subject:" "$messages")"
}

function main() {
	# shellcheck disable=SC2155
	local new_messages=$(new_messages)

	# shellcheck disable=SC2155
	local new_messages_count=$(count_messages "$new_messages")

	if [[ $new_messages_count -le 0 ]]; then
		return
	fi

	update_state_file

	notify-send \
		--urgency="normal" \
		--app-name="mbsync" \
		--category="email.arrived" \
		--icon="${MAIL_NOTIFY_ICON:-mail-unread}" \
		"$(generate_summary)" "$(generate_body "$new_messages_count" "$new_messages")"
}

main
