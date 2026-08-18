state_file="${XDG_STATE_HOME:-$HOME/.local/state}/theme-switch/current"

# A specialisation's own generation carries no specialisation/ dir, so walk the
# generations newest-first for the most recent base one.
base=""
while read -r generation; do
  if [[ -d "$generation/specialisation" ]]; then
    base="$generation"
    break
  fi
done < <(home-manager generations | awk '{print $NF}')

if [[ -z "$base" ]]; then
  echo "theme-switch: no generation with specialisations found, run home-manager switch first" >&2
  exit 1
fi

choice="${1:-}"

if [[ "$choice" == "resume" ]]; then
  if [[ ! -f "$state_file" ]]; then
    echo "theme-switch: no theme recorded to resume" >&2
    exit 1
  fi
  choice="$(<"$state_file")"
fi

if [[ -z "$choice" ]]; then
  names="default"
  for entry in "$base/specialisation"/*; do
    names+=" ${entry##*/}"
  done
  echo "available: $names"
  if [[ -f "$state_file" ]]; then
    echo "current: $(<"$state_file")"
  fi
  exit 0
fi

if [[ "$choice" == "default" ]]; then
  activate="$base/activate"
else
  activate="$base/specialisation/$choice/activate"
fi

if [[ ! -x "$activate" ]]; then
  echo "theme-switch: unknown theme '$choice'" >&2
  exit 1
fi

"$activate"

mkdir -p "$(dirname "$state_file")"
printf '%s\n' "$choice" > "$state_file"

# Symlink flips do not reliably wake hyprland's config watcher.
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl > /dev/null; then
  hyprctl reload > /dev/null
fi
