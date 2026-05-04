#!/bin/bash
# drink-water plugin — fires a reminder if more than $INTERVAL seconds have
# passed since the previous reminder. Default: 60 minutes.
# Override with DRINK_WATER_INTERVAL_SECONDS env var.

set -eu

INTERVAL="${DRINK_WATER_INTERVAL_SECONDS:-3600}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/drink-water-plugin"
STATE_FILE="$STATE_DIR/last-reminder"

mkdir -p "$STATE_DIR"

NOW=$(date +%s)
LAST=0
if [ -f "$STATE_FILE" ]; then
  LAST=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi

ELAPSED=$(( NOW - LAST ))

if [ "$ELAPSED" -lt "$INTERVAL" ]; then
  # Not time yet — exit silently, do nothing.
  exit 0
fi

echo "$NOW" > "$STATE_FILE"

# Pretty-print elapsed time since last reminder (for the very first run, LAST=0
# would yield a huge number, so suppress that case).
if [ "$LAST" -eq 0 ]; then
  HUMAN_ELAPSED="this session"
else
  MINUTES=$(( ELAPSED / 60 ))
  HUMAN_ELAPSED="${MINUTES} min"
fi

# JSON output is read by Claude Code:
#   - systemMessage  -> shown to the user in the UI
#   - additionalContext -> injected into Claude's context so it can nudge too
# We avoid a hard dependency on jq by hand-building the JSON (the strings are
# fixed, so escaping is not a concern).
cat <<JSON
{
  "systemMessage": "💧 Hydration check — drink some water (last reminder: ${HUMAN_ELAPSED} ago).",
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "Hydration reminder fired. If it feels natural, briefly remind the user to drink water before continuing."
  }
}
JSON
