#!/usr/bin/env bash
# Move JETCARP's test records from the layout they grew up in (plans at the top, results by
# wave, one NOTES.md for everything) to one folder per release cycle:
#
#   v0.4.2/
#     NOTES.md            the running log of the cycle, release candidates included
#     parity/             the cycle's parity set
#     rc.1/PLAN.md        a candidate's plan, beside ...
#     rc.1/<machine>/     ... each machine's results for it
#     rc.4-pre/           a pre-check on the branch (its steps are in rc.4/PLAN.md)
#     release/            checks on the release itself
#
# Names follow the tags: v0.4.2-rc.1 is v0.4.2/rc.1. MOVED.md lists every old path and its new one.
#
# Usage:  tools/restructure-by-cycle.sh [--dry-run] [DIRECTORY]
#
# DIRECTORY (default: the current one) is the top of the records: the folder that holds results/.
# It works on the public copy and on the working repository alike:
#   - whole folders are moved, so files this script has never heard of come along with them;
#   - a path that is not there is reported and skipped; one already moved is left alone, so the
#     script can be run again;
#   - tracked files are moved with `git mv`, anything else with `mv`;
#   - nothing is committed, and nothing inside a record is edited. NOTES.md is cut in two at the
#     heading that opens the 0.4.2 cycle, and each half gets a title of its own; that is all.
#   - README.md, WITHHELD.md and the licence files stay where they are, and whatever else it
#     finds at the top or left in results/ is listed at the end for a person to place.
# --dry-run prints what it would do.

set -eu

dry=0
dir=.
for a in "$@"; do
    case "$a" in
        --dry-run) dry=1 ;;
        -h|--help) sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*) echo "unknown option $a" >&2; exit 2 ;;
        *) dir=$a ;;
    esac
done
cd "$dir"

if [ ! -d results ] && [ ! -d v0.4.2 ]; then
    echo "no results/ and no v0.4.2/ in $(pwd): this is not the top of the test records" >&2
    exit 2
fi

in_git=0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 && in_git=1

moved=0 already=0 absent=0 problems=0

say() { printf '%s\n' "$*"; }

tracked() {
    [ "$in_git" = 1 ] && [ -n "$(git ls-files -- "$1" 2>/dev/null | head -n 1)" ]
}

# move OLD NEW
move() {
    old=$1 new=$2
    if [ -e "$old" ] || [ -L "$old" ]; then
        if [ -e "$new" ] || [ -L "$new" ]; then
            say "PROBLEM  $old and $new both exist; left as they are"
            problems=$((problems + 1))
            return 0
        fi
        say "move     $old -> $new"
        moved=$((moved + 1))
        [ "$dry" = 1 ] && return 0
        mkdir -p "$(dirname "$new")"
        if tracked "$old"; then git mv -- "$old" "$new"; else mv -- "$old" "$new"; fi
    elif [ -e "$new" ] || [ -L "$new" ]; then
        say "done     $new (already moved)"
        already=$((already + 1))
    else
        say "absent   $old (not here; skipped)"
        absent=$((absent + 1))
    fi
}

# --- each wave's results become the candidate's folder ------------------------------------------
move results/rc1             v0.4.0/rc.1
move results/rc2-debug       v0.4.0/rc.2-debug
move results/rc2             v0.4.0/rc.2
move results/rc3             v0.4.0/rc.3
move results/v0.4.0          v0.4.0/release
move results/v0.4.2-rc.1     v0.4.2/rc.1
move results/v0.4.2-rc.2     v0.4.2/rc.2
move results/v0.4.2-rc.3     v0.4.2/rc.3
move results/v0.4.2-rc4-pre  v0.4.2/rc.4-pre
move results/v0.4.2-rc4      v0.4.2/rc.4
move results/v0.4.2-rc5-pre  v0.4.2/rc.5-pre
move results/v0.4.2-rc5      v0.4.2/rc.5
move results/v0.4.2          v0.4.2/release

# --- each plan goes beside its results ------------------------------------------------------------
move rc1.md               v0.4.0/rc.1/PLAN.md
move debug-host-start.md  v0.4.0/rc.2-debug/PLAN.md
move rc2.md               v0.4.0/rc.2/PLAN.md
move rc3.md               v0.4.0/rc.3/PLAN.md
move v0.4.0.md            v0.4.0/release/PLAN.md
move v0.4.2-rc.1.md       v0.4.2/rc.1/PLAN.md
move v0.4.2-rc.2.md       v0.4.2/rc.2/PLAN.md
move v0.4.2-rc.3.md       v0.4.2/rc.3/PLAN.md
move v0.4.2-rc.4.md       v0.4.2/rc.4/PLAN.md
move v0.4.2-rc.5.md       v0.4.2/rc.5/PLAN.md

# --- the parity set was made for 0.4.2's candidates -----------------------------------------------
move parity  v0.4.2/parity

# --- the rules the sessions work by (the public copy's name for them) -----------------------------
if [ -e TEST-SESSION-RULES.md ] || [ -e RULES.md ]; then
    move TEST-SESSION-RULES.md RULES.md
fi

# --- NOTES.md: one log per cycle -------------------------------------------------------------------
# The 0.4.2 cycle opens with this heading; everything before it is the 0.4.0 cycle (0.4.1 had no
# candidates and left no notes).
marker='^## 2026-11-14, main session: wave v0\.4\.2-rc\.1 written'
if [ -f NOTES.md ]; then
    if [ -e v0.4.0/NOTES.md ] || [ -e v0.4.2/NOTES.md ]; then
        say "PROBLEM  NOTES.md and a cycle's NOTES.md both exist; left as they are"
        problems=$((problems + 1))
    else
        n=$(grep -n -m 1 -E "$marker" NOTES.md | cut -d: -f1 || true)
        total=$(wc -l < NOTES.md | tr -d ' ')
        if [ -z "$n" ]; then
            say "PROBLEM  NOTES.md has no heading matching: $marker"
            say "         (split it by hand: v0.4.0/NOTES.md up to 2026-11-13, v0.4.2/NOTES.md from 2026-11-14)"
            problems=$((problems + 1))
        else
            say "split    NOTES.md: lines 1-$((n - 1)) -> v0.4.0/NOTES.md, lines $n-$total -> v0.4.2/NOTES.md"
            moved=$((moved + 1))
            if [ "$dry" = 0 ]; then
                mkdir -p v0.4.0 v0.4.2
                tmp0=$(mktemp) tmp2=$(mktemp)
                # First half: its title names the cycle; blank lines at the end are dropped.
                {
                    printf '# Notes between sessions: the 0.4.0 cycle\n'
                    sed -n "2,$((n - 1))p" NOTES.md
                } | awk '{ a[NR] = $0 } END { while (NR > 0 && a[NR] == "") NR--; for (i = 1; i <= NR; i++) print a[i] }' > "$tmp0"
                # Second half: a title and the same one-line rule, then the notes as they are.
                {
                    printf '# Notes between sessions: the 0.4.2 cycle\n\n'
                    printf 'Newest last. Date each note and name the machine. The notes of the cycle before are in\n'
                    printf '`../v0.4.0/NOTES.md`.\n\n'
                    sed -n "$n,\$p" NOTES.md
                } > "$tmp2"
                # The longer half keeps the file's history in git.
                if tracked NOTES.md; then git mv -- NOTES.md v0.4.2/NOTES.md; else mv -- NOTES.md v0.4.2/NOTES.md; fi
                cat "$tmp2" > v0.4.2/NOTES.md
                cat "$tmp0" > v0.4.0/NOTES.md
                rm -f "$tmp0" "$tmp2"
                [ "$in_git" = 1 ] && git add -- v0.4.0/NOTES.md v0.4.2/NOTES.md
            fi
        fi
    fi
elif [ -f v0.4.0/NOTES.md ] && [ -f v0.4.2/NOTES.md ]; then
    say "done     NOTES.md (already split)"
    already=$((already + 1))
else
    say "absent   NOTES.md (not here; skipped)"
    absent=$((absent + 1))
fi

# --- results/ should now be empty but for its placeholder ------------------------------------------
waves=' rc1 rc2-debug rc2 rc3 v0.4.0 v0.4.2-rc.1 v0.4.2-rc.2 v0.4.2-rc.3 v0.4.2-rc4-pre v0.4.2-rc4 v0.4.2-rc5-pre v0.4.2-rc5 v0.4.2 '
if [ -d results ]; then
    left=$(for e in results/* results/.[!.]*; do
        [ -e "$e" ] || continue
        b=${e#results/}
        case "$b" in .keep|.DS_Store) continue ;; esac
        # In a dry run the known waves are still there; they are not left over.
        if [ "$dry" = 1 ]; then case "$waves" in *" $b "*) continue ;; esac; fi
        printf '           %s\n' "$e"
    done)
    if [ -z "$left" ]; then
        say "remove   results/ (empty)"
        if [ "$dry" = 0 ]; then
            for f in results/.keep results/.DS_Store; do
                [ -e "$f" ] || continue
                if tracked "$f"; then git rm -q -- "$f"; else rm -f -- "$f"; fi
            done
            rmdir results 2>/dev/null || true
        fi
    else
        say "LEFT     in results/ (not a wave this script knows; place by hand):"
        say "$left"
        problems=$((problems + 1))
    fi
fi

# --- anything else at the top is for a person to place ---------------------------------------------
known=' README.md RULES.md WITHHELD.md MOVED.md LICENSE-MIT UNLICENSE audits tools results v0.4.0 v0.4.2 '
[ "$dry" = 1 ] && known="$known NOTES.md TEST-SESSION-RULES.md parity rc1.md rc2.md rc3.md v0.4.0.md debug-host-start.md v0.4.2-rc.1.md v0.4.2-rc.2.md v0.4.2-rc.3.md v0.4.2-rc.4.md v0.4.2-rc.5.md "
other=$(for e in * .[!.]*; do
    [ -e "$e" ] || continue
    case "$e" in .git|.gitignore|.gitattributes|.DS_Store) continue ;; esac
    case "$known" in *" $e "*) ;; *) printf '           %s\n' "$e" ;; esac
done)
if [ -n "$other" ]; then
    say "NOTE     at the top, not moved (new cycles go in a folder named after their tag, like v0.4.3/):"
    say "$other"
fi

say ""
say "moved or split: $moved; already in place: $already; not here: $absent; problems: $problems"
if [ "$dry" = 1 ]; then say "(dry run: nothing was changed)"; fi
[ "$problems" = 0 ]
