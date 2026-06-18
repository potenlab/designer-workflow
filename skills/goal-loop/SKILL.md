---
name: goal-loop
description: "Use after plan-and-spec to build a planned change to completion. Scales to size: a small single-issue change is built directly (one story, verify, one PR); a new/large epic is walked one child story at a time (build via design, verify in a browser, open one PR per story), then reports. Triggered by plan-and-spec ONLY after the user has confirmed the FILED GitHub issue is correct; or use directly when a spec (/docs/plan) and a filed, user-approved issue already exist. Execution only — it does not plan or file issues."
metadata:
  author: dev@potenlab.dev
  version: "0.1.0"
  date: 2026-06-17
  status: v1
  reuses: plan-and-spec, design, supabase-integration, higgsfield-assets, verify-in-browser, commit-commands:commit-push-pr, qa-check, higgsfield
---

# goal-loop — drive a planned goal to done, one story per turn

The **goal** is an epic (from `plan-and-spec`) plus its acceptance criteria. The **loop** walks the
epic's **child-story issues one at a time** and builds each to a verified, reviewable PR. You keep
going **autonomously** until every story is green, then report once at the end.

> **Think as an engineer, speak as a designer/PM.** You build like a full-stack engineer; you report
> per story in plain language ("Submit-a-brief is built and running — here's the walkthrough and a PR").

This skill is **execution only**. It does **not** clarify, spec, or file issues — `plan-and-spec` did
that. It assumes the **spec** (`/docs/plan/<slug>.md`) and the **epic + child issues** already exist.

---

## 0. Gate before you loop

### 0a. Higgsfield hard-gate (REQUIRED — building needs it)

`goal-loop` builds real apps with real assets, so the workflow's **Higgsfield hard-gate applies here**.
Before the first story, verify the Higgsfield MCP is connected and the user is **signed in** by calling
a read-only Higgsfield tool — `balance` (preferred) or `list_workspaces`.

- Returns a balance/workspaces → proceed.
- Missing, or auth/unauthorized/connection error → **STOP.** Don't build. Tell the user, plainly:

  > "Before I start building I need Higgsfield connected — it makes all the images and icons. Just sign
  > in: run `/mcp`, pick **higgsfield → Authenticate**, and log in in the browser. Tell me once it shows
  > connected and I'll pick up the build."

### 0b. Inputs exist AND the issue is user-approved

Confirm there is something to build **and that the user already blessed the filed issue** (that gate
lives in `plan-and-spec` §④ — don't re-ask, but don't build an issue that was never confirmed):

- The **spec** at `/docs/plan/<slug>.md`.
- Either a **single `change` issue** (small change) OR an **epic + open `story` children**
  (`gh issue list --label "story,change"` / read the epic's checklist).
- If there's no spec/issue at all, you were invoked too early — defer to **`plan-and-spec`** first.

**Scale to the work:** if it's a single small-change issue, treat it as **one short story** — build it
directly, verify, open one PR, done. Only walk a multi-story loop when there's an epic with children.

### 0c. Read the project config

Read `.designer-workflow/config.md` for the **sandbox location** and the **off-limits / production
boundary**. Every story is built inside the sandbox; the boundary is hard (see §3).

## 1. The loop

```
for each open child story, in the spec's build order:
   ① pick      the next open story (respect dependencies: schema → auth → UI → per-user filtering)
   ② build     invoke `design` to build just that story (backend / UI / assets / wire), in the sandbox
   ③ verify    invoke `verify-in-browser` — core flow, access rule, console + network, mobile + desktop
   ④ land      one PR for this story (commit-push-pr) that CLOSES its issue; check the epic's box
   ⑤ next      move to the next story
↑ repeat until every child story is shipped
→ REPORT once: goal met, list every PR + walkthrough
```

### ① Pick the next story

Take the next **open** child issue following the **build order** in the spec (`§10`) — dependencies
first (schema before the UI that reads it; auth before "only my team" filtering). One story per turn.

### ② Build it — delegate to `design`

Invoke the **`design`** skill to build **just this one story**, scoped to its **Story → implementation
map** section of the spec. `design` assembles the backend (`supabase-integration`), UI
(`frontend-design` / `impeccable`), and assets (`higgsfield-assets`), and wires it — all **inside the
sandbox branch/app**. Build only what this story needs; don't pull future stories forward.

### ③ Verify it — `verify-in-browser` (every story, no exceptions)

Invoke **`verify-in-browser`**. A story is not done until you've watched it run: the core flow
completes, the access rule holds (positive AND negative case), console + network are clean, and you've
captured a **mobile + desktop** walkthrough. If it fails, **fix it in the sandbox and re-verify** —
never land a broken story.

### ④ Land one PR per story

Open **one PR for this story** via **commit-commands:commit-push-pr** (or **qa-check** for the
branch/commit/PR mechanics). The PR:

- Lands on a sandbox branch — **never commits to `main`**.
- **Closes its issue** — put `Closes #NN` in the PR body.
- Carries the **mobile + desktop walkthrough** + a short "for the developer" note (the only place
  engineer detail is allowed — stack touched, the Supabase project/branch, what to review).

Then check that story's box in the epic checklist (`gh issue edit` / let the close auto-tick it) and
tell the user, in one plain line, that this piece is built and open for review.

### ⑤ Next / done

Move to the next open story. When none remain, **report once**.

## 2. Autonomy — run to done, report at the end

After the go-ahead (the user's "the plan is correct" in `plan-and-spec`, or a direct invocation), run
**autonomously through all stories** — do **not** pause for approval between stories. Give a short
plain-language line as each story lands so the user can follow along, but don't wait.

**Stop early and ask only when:**

- **Sandbox boundary hit** — a story needs out-of-sandbox / production access (see §3). Stop, write the
  dev-handoff note, keep going on the stories that don't need it, and surface the handoff at the end.
- **Verify won't pass** — a story can't be made to work after a genuine fix attempt. Stop on that
  story, report what's blocking in plain language, and don't fake a green walkthrough.
- **Genuine ambiguity** the spec doesn't answer and you can't safely assume. Ask one plain question.

Otherwise: keep building. Don't invent extra confirmation gates — the single human gate was the plan
approval in `plan-and-spec`.

## 3. The sandbox boundary still holds (autonomy does NOT override it)

Running unattended makes isolation **more** important, not less. Every story is built **inside the new
app's own workspace/branch and its own Supabase project/branch**.

- ✅ Allowed: the new app's data model, its own Supabase project/branch, its UI, assets, config/env.
- 🚫 Hard refuse: other apps/repos; production DBs, migrations, or data; shared secrets / any `.env*`;
  auth/billing of an existing system; `.understand-anything*/` KG files.

If a story **requires** an out-of-sandbox change, **do not reach out**. Write a **dev-handoff note**
(`../design/references/dev-handoff-template.md`), skip just that story, continue the rest, and surface
the handoff in the final report. Handing off is success, not failure.

## 4. Final report (designer/PM language)

When the goal is met (or as far as the sandbox allows), report **once**, plainly:

> "All done. I built and tested every piece on phone and desktop:
> • **Submit a brief** — built, running, PR open.
> • **See the board** — built, running, PR open.
> • **Move a brief** — built, running, PR open.
> • **Only-my-team** — built, running, PR open (checked one account can't see another's).
> Each piece has its own review link. <If any handoff:> One piece needs a developer because it touches
> our real data — I've written up exactly what's needed."

List the PRs/walkthroughs. Keep raw logs and engineer detail in the PRs, never in chat.

## 5. Acceptance — a goal-loop run is "done" when it

1. **Verified Higgsfield** access before building (hard-gated).
2. Built **every open child story**, one per turn, in the spec's build order.
3. **Verified each story in a browser** (mobile + desktop) before landing it.
4. Opened **one PR per story** that **closes its issue** — never committed to `main`.
5. Stayed **inside the sandbox** — wrote a **dev-handoff note** instead of any boundary breach.
6. Ran **autonomously** after the go-ahead and **reported once** at the end with all PRs + walkthroughs.

## 6. Building blocks (all installed — you assemble, you don't build)

| Need | Reuse |
| --- | --- |
| The plan/spec + epic/child issues (input) | `plan-and-spec` (runs before this) |
| Build one story full-stack | **`design`** skill (→ `supabase-integration`, `frontend-design`, `impeccable`) |
| Brand-locked assets per story | **`higgsfield-assets`** skill + `higgsfield` MCP |
| Verify each story (mobile+desktop, console+network) | **`verify-in-browser`** skill |
| One PR per story | `commit-commands:commit-push-pr`, `qa-check` |
| Out-of-sandbox → handoff, not breach | `../design/references/dev-handoff-template.md` |
