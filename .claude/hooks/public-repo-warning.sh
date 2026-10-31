#!/usr/bin/env bash
# Warn before anything is pushed or written to this PUBLIC repository.
# Runs as a Claude Code PreToolUse hook. Asks the user to confirm instead of
# letting the push/write go through silently.
input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // ""')
hit=""

if [ "$tool" = "Bash" ]; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
  if printf '%s' "$cmd" | grep -Eq '(^|[^[:alnum:]_-])git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+push([[:space:]]|$)'; then
    hit="git push"
  fi
else
  repo=$(printf '%s' "$input" | jq -r '.tool_input.repo // ""' | tr '[:upper:]' '[:lower:]')
  if [ "$repo" = "ncalaelen.github.io" ]; then
    hit="$tool"
  fi
fi

[ -z "$hit" ] && exit 0

msg="⚠️ PUBLIC REPOSITORY: ncalaelen/ncalaelen.github.io is public and served on GitHub Pages. Anything pushed here ($hit) is visible to anyone on the internet. Confirm only if nothing private or sensitive is included."
jq -n --arg m "$msg" '{
  systemMessage: $m,
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: $m
  }
}'
