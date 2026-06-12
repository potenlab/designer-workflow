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
for name in "designer-workflow:dw-init" "designer-workflow:design" "designer-workflow:supabase-integration"; do
  echo "$OUT" | grep -q "$name" && echo "  ok: $name" || { echo "  MISSING: $name"; exit 1; }
done

echo "All smoke checks passed."
