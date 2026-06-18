---
name: plan-and-spec
description: "You MUST use this before building any app, tool, site, dashboard, tracker, intake, or new feature — before writing any code. Turns the request into an agreed plan: clarifies the idea through questions, writes a technical spec, and files designer-language GitHub issues, then hands off to goal-loop to build. Skip only for bug fixes, questions, code review, or single-file edits."
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

### 0a. Does this even apply? (intent gate)

Run this skill **only** when the user is asking to **create an app or a feature** (a new runnable
thing, or a new capability in one). Signals: "make me a tool/app/site that…", "I want something
where…", "build a tracker/gallery/intake/dashboard for…", "add a feature where…".

**Do not run** (handle normally, no planning skin) when the request is:

- Editing or restyling **one existing** component/page ("make this button calmer").
- A bug fix, a question, a code review, a refactor of existing code.
- An explicit single-layer ask ("just write the SQL", "only the React component").

When unsure, **ask one plain-language question**: *"Do you want me to plan this out as its own thing —
write it up and break it into pieces — or just make a quick change to what we already have?"*

### 0b. Higgsfield is NOT gated here

Planning writes no assets, so it does **not** require Higgsfield. (The hard Higgsfield gate kicks in
later, at build time, inside `goal-loop` / `design`.) Do not block planning on a Higgsfield sign-in.

### 0c. Read the project config

Read `.designer-workflow/config.md` if it exists (written by `/designer-workflow:dw-init`) — it tells
you **where sandbox apps live** and the **off-limits / production boundary**. The spec must respect
this boundary. If it's missing, note it once and suggest running `/designer-workflow:dw-init`.

## 1. The flow

```
① CLARIFY   ask questions until the idea is pinned (data, users, flows, scope)
② PREVIEW   restate the plan + epic/story breakdown in plain language
            → ONE confirmation: "Is this plan correct?"
   ↓ yes
③ SPEC      write the TECHNICAL spec → /docs/plan/<slug>.md
④ ISSUES    create the GitHub epic + one child issue per story (designer language)
⑤ HANDOFF   on the same "yes", trigger goal-loop to build it autonomously
```

Never skip ① or ②. The confirmation in ② is the **single human gate** for the whole pipeline.

### ① Clarify (use AskUserQuestion)

You can't write a good spec from a one-line request. Use the **AskUserQuestion** tool to pin down what
you genuinely can't assume — keep questions in plain language, group them, and don't interrogate:

- **Who uses it** and do different people see different things? (drives auth + RLS later)
- **What it stores** — the core "things" and their important fields.
- **The main flow** — the one path that has to work end to end.
- **Scope for v1** — what's in, what's explicitly out (so the breakdown is bounded).

For your **own** situational awareness, you may invoke **kg-context-dispatch** to understand the
existing tree and the sandbox blast radius. Never surface KG / `touch_budget` / "blast radius"
language to the user.

Stop asking once you can write the breakdown. One or two rounds is usually enough.

### ② Preview + confirm (the one gate)

Restate, in **plain language**, what you heard and how you'd break it into stories:

> "Here's what I've got. A **brief-intake tracker**: clients submit a brief, your team moves it
> New → Doing → Done, and people only see their own team's. I'd build it as:
> • **Submit a brief** — a client fills a short form and it's saved.
> • **See the board** — briefs show up in New / Doing / Done.
> • **Move a brief** — drag/advance a brief between stages.
> • **Only-my-team** — sign in, and you only see your team's briefs.
> It lives in its own sandbox — nothing here touches our live data. **Is this plan correct?**"

- Wait for an explicit **yes**. It's cheap to fix the plan here, expensive after issues are filed.
- This single confirmation authorizes **all** of: writing the spec, filing the issues, AND starting
  the build loop. Do not file anything or build anything before it.
- If they change something, re-state and re-confirm. Don't proceed on a "maybe".

### ③ Write the technical spec → `/docs/plan/<slug>.md`

After the yes, write the spec. This is the **one place engineer language belongs** in this phase — it
is a file, not chat. Pick `<slug>` as a kebab-case name of the app/feature (e.g.
`brief-intake-tracker`). Create `/docs/plan/` if it doesn't exist.

Follow **`references/spec-template.md`**. It must cover: data model, auth & RLS model, types, the
route/API shape, edge cases & error states, the sandbox boundary it stays inside, and a
**story → implementation map** so each GitHub child issue points at its section of the spec.

Do **not** show the spec contents in chat. Tell the user it exists in plain language ("I've written
up the technical plan").

### ④ Create the GitHub issues (designer language)

Use the **`gh` CLI**. First check a remote exists (`git remote -v` / `gh repo view`). If there's **no
GitHub remote**, don't fail silently — tell the user in plain language and write the breakdown into the
spec file as a checklist instead, so nothing is lost.

Create, following **`references/issue-templates.md`**:

- **One epic issue** — the product vision in plain language + a task-list checklist linking each child.
  Label it `epic`.
- **One child issue per story** — a single user story with **plain-language acceptance criteria**,
  linked back to the epic, and a pointer to its spec section. Label each `story`.

These are **designer/product language**: user stories and acceptance criteria a PM can read. **No SQL,
no file paths, no schema, no migration talk** in the issue bodies. Keep the epic↔child links intact
(the epic's checklist references each child by number).

### ⑤ Hand off to goal-loop

On the **same confirmation** from ②, after the spec + issues exist, **invoke the `goal-loop` skill**
with the `Skill` tool to build the stories autonomously, one per turn. Announce it in plain language:

> "Plan's locked and broken into pieces. I'll start building it now, story by story, and show you each
> one running before I open it for review."

If the user said "just plan it, don't build yet," **respect that** — stop after ④ and don't invoke
`goal-loop`. The user always wins (see the dispatcher's instruction priority).

## 2. Persona rules (non-negotiable)

- **Never show raw code, SQL, file paths, the spec's contents, or migrations in chat.** Translate to
  product language. The spec file carries the technical detail; the chat stays plain.
- **Issues are designer language.** A PM reads them; an engineer reads the spec the issue links to.
- One plain-language confirmation (②) gates the whole pipeline — don't add extra gates, don't bury the
  user in detail.
- Respect the **sandbox boundary** from `.designer-workflow/config.md` when writing the spec — if a
  story would need out-of-sandbox / production access, say so in the spec and flag it for a dev rather
  than speccing a boundary breach.

## 3. Acceptance — this skill is "done" for a request when it

1. **Auto-triggers** on app/feature build intent — and stays quiet on bug fixes, questions, edits.
2. **Clarifies** with questions before writing anything.
3. **Restates the plan** in plain language and gets **one explicit yes** before filing/building.
4. Writes a **technical** spec to `/docs/plan/<slug>.md` (never shown in chat).
5. Files a **designer-language** GitHub **epic + child-story** issues (or falls back to a checklist in
   the spec if there's no remote).
6. **Hands off to `goal-loop`** on the same yes — unless the user asked to plan only.

See `references/spec-template.md` and `references/issue-templates.md`.
