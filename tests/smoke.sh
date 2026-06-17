#!/usr/bin/env bash
# Smoke test for the designer-workflow plugin.
# Validates the manifests and confirms the plugin loads with its command + skills.
# Usage:  ./tests/smoke.sh
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "Plugin dir: $PLUGIN_DIR"

echo "== 1. Validate manifests =="
claude plugin validate "$PLUGIN_DIR"

echo "== 2. Load plugin headless and list its commands/skills =="
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
( cd "$TMP" && git init -q )
OUT="$(cd "$TMP" && claude --plugin-dir "$PLUGIN_DIR" \
  -p "List ONLY the slash commands and skills the designer-workflow plugin provides, by exact invocation name. Terse." \
  --output-format text 2>&1)"
echo "$OUT"

echo "== 3. Assert expected names are present =="
# Tolerant of how the model formats the list: "designer-workflow:NAME" or "/NAME".
# Exact-match the name (word-boundary, not followed by '-') so "supabase" doesn't match
# "supabase-integration".
for name in "dw-init" "dw-plan" "plan-and-spec" "goal-loop" "design" "supabase-integration" "supabase" "supabase-postgres-best-practices" "using-designer-workflow" "higgsfield-assets" "verify-in-browser"; do
  if echo "$OUT" | grep -qE "(designer-workflow:|/|\`)${name}([^-a-z]|\`|$)"; then
    echo "  ok: $name"
  else
    echo "  MISSING: $name"; exit 1
  fi
done

echo "== 4. Validate auto-activation hook (superpowers-style SessionStart injection) =="
HOOKS="$PLUGIN_DIR/hooks/hooks.json"
[ -f "$HOOKS" ] || { echo "  MISSING: hooks/hooks.json"; exit 1; }
python3 -c "
import json
d=json.load(open('$HOOKS'))['hooks']
ss=d['SessionStart'][0]
assert 'compact' in ss['matcher'], 'matcher must include compact so the rule survives context loss'
assert 'run-hook.cmd' in ss['hooks'][0]['command']
assert ss['hooks'][0].get('async') is False
print('  ok: hooks.json SessionStart-only, matcher='+ss['matcher']+', async=false')
"
for f in "hooks/session-start" "hooks/run-hook.cmd"; do
  [ -x "$PLUGIN_DIR/$f" ] || { echo "  MISSING/not executable: $f"; exit 1; }
  echo "  ok: $f present + executable"
done

echo "== 5. session-start emits valid context-injection JSON with the dispatcher skill =="
HOOK_JSON="$(CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" bash "$PLUGIN_DIR/hooks/run-hook.cmd" session-start)"
echo "$HOOK_JSON" | python3 -c "
import json,sys
d=json.load(sys.stdin)
ac=d['hookSpecificOutput']['additionalContext']
assert 'using-designer-workflow' in ac and 'Skill catalog' in ac, 'dispatcher skill not injected'
assert 'HARD-GATE-HIGGSFIELD' in ac, 'Higgsfield gate not injected by the hook'
print('  ok: injects using-designer-workflow dispatcher ('+str(len(ac))+' chars) + Higgsfield gate')
"

echo "== 6. Higgsfield is bundled + hard-gated =="
MCPJSON="$PLUGIN_DIR/.mcp.json"
[ -f "$MCPJSON" ] || { echo "  MISSING: .mcp.json (Higgsfield must be bundled)"; exit 1; }
python3 -c "
import json
s=json.load(open('$MCPJSON'))['mcpServers']['higgsfield']
assert s['type']=='http' and s['url']=='https://mcp.higgsfield.ai/mcp', s
print('  ok: .mcp.json bundles higgsfield ('+s['url']+')')
"
grep -q 'HARD-GATE-HIGGSFIELD' "$PLUGIN_DIR/skills/using-designer-workflow/SKILL.md" \
  && echo "  ok: dispatcher carries the Higgsfield hard gate" \
  || { echo "  MISSING: Higgsfield gate in dispatcher skill"; exit 1; }
grep -qi 'Higgsfield access check' "$PLUGIN_DIR/skills/design/SKILL.md" \
  && echo "  ok: design skill verifies Higgsfield before building" \
  || { echo "  MISSING: Higgsfield precheck in design skill"; exit 1; }

echo "== 7. Persona + verify-every-development rules =="
DISP="$PLUGIN_DIR/skills/using-designer-workflow/SKILL.md"
grep -qi 'think as a developer, respond as a designer/PM' "$DISP" \
  && echo "  ok: dispatcher carries the global persona rule" \
  || { echo "  MISSING: persona rule in dispatcher"; exit 1; }
grep -qi 'Verify every development' "$DISP" \
  && echo "  ok: dispatcher mandates verify-in-browser for every development" \
  || { echo "  MISSING: verify-every-development rule in dispatcher"; exit 1; }
grep -qi 'claude-in-chrome\|Claude Chrome extension' "$PLUGIN_DIR/skills/verify-in-browser/SKILL.md" \
  && echo "  ok: verify-in-browser uses the Claude Chrome extension" \
  || { echo "  MISSING: Claude Chrome extension in verify-in-browser"; exit 1; }

echo "== 8. Planning pipeline: plan-and-spec → goal-loop wiring =="
PS="$PLUGIN_DIR/skills/plan-and-spec/SKILL.md"
GL="$PLUGIN_DIR/skills/goal-loop/SKILL.md"
[ -f "$PS" ] || { echo "  MISSING: plan-and-spec/SKILL.md"; exit 1; }
[ -f "$GL" ] || { echo "  MISSING: goal-loop/SKILL.md"; exit 1; }
grep -qi 'docs/plan' "$PS" \
  && echo "  ok: plan-and-spec writes a technical spec to /docs/plan" \
  || { echo "  MISSING: /docs/plan spec target in plan-and-spec"; exit 1; }
grep -qi 'goal-loop' "$PS" \
  && echo "  ok: plan-and-spec hands off to goal-loop on confirmation" \
  || { echo "  MISSING: goal-loop handoff in plan-and-spec"; exit 1; }
grep -qi 'one PR per story\|one PR for this story' "$GL" \
  && echo "  ok: goal-loop opens one PR per story" \
  || { echo "  MISSING: one-PR-per-story rule in goal-loop"; exit 1; }
grep -qi 'HARD-GATE\|hard-gate\|Higgsfield hard-gate' "$GL" \
  && echo "  ok: goal-loop carries the Higgsfield hard gate at build time" \
  || { echo "  MISSING: Higgsfield gate in goal-loop"; exit 1; }
for f in "skills/plan-and-spec/references/spec-template.md" "skills/plan-and-spec/references/issue-templates.md"; do
  [ -f "$PLUGIN_DIR/$f" ] && echo "  ok: $f present" || { echo "  MISSING: $f"; exit 1; }
done

echo "All smoke checks passed."
