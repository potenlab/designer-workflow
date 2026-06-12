# Designer Workflow — Timeline & Spec

> A **`design` skill** that lets a **designer or PM** **create a whole application** in design/business
> language, while Claude does the **engineer's thinking** underneath (idea → data model → backend →
> UI → running app → PR). It **auto-triggers** on intent — the user never types a command and never
> reads code. They describe the app they want and judge it by using it.

**Status:** proposal — pending team sign-off (DionNam, Raka).
**Owner:** dev@potenlab.dev
**Date:** 2026-06-12

---

## 1. Why

A designer or PM can describe an **application** they want — "a simple tool where clients upload a
brief and we track it to done" — but every existing workflow assumes they'll then act like an engineer:

| Current workflow | Hidden assumption a designer/PM doesn't have |
| --- | --- |
| **kg-workflow** (side-effect warning) | Knows what `touch_budget`, "blast radius", a file tree mean |
| **claude-chrome** (verify changes) | Knows to read a diff and reason about regressions |
| **frontend-design + higgsfield** (design parts) | Knows which component to edit and where assets go |

The goal is **not new tooling** and **not a new command to memorize**. It's a **translation skin**
over what we already have that **switches itself on**. The user describes an **application** in plain
language; the skill recognizes the intent, **thinks as a full-stack engineer** underneath (data model,
backend, UI, wiring) but **responds as a designer/PM** — it only ever shows a **working app** and
plain language, never code.

## 2. Locked decisions

| Decision | Choice | Consequence |
| --- | --- | --- |
| **Scope** | **Create an application** (not edit a component) | Full-stack: the skill scaffolds data + backend + UI as one coherent app, end to end. |
| **Activation** | **Auto-trigger, no slash command** | The skill carries strong intent triggers in its `description`; Claude invokes it automatically when a user describes an app/design. Users never type `/design`. |
| **Install scope** | **Global (user-level) + optional per-project** | Drop it in `~/.claude/skills/` and it works on every project that user opens. A team can also commit it to a repo's `.claude/skills/` so the project ships with it. |
| **Autonomy** | Auto-PR, **no preview deploy** | The PR *is* the deliverable. An embedded screen recording / screenshots of the running app are how the user + dev both judge it. No preview infra. |
| **Persona** | **Designer + PM** | Think as engineer, respond as designer/PM. One non-technical vocabulary for describing apps and product intent. |

## 3. How activation works

The skill is a folder of instructions + a sharp `description` field. Two install paths, same behavior:

- **Per-user (global):** placed in `~/.claude/skills/` → active across **all** projects that user opens.
- **Per-project:** committed to a repo's `.claude/skills/` → ships with that project for the whole team.

Either way, **there is no command**. When the user writes something like *"make me a little tool
that…"* or *"I want an app where…"*, Claude reads the skill's trigger description, recognizes the
app-creation intent, and runs the design loop on its own. Tuning that trigger so it fires on real
designer/PM phrasing (and **not** on unrelated requests) is the core of Day 1.

## 4. Building blocks (all ready ✅)

| Need | Reuse | Status |
| --- | --- | --- |
| Map intent → app structure + blast radius | `kg-context-dispatch` (kg-workflow) | ✅ ready |
| Plain-language design + UI build | `frontend-design`, `impeccable` skills | ✅ ready |
| **Secure backend (data + auth)** | **`supabase-integration` skill + Supabase MCP** | ✅ ready |
| Run the app + visual verification | `claude-in-chrome` / `chrome-devtools` MCP, `verify` skill | ✅ ready |
| Asset generation | `higgsfield` MCP (brand-locked presets) | ✅ ready |
| PR handoff | `commit-commands:commit-push-pr`, `qa-check` | ✅ ready |

Every dependency is installed. Day 1 is **assembly + trigger tuning + guardrails**, not building infrastructure.

> **Backend = Supabase, done right the first time.** The `supabase-integration` skill
> (`~/.claude/skills/mine/supabase-integration/`) gives every created app a working Postgres backend
> with RLS-on-by-default, proper auth, MCP-driven migrations, and type-safe client wiring — then
> reports back to the designer/PM in plain language. It embeds the official `supabase/agent-skills`
> best practices and drives everything through the Supabase MCP.

## 5. Timeline

**Critical path = 3 days. Usable MVP (Day 1–2) end of Day 2; dogfood Day 3.**

| Day | Ships |
| --- | --- |
| **Day 1 — Spec, triggers, guardrails & scaffold** | ~6 golden designer/PM **app-idea** prompts → acceptance tests. `design` skill scaffold with a **tuned auto-trigger `description`** (fires on app/design intent, stays quiet otherwise). Plain-language plan restatement before acting. Isolated app workspace per session + hard sandbox enforcement + plain-language side-effect gate. |
| **Day 2 — Build, run-verify & PR** | Full-stack scaffold inside the sandbox: **Supabase backend via `supabase-integration`** (schema + RLS + auth + typed client, verified with `get_advisors`) + UI. Run the app and capture a working walkthrough (mobile + desktop) via chrome MCP. Higgsfield brand-locked assets, auto-placed. Auto-PR with human summary + embedded screenshots *(no preview infra)*. |
| **Day 3 — Dogfood & install** | Run golden prompts with Minjae + a PM prompt set **without telling them a command** — confirm it auto-fires. Capture friction, tune triggers + widen the sandbox where safe, document the one-step install (global vs per-project), lock v1. |

## 6. The guardrail IS the product (Day 1 detail)

Because the skill now builds **full applications** (data + backend included), the guardrail is no longer
"never touch the backend" — it's **isolation**. The single biggest failure mode: an app-creation
prompt that reaches **out of its sandbox** and silently mutates an existing production app, its
database, secrets, or billing/auth. (Auto-activation makes this *more* important, not less — the skill
fires without an explicit command, so the boundary must hold on its own.)

- ✅ **Allowed:** everything **inside the new app's own workspace/branch** — its data model, backend,
  UI, assets, config.
- 🚫 **Forbidden (hard refuse):** touching **other** apps/repos, production databases & migrations,
  shared secrets/`.env*`, auth/billing of existing systems, the `.understand-anything*/` KG files.

If creating the app *requires* a change outside its sandbox, the skill **stops** and says, in plain
language:

> "This needs a developer — it connects to our real customer data. I've written up what's needed for Raka."

…then produces a dev-handoff note **instead of reaching out of the sandbox**.

## 7. The user's loop (designer or PM — no command)

```
User (designer): "a clean little gallery app where I drop images and tag them"
User (PM):       "an intake tool: clients submit a brief, we track it New → Doing → Done"
   │  (no /command — the skill recognizes the intent and switches on)
   ▼
design   ① restates the app plan in plain language
         "You want a brief-intake tracker. It stores briefs and their status.
          It lives in its own sandbox — nothing touches our live data. Go ahead?"
   │  (User: yes)
   ▼
         ② builds the full app on an isolated branch (sandbox only)
         ③ runs it and shows a working walkthrough — mobile + desktop
   │  (User: looks good / "make the status colors calmer")
   ▼
         ④ opens a PR with the recording/screenshots + a human summary for the dev
```

The engineer reasoning (data model, backend, KG context, blast radius, isolation checks) runs the
whole time — but the user only ever sees plain language and a working app, and never had to invoke a
command.

## 8. Acceptance (derived from Day 1 golden prompts)

The skill is "done for v1" when, across the ~6 golden designer/PM app-idea prompts, it:

1. **Auto-triggers on app/design intent** without a slash command — and stays quiet on unrelated asks.
2. Builds a **runnable** application from a plain-language description.
3. Stays inside its sandbox — refuses to touch other apps / production data, + writes a handoff note.
4. Always restates the app plan in plain language before building.
5. Always shows the **running app** (mobile + desktop) before opening the PR.
6. Always lands on an isolated branch and opens a PR (never commits to `main`).
7. Never shows the user raw code unless asked.

## 9. Open inputs needed from the team

- [ ] 5–6 real example **app ideas** a designer **and** a PM would actually type (seeds the golden set + tunes the trigger).
- [ ] Default install scope — global per-user for everyone, or committed per-project?
- [ ] Where do new sandbox apps live? (subfolder in a repo vs. a fresh repo per app.)
- [ ] Confirm the isolation boundary against the real tree (what's "production" and off-limits).
- [ ] Which viewports matter beyond mobile + desktop? (tablet?)

## 10. Next step

Kick off **Day 1**: gather the golden app-idea prompts (designer + PM), **draft + tune the
auto-trigger `description`**, decide where sandbox apps live, draw the isolation boundary, and scaffold
the `design` skill.
