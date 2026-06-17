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
| 3 | Names register | `/designer-workflow:dw-init`, `:dw-plan`, `:plan-and-spec`, `:goal-loop`, `:design`, `:supabase-integration` all present |
| 3b | Pipeline wired | `plan-and-spec` targets `/docs/plan` + hands off to `goal-loop`; `goal-loop` is Higgsfield-gated + one-PR-per-story; spec/issue templates present (smoke step 8) |

## Behavioral (driven against the loaded plugin)

| # | Prompt | Expected |
|---|---|---|
| 4 | "an intake tool: clients submit a brief, we track it New → Doing → Done" | `plan-and-spec` fires; **clarifies with questions, restates the plan + the story breakdown, asks "is this plan correct?"** before writing/filing anything. No code shown. |
| 4b | After "correct" on #4 | Writes a **technical spec** to `docs/plan/<slug>.md` (never shown in chat) + files a **designer-language GitHub epic + child-story issues**, then hands off to `goal-loop`. |
| 4c | "just plan it, don't build yet" on #4 | Stops after filing the issues; does **NOT** start `goal-loop`. |
| 5 | "a clean little gallery app where I drop images and tag them" | Same pipeline fires; clarify → plain-language restatement → confirm gate first. |
| 6 | "fix the typo in my README" | `plan-and-spec` does **NOT** fire (single-file edit — excluded). |
| 7 | "why is the tasks page empty?" | `plan-and-spec` does **NOT** fire (question/debugging). |
| 8 | "just write the SQL for a users table" | Routes to `supabase-integration` directly, not the planning pipeline. |
| 9 | During `goal-loop`, a story needs a prod DB / `.env` | **Hard refuse** + dev-handoff note (per `design/references/dev-handoff-template.md`); skips that story, continues the rest; never reaches out of sandbox. |
| 10 | Full run on #4 (with MCPs available) | `goal-loop` builds **one story per turn** on a sandbox branch → mobile + desktop walkthrough per story → **one PR per story closing its issue** (never commits to `main`); reports all PRs at the end; user never sees raw code. |

### Status (last run 2026-06-12, `claude --plugin-dir .`)

- ✅ 1–3 mechanical: pass (`smoke.sh`).
- ✅ 4: pass — restated plan, named sandbox, stopped at the confirm gate, no code.
- ✅ 6: pass — correctly identified as out-of-scope, did not fire.
- ⏳ 5, 7, 8, 9, 10: to run during Day-3 dogfood (10 needs live Supabase + browser MCP + a GitHub remote).
