#!/bin/sh
# goto-workspace-term.sh — switch to a workspace, open kitty if it is empty.
#
# Usage: goto-workspace-term.sh <workspace identifier>
#   e.g. goto-workspace-term.sh "number 1"   (what "$ws1" expands to)
#        goto-workspace-term.sh 1
#
# Behavior:
#   1. Switches to the given workspace via swaymsg.
#   2. Counts windows on the now-focused workspace.
#   3. If empty, launches kitty with cwd logic matching $term_cwd
#      (kitty --directory "$(swaycwd 2>/dev/null || echo $HOME)").
#   Never spawns a terminal when the workspace already has windows.

set -u

if [ $# -eq 0 ]; then
    echo "usage: $(basename "$0") <workspace>" >&2
    exit 1
fi

# Join all args so both `1` and `"number 1"` forms work.
WS="$*"

# Switch first; swaymsg IPC is synchronous so the switch has
# completed when this returns.
swaymsg workspace "$WS" >/dev/null 2>&1 || exit 1

COUNT=""

# Primary check: window count of the focused workspace.
# get_workspaces tells us the focused workspace's node id; get_tree is
# then searched for that node and every real window below it. Real
# windows are objects carrying app_id (Wayland) or window_properties
# (XWayland). NOTE: we must NOT match `.focused == true` inside
# get_tree — this sway build never sets it on workspace nodes (focus
# lives in the `focus` id chains), so that naive filter always yields 0.
if command -v jq >/dev/null 2>&1; then
    FOCUSED_ID=$(swaymsg -t get_workspaces 2>/dev/null | jq '
        ([.[] | select(.focused == true)][0].id // empty)
    ')
    if [ -n "$FOCUSED_ID" ] && [ "$FOCUSED_ID" != "null" ]; then
        COUNT=$(swaymsg -t get_tree 2>/dev/null | jq --argjson id "$FOCUSED_ID" '
            [.. | objects | select(.id == $id)
             | .. | objects
             | select(.app_id != null or .window_properties != null)]
            | length
        ')
    fi
fi

# Fallback: older sway builds expose a numeric "windows" count on
# get_workspaces. Only trust it when it is actually a number; a missing
# (null) field must NOT default to 0, or we would spawn on occupied
# workspaces.
if [ -z "$COUNT" ] || [ "$COUNT" = "null" ]; then
    WINS=$(swaymsg -t get_workspaces 2>/dev/null | jq '
        ([.[] | select(.focused == true)][0].windows // empty)
    ')
    case "$WINS" in
        ''|'null') COUNT="" ;;
        *) COUNT="$WINS" ;;
    esac
fi

# If we still cannot tell, do nothing (safer than spawning blindly).
case "$COUNT" in
    ''|*[!0-9]*) exit 0 ;;
esac

if [ "$COUNT" -eq 0 ]; then
    kitty --directory "$(swaycwd 2>/dev/null || echo "$HOME")" >/dev/null 2>&1 &
    disown 2>/dev/null || true
fi
