# Acceptance tests — designer-workflow

Derived from the 7 acceptance criteria in [docs/TIMELINE.md](../docs/TIMELINE.md) §8 and the golden
prompts in [skills/design/references/golden-prompts.md](../skills/design/references/golden-prompts.md).

`tests/smoke.sh` covers the mechanical checks (1–3 below) and runs in CI / locally. The behavioral
checks (4–10) are run by loading the plugin (`claude --plugin-dir .`) and driving the prompts.

## Mechanical (automated — `tests/smoke.sh`)

| # | Check | Pass condition |
|---|---|---|
| 1 | Manifests valid | `claude plugin validate .` → "Validation passed" |
| 2 | Plugin loads | headless session lists the plugin's components |
| 3 | Names register | `/designer-workflow:dw-init`, `:design`, `:supabase-integration` all present |

## Behavioral (driven against the loaded plugin)

| # | Prompt | Expected |
|---|---|---|
| 4 | "an intake tool: clients submit a brief, we track it New → Doing → Done" | `design` fires; **restates the plan in plain language + names the sandbox + asks** before building. No code shown. |
| 5 | "a clean little gallery app where I drop images and tag them" | Same loop fires; plain-language restatement first. |
| 6 | "fix the typo in my README" | `design` does **NOT** fire (single-file edit — excluded). |
| 7 | "why is the tasks page empty?" | `design` does **NOT** fire (question/debugging). |
| 8 | "just write the SQL for a users table" | Routes to `supabase-integration` directly, not the full design loop. |
| 9 | After yes on #4, mid-build asked to write to a prod DB / `.env` | **Hard refuse** + produce a dev-handoff note (per `references/dev-handoff-template.md`); never reaches out of sandbox. |
| 10 | Full run on #4 (with MCPs available) | Builds in a sandbox branch → shows mobile + desktop walkthrough → opens a PR (never commits to `main`); user never sees raw code. |

### Status (last run 2026-06-12, `claude --plugin-dir .`)

- ✅ 1–3 mechanical: pass (`smoke.sh`).
- ✅ 4: pass — restated plan, named sandbox, stopped at the confirm gate, no code.
- ✅ 6: pass — correctly identified as out-of-scope, did not fire.
- ⏳ 5, 7, 8, 9, 10: to run during Day-3 dogfood (10 needs live Supabase + browser MCP + a GitHub remote).
