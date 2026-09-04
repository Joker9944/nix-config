#!/usr/bin/env bash

# `git branch --merged` only sees ancestry, so it misses every branch that
# shipped via rebase or squash. git cherry catches those by patch-id, but they
# are not ancestors and so need -D rather than -d — hence the two buckets.

usage() {
	cat <<EOF
tidy-branches — delete local branches whose work is already in the default branch

Usage:
  tidy-branches [--delete] [--fetch] [--base <branch>]

Options:
  --delete         Delete. Without it this only reports.
  --fetch          git fetch --prune first, so the comparison uses a current base.
  --base <branch>  Compare against <branch> instead of origin/HEAD (falling back to main).
EOF
}

delete=false
fetch=false
base=""

while [ $# -gt 0 ]; do
	case "$1" in
	--delete)
		delete=true
		;;
	--fetch)
		fetch=true
		;;
	--base)
		if [ $# -lt 2 ]; then
			echo "--base needs a branch name" >&2
			exit 1
		fi
		base="$2"
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "unknown argument: $1" >&2
		usage >&2
		exit 1
		;;
	esac
	shift
done

git rev-parse --git-dir >/dev/null

if [ "$fetch" = true ]; then
	git fetch --prune
fi

if [ -z "$base" ]; then
	base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD || true)
	base="${base#origin/}"
	base="${base:-main}"
fi

if ! git rev-parse --verify --quiet "$base" >/dev/null; then
	echo "base branch '$base' not found" >&2
	exit 1
fi

current=$(git symbolic-ref --quiet --short HEAD || true)

merged=()
absorbed=()
kept=()

while IFS= read -r ref; do
	branch="${ref#refs/heads/}"
	if [ "$branch" = "$base" ] || [ "$branch" = "$current" ]; then
		continue
	fi

	if git merge-base --is-ancestor "$ref" "$base"; then
		merged+=("$branch")
		continue
	fi

	# fully qualified: a branch named origin/foo is otherwise ambiguous
	unique=$(git cherry "$base" "$ref" | grep -c '^+' || true)
	if [ "$unique" -eq 0 ]; then
		absorbed+=("$branch")
	else
		kept+=("$(git log -1 --format=%cs "$ref")  $branch ($unique unique)")
	fi
done < <(git for-each-ref --format='%(refname)' refs/heads)

echo "base: $base"

if [ ${#merged[@]} -gt 0 ]; then
	echo
	echo "merged — deletable with -d:"
	printf '  %s\n' "${merged[@]}"
fi

if [ ${#absorbed[@]} -gt 0 ]; then
	echo
	echo "absorbed by rebase or squash, patch-identical — needs -D:"
	printf '  %s\n' "${absorbed[@]}"
fi

if [ ${#kept[@]} -gt 0 ]; then
	echo
	echo "unique commits — kept:"
	printf '  %s\n' "${kept[@]}" | sort
fi

total=$((${#merged[@]} + ${#absorbed[@]}))
echo

if [ "$total" -eq 0 ]; then
	echo "nothing to delete"
	exit 0
fi

if [ "$delete" != true ]; then
	echo "dry run — pass --delete to remove those $total branches"
	exit 0
fi

if [ ${#merged[@]} -gt 0 ]; then
	git branch -d "${merged[@]}"
fi

if [ ${#absorbed[@]} -gt 0 ]; then
	git branch -D "${absorbed[@]}"
fi
