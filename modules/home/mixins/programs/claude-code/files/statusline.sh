#!/usr/bin/env bash

# Renders the Claude Code status line from the session JSON on stdin.

RESET=$'\033[0m'
DIM=$'\033[2m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
MAGENTA=$'\033[35m'

GLYPH_MODEL='󰚩'
GLYPH_FIVE_HOUR='󰥔'
GLYPH_SEVEN_DAY='󰸗'

BAR_WIDTH=10
BAR_FULL='█'
BAR_TRACK='─'
# Indexed by eighths of a cell to fill; index 0 is unused.
BAR_PARTIAL=('' '▏' '▎' '▍' '▌' '▋' '▊' '▉')

input=$(cat)

# Thresholds are shared by the context bar and the rate-limit segments.
color_for() {
	local pct=$1
	if ((pct < 50)); then
		printf '%s' "$GREEN"
	elif ((pct < 80)); then
		printf '%s' "$YELLOW"
	else
		printf '%s' "$RED"
	fi
}

# Fill resolves to eighths of a cell so low percentages still register. Emits its own colors
# because the track is dim while the fill carries the threshold color.
bar_for() {
	local pct=$1
	local eighths=$((pct * BAR_WIDTH * 8 / 100))
	((eighths > BAR_WIDTH * 8)) && eighths=$((BAR_WIDTH * 8))
	local full=$((eighths / 8)) rest=$((eighths % 8))
	local used=$full fill='' track='' i
	for ((i = 0; i < full; i++)); do
		fill+=$BAR_FULL
	done
	if ((rest > 0)); then
		fill+=${BAR_PARTIAL[rest]}
		used=$((used + 1))
	fi
	for ((i = used; i < BAR_WIDTH; i++)); do
		track+=$BAR_TRACK
	done
	printf '%s%s%s%s%s%s' "$(color_for "$pct")" "$fill" "$RESET" "$DIM" "$track" "$RESET"
}

format_tokens() {
	local n=$1
	if ((n >= 1000)); then
		printf '%dk' $(((n + 500) / 1000))
	else
		printf '%d' "$n"
	fi
}

# `resets_at` is Unix epoch seconds; render the distance to it, coarsest unit first.
format_until() {
	local target=$1 delta days hours minutes
	delta=$((target - $(date +%s)))
	((delta < 0)) && delta=0
	days=$((delta / 86400))
	hours=$((delta % 86400 / 3600))
	minutes=$((delta % 3600 / 60))
	if ((days > 0)); then
		printf '%dd' "$days"
	elif ((hours > 0)); then
		printf '%dh%02dm' "$hours" "$minutes"
	else
		printf '%dm' "$minutes"
	fi
}

model_segment() {
	local model effort
	model=$(jq -r '.model.display_name // empty' <<<"$input")
	[[ -n $model ]] || return 0
	printf '%s%s %s%s' "$MAGENTA" "$GLYPH_MODEL" "$model" "$RESET"

	# Absent for models that do not support effort levels.
	effort=$(jq -r '.effort.level // empty' <<<"$input")
	[[ -n $effort ]] || return 0
	printf ' %s%s%s' "$DIM" "$effort" "$RESET"
}

context_segment() {
	local pct used size color
	pct=$(jq -r '(.context_window.used_percentage // 0) | floor' <<<"$input")
	used=$(jq -r '.context_window.total_input_tokens // 0' <<<"$input")
	size=$(jq -r '.context_window.context_window_size // 0' <<<"$input")
	((size > 0)) || return 0
	color=$(color_for "$pct")
	printf '%s %s%d%%%s %s(%s/%s)%s' \
		"$(bar_for "$pct")" "$color" "$pct" "$RESET" \
		"$DIM" "$(format_tokens "$used")" "$(format_tokens "$size")" "$RESET"
}

# Absent for non-subscription plans and until the first API response of a session; each window
# can also be absent on its own, so a missing one drops its segment rather than reporting 0%.
rate_limit_segment() {
	local window=$1 glyph=$2 label=$3 pct resets color
	pct=$(jq -r --arg w "$window" '.rate_limits[$w].used_percentage // empty' <<<"$input")
	[[ -n $pct ]] || return 0
	pct=${pct%%.*}
	color=$(color_for "$pct")
	printf '%s%s %s %d%%%s' "$color" "$glyph" "$label" "$pct" "$RESET"

	resets=$(jq -r --arg w "$window" '.rate_limits[$w].resets_at // empty' <<<"$input")
	[[ -n $resets ]] || return 0
	printf ' %s·%s%s' "$DIM" "$(format_until "$resets")" "$RESET"
}

line=''
for segment in \
	"$(model_segment)" \
	"$(context_segment)" \
	"$(rate_limit_segment five_hour "$GLYPH_FIVE_HOUR" 5h)" \
	"$(rate_limit_segment seven_day "$GLYPH_SEVEN_DAY" 7d)"; do
	[[ -n $segment ]] || continue
	[[ -n $line ]] && line+='  '
	line+=$segment
done

printf '%s\n' "$line"
