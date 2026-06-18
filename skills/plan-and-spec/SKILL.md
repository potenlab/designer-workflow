---
name: plan-and-spec
description: "You MUST use this before ANY change to the project's code or UI — building something new, OR editing, restyling, tweaking, fixing, or refactoring anything that already exists — before you touch any file. Clarifies the change through questions, writes a technical spec to /docs/plan, and ALWAYS files a GitHub issue with gh, then hands off to goal-loop to build. Skip ONLY for pure questions, explanations, or read-only code review with no change."
metadata:
  author: dev@potenlab.dev
  version: "0.1.0"
  date: 2026-06-17
  status: v1
  reuses: kg-context-dispatch, AskUserQuestion, goal-loop, design, commit-commands
---

# plan-and-spec — agree the plan, write the spec, file the issues

A **designer or PM** describes an app or feature. Before anything gets built, you **clarify the idea
with questions**, **restate it for approval**, and only then produce two artifacts and hand off:

- a **technical spec** at `/docs/plan/<slug>.md` (engineer language — the build contract), and
- a **GitHub epic + child-story issues** (designer/product language — the tracking artifact).

> **The defining rule (same as the whole plugin): think as an engineer, speak as a designer/PM.**
> The chat stays plain-language. Technical detail lives ONLY in the spec file. The issues are written
> in product language a PM can read — user stories and plain acceptance criteria, never SQL or paths.

This is the **planning phase**. It **never builds, never writes code, never generates assets.** It
**stops** after the spec + issues exist and hands off to **`goal-loop`** only when the user confirms
the plan is correct.

---

## 0. Gate before you act

### 0a. Does this even apply? (scope gate — broad by design)

Run this skill before **ANY change to the project's code or UI** — whether you are building something
new OR editing, restyling, tweaking, fixing, refactoring, or extending something that already exists.
**If the work will touch a file, plan it here FIRST.** Signals (all of these go through planning):
"make me a tool…", "add a feature…", "restyle this tab", "change the header", "move this button",
"fix this bug", "tidy up this screen", "refactor X".

**Skip it ONLY when the request makes no change to code/UI at all:**

- A pure question, an explanation, or a code review with no edit.
- Read-only investigation ("why is this empty?", "where is X defined?", "explain this file").

Everything that modifies the project goes through planning first — **even a one-line restyle.** The
plan scales to the work: a small focused change gets a short spec and a **single** GitHub issue; new
or large work gets a spec plus an **epic + child stories**. Either way you **ALWAYS file at least one
GitHub issue** (§④). When you catch yourself about to "just make the change directly" — stop, that is
exactly the case this gate exists for.

### 0b. Higgsfield is NOT gated here

Planning writes no assets, so it does **not** require Higgsfield. (The hard Higgsfield gate kicks in
later, at build time, inside `goal-loop` / `design`.) Do not block planning on a Higgsfield sign-in.

### 0c. Read the project config

Read `.designer-workflow/config.md` if it exists (written by `/designer-workflow:dw-init`) — it tells
you **where sandbox apps live** and the **off-limits / production boundary**. The spec must respect
this boundary. If it's missing, note it once and suggest running `/designer-workflow:dw-init`.

## 1. The flow

```
① CLARIFY   pin the change — SCALE TO SIZE (small: 0–1 quick Qs; new/large: data, users, flows)
② SPEC      write the spec → /docs/plan/<slug>.md (short for a small change)
③ ISSUE     file the GitHub issue(s) with gh:
            • small focused change → ONE tracking issue
            • new / large work     → an epic + one child issue per story
④ VERIFY    show the user the FILED issue(s) + link → "Is this issue correct? Start building?"
   ↓ yes  ← THE GATE: nothing builds before the user confirms the filed issue
⑤ HANDOFF  trigger goal-loop to build (small change → quick/direct build; large → full loop)
```

**Two rules that shape everything:**

- **Scale to the work.** A one-tab restyle gets one quick clarifying round (or none), a short spec, and
  ONE issue — never a four-story epic. A whole new app gets the full breakdown. Don't over-process small
  changes; just move fast through ②③④ and build.
- **The gate is ④, AFTER the issue is filed.** You file the issue first, then show it to the user and
  get an explicit yes before triggering `goal-loop`. Never start building on an unverified issue. Never
  skip ②, ③, or ④ — even a small change gets a spec entry, a filed issue, and the user's okay.

Never skip ① or ②. The confirmation in ② is the **single human gate** for the whole pipeline.

### ① Clarify — scale to the size of the change

Pin down only what you genuinely can't assume, then stop. **Match the effort to the change:**

- **Small change** (a restyle, a copy tweak, a one-component fix): usually **zero or one** quick
  question — or none if it's obvious. Don't interrogate the user over a button color or a header tweak.
- **New / large work** (a new app or a real feature): use **AskUserQuestion** to pin the essentials —
  who uses it and do different people see different things (drives auth/RLS), what it stores, the one
  main flow, and what's in/out of scope.

For your **own** situational awareness you may invoke **kg-context-dispatch** to understand the
existing tree and the blast radius. Never surface KG / `touch_budget` / "blast radius" to the user.

Stop asking the moment you can write the spec — for a small change that's immediately.

### ② Write the technical spec → `/docs/plan/<slug>.md`

Write the spec — the **one place engineer language belongs** in this phase (a file, not chat). `<slug>`
is a kebab-case name of the change (e.g. `community-tab-restyle`, `brief-intake-tracker`). Create
`/docs/plan/` if it doesn't exist. Follow **`references/spec-template.md`**, and **scale it to the
work**:

- **Small change** → a short spec: what changes, where, and the acceptance criteria. A few lines is fine.
- **New / large work** → the full spec: data model, auth & RLS, types, routes, edge cases, the sandbox
  boundary, and a **story → implementation map** so each child issue points at its spec section.

Do **not** show the spec contents in chat. Just say, plainly, "I've written up the technical plan."

### ③ File the GitHub issue(s) with `gh`

Use the **`gh` CLI**. Check a remote exists (`gh repo view`). If there's **no GitHub remote**, don't
fail silently — tell the user and write the breakdown into the spec as a checklist instead. **Always
file at least one issue**, sized to the work (`references/issue-templates.md`):

- **Small focused change** → **ONE** issue (label `change`): what changes + plain acceptance criteria.
- **New / large work** → an **epic** (`epic`) + **one child issue per story** (`story`), linked back to
  the epic by number.

Issue bodies are **designer/product language** — user stories and plain acceptance criteria. **No SQL,
no file paths, no schema, no migration talk**; they link to the spec via a small note.

### ④ Verify the filed issue with the user — THE GATE

After the issue exists, **show it to the user and get an explicit okay before anything is built.** Paste
the issue title, a one- or two-line plain-language summary, and the link, then ask:

> "I've filed the issue: **<title>** → <link>. In plain terms: <1–2 lines of what it covers>.
> **Is this correct — should I start building it?**"

- Wait for an explicit **yes**. This is the **single human gate — nothing builds before it.**
- If it's **wrong**, fix it: `gh issue edit` the body (or `gh issue close` and refile), then re-confirm.
  Never build on an issue the user hasn't blessed.
- If the user says "just file it, don't build yet," **stop here** — the issue stands, no `goal-loop`.
- For an epic + children, show the **epic** (with its checklist) and confirm the set, not every child
  separately.

### ⑤ Hand off to goal-loop

On the user's **yes at ④**, **invoke the `goal-loop` skill** with the `Skill` tool to build. **Scale
the build to the change:**

- **Small change** → build it quickly and directly (one short story), verify it in the browser, open
  one PR. Don't spin up heavy multi-story machinery for a one-tab restyle.
- **New / large work** → goal-loop walks the child stories one per turn (build → verify → one PR each).

Announce it plainly: "Great — building it now. I'll show you it running before I open it for review."

## 2. Persona rules (non-negotiable)

- **Never show raw code, SQL, file paths, the spec's contents, or migrations in chat.** Translate to
  product language. The spec file carries the technical detail; the chat stays plain.
- **Issues are designer language.** A PM reads them; an engineer reads the spec the issue links to.
- One plain-language confirmation (④, **after** the issue is filed) gates the build — show the real
  GitHub issue and get a yes before `goal-loop`. Don't add extra gates; don't bury the user in detail.
- Respect the **sandbox boundary** from `.designer-workflow/config.md` when writing the spec — if a
  story would need out-of-sandbox / production access, say so in the spec and flag it for a dev rather
  than speccing a boundary breach.

## 3. Acceptance — this skill is "done" for a request when it

1. **Auto-triggers** on ANY code/UI change (build, edit, restyle, fix) — quiet only on pure
   questions/explanations/read-only review.
2. **Scales to size** — a small change gets ~0–1 quick questions, a short spec, and ONE issue; new/large
   work gets the full clarify + spec + epic.
3. Writes a **technical** spec to `/docs/plan/<slug>.md` (never shown in chat).
4. **Always files at least one GitHub issue** with `gh` — a single `change` issue for small work, an
   `epic` + `story` children for large (or a spec checklist if there's no remote).
5. **Verifies the filed issue with the user (the gate)** — shows the real issue + link and waits for an
   explicit yes **before** building.
6. **Hands off to `goal-loop`** only on that yes — and scales the build (quick/direct for a small change,
   full loop for large). Unless the user asked to file only.

See `references/spec-template.md` and `references/issue-templates.md`.
