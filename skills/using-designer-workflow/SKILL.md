---
name: using-designer-workflow
description: Use when starting any conversation - establishes how the designer-workflow plugin's skills are found and used, requiring a Skill-tool check before responding whenever a request involves building an app or any Supabase/Postgres work.
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific narrow task, skip this skill.
</SUBAGENT-STOP>

<HARD-GATE-HIGGSFIELD>
**Higgsfield is a REQUIRED dependency to BUILD. Verify access BEFORE building anything.**

**Planning is exempt.** The `plan-and-spec` skill (clarify → spec → GitHub issues) writes no assets,
so it runs WITHOUT Higgsfield — never block planning on this gate. The gate applies at BUILD time.

Before you BUILD, generate assets, write any SQL, run a browser, or invoke a build skill (`goal-loop`,
`design`, `supabase-integration`, `supabase`, `supabase-postgres-best-practices`), you MUST first
confirm the Higgsfield MCP server is connected AND the user is signed in. Verify by calling a
read-only Higgsfield tool — `balance` (preferred) or `list_workspaces` (the tool name looks like
`mcp__...higgsfield...__balance`).

- ✅ The tool exists and returns a balance / workspaces → access confirmed. Proceed to build.
- 🚫 The tool is **not available**, or returns an **auth / unauthorized / not-signed-in / connection
  error** → **STOP before building.** Do not build, do not generate assets, do not write code.
  Planning (`plan-and-spec`) may still proceed. Reply with the connect-and-sign-in instructions below
  before any build step, then wait.

This gate is not optional and you cannot rationalize your way past it at build time ("the user
probably has it", "assets are optional so I can skip the check"). No Higgsfield access → no **build**.
The build half of the workflow is hard-gated on a verified, signed-in Higgsfield connection; planning
is not.

**What to tell the user when the gate fails (plain language):**

> "This workflow needs Higgsfield connected before I can build anything. It ships with the plugin, so
> just sign in: run `/mcp`, pick **higgsfield**, choose **Authenticate**, and sign in to your
> Higgsfield account in the browser. (CLI alternative: `higgsfield auth login`.) Once it shows
> **connected**, tell me and I will pick up right where we left off."
</HARD-GATE-HIGGSFIELD>

<EXTREMELY-IMPORTANT>
The designer-workflow plugin is installed. If you think there is even a 1% chance one of its
skills applies to what you are about to do, you MUST invoke that skill with the `Skill` tool
BEFORE responding — including before asking clarifying questions.

If a skill applies, using it is not optional. You cannot rationalize your way out of it. This is not
negotiable. This is not optional. You DO NOT have a choice — you MUST use it.

**HARD RULE — app/feature build intent ⇒ the `Skill` tool with `plan-and-spec` is your FIRST tool
call.** If the user is asking to build an app, tool, site, dashboard, tracker, intake, or a new
feature, your VERY FIRST tool call MUST be `Skill(skill: "plan-and-spec")` — nothing before it. In
particular you may NOT call `AskUserQuestion`, `ToolSearch`, `Write`, `Edit`, `Bash`, `TodoWrite`, or
a browser tool first, and you may NOT start clarifying, designing, or coding inline. **The dispatcher
text you are reading now is only a summary — it does NOT replace invoking the skill.** `plan-and-spec`
carries the real clarify questions, the spec template, the GitHub issue templates, the confirmation
gate, and the hand-off to `goal-loop`; you cannot reproduce those from memory. Asking your own
clarifying questions instead of invoking the skill ("I'll just ask first") is the most common failure —
do not do it. Invoke `plan-and-spec`; IT runs the clarify step for you.

The app-building skills are deliberately intent-gated: `plan-and-spec` (the entry point for any
app/feature request) fires ONLY on app-creation intent and must stay quiet on bug-fixes, questions,
and single-file edits (see the catalog below). `goal-loop` and `design` run downstream of it
(`plan-and-spec` → on the user's "correct" → `goal-loop` → `design` per story), so you normally don't
invoke them directly. For the Supabase / Postgres skills there is no such gate — reach for them.
</EXTREMELY-IMPORTANT>

## Instruction priority

designer-workflow skills override default behavior, but **the user always wins**:

1. **User's explicit instructions** (CLAUDE.md, AGENTS.md, direct requests) — highest priority.
2. **designer-workflow skills** — override default behavior where they conflict.
3. **Default behavior** — lowest priority.

If the user says "just write the SQL" or "don't run the full design loop," follow them.

## How to access skills

In Claude Code, use the **`Skill` tool** — invoking a skill loads its full content; follow it
directly. Never `Read` a skill file to "use" it. Skills evolve; invoke the current version.

## The rule

**Check for a relevant skill BEFORE any response or action.** Even a 1% chance means invoke it
to check — if it turns out wrong for the situation, you simply don't follow it.

```dot
digraph dw_flow {
    "User message received" [shape=doublecircle];
    "About to build / Write / Edit / Bash / plan-mode?" [shape=doublecircle];
    "App / feature build intent?" [shape=diamond];
    "Invoke plan-and-spec skill FIRST (before any tool)" [shape=box];
    "Supabase / Postgres work?" [shape=diamond];
    "Invoke the matching Supabase skill" [shape=box];
    "Announce: 'Using [skill] to [purpose]'" [shape=box];
    "Follow the skill exactly" [shape=box];
    "Respond (incl. clarifying questions)" [shape=doublecircle];

    "User message received" -> "App / feature build intent?";
    // Second entry: catch yourself the instant you're tempted to start building.
    "About to build / Write / Edit / Bash / plan-mode?" -> "App / feature build intent?";
    "App / feature build intent?" -> "Invoke plan-and-spec skill FIRST (before any tool)" [label="yes (build an app/tool/site/feature)"];
    "App / feature build intent?" -> "Supabase / Postgres work?" [label="no"];
    "Invoke plan-and-spec skill FIRST (before any tool)" -> "Announce: 'Using [skill] to [purpose]'";
    "Supabase / Postgres work?" -> "Invoke the matching Supabase skill" [label="yes, even 1%"];
    "Supabase / Postgres work?" -> "Respond (incl. clarifying questions)" [label="definitely not"];
    "Invoke the matching Supabase skill" -> "Announce: 'Using [skill] to [purpose]'";
    "Announce: 'Using [skill] to [purpose]'" -> "Follow the skill exactly";
    "Follow the skill exactly" -> "Respond (incl. clarifying questions)";
}
// Two entry points (both double-circles): on every user message AND the moment you catch yourself
// about to Write/Edit/Bash or enter plan mode for a build. Either way, app/feature intent routes to
// plan-and-spec FIRST. plan-and-spec then drives the rest: clarify → confirm → spec + issues →
// on "correct" → goal-loop → design (per story) → verify-in-browser → PR.
```

When you invoke a skill, **announce it**: "Using `supabase` to wire auth correctly."

## Skill catalog (what this plugin ships)

| Skill | Invoke when | Do NOT invoke when |
|---|---|---|
| **plan-and-spec** | **The entry point for any app/feature request.** The user describes an app, tool, site, dashboard, tracker, intake, or new feature to **build** in plain language ("make me a tool that…", "add a feature where…"). Runs: clarify with questions → restate plan → on "correct" write a technical spec to `/docs/plan` + a designer-language GitHub epic + child stories → hand off to `goal-loop`. | A single-file edit, a bug fix, or a question. It must stay quiet here. |
| **goal-loop** | Downstream of `plan-and-spec` — autonomously builds the planned epic, **one child story per turn** (build → verify → PR), until the goal is met. Normally auto-triggered by `plan-and-spec` on "correct"; invoke directly only when an epic of story issues already exists. | No plan/spec/epic exists yet (run `plan-and-spec` first). |
| **design** | Build **one** story/app full-stack (backend + UI + assets + wire) on a sandbox branch, run it, show a mobile+desktop walkthrough, open a PR. Usually called **by `goal-loop`** per story; can run standalone for a single ad-hoc build. | A single-file edit, a bug fix, or a question. |
| **supabase-integration** | A created app needs a backend: store data, save submissions, user accounts, login, "a database for this". The opinionated app-creation backend path. | Pure Postgres tuning with no app context (use the two skills below). |
| **supabase** | ANY Supabase task: Database, Auth, Edge Functions, Realtime, Storage, RLS, migrations, `supabase-js` / `@supabase/ssr`, Supabase CLI or MCP. Prefer it over memory — Supabase changes often. | The task has nothing to do with Supabase. |
| **supabase-postgres-best-practices** | Writing, reviewing, or optimizing Postgres queries, schema, indexes, connections, or locks. | Non-database work. |
| **higgsfield-assets** | ANY visual or media asset is needed — image, icon, logo, illustration, hero, background, avatar, video, sound, voiceover. Higgsfield is the ONLY asset path; never use stock/emoji/placeholder/another generator. Fires automatically, plugin-wide, not just inside `design`. | Code, data/schema, copywriting, or UI layout — assets only. |
| **verify-in-browser** | You just built or changed ANY part of an app and are about to call it done or open a PR. Runs the app in the Claude Chrome extension, drives the real flow, captures mobile+desktop, checks console+network. | You have not changed anything runnable yet. |

## Skill priority

When more than one could apply: **process/orchestration first, implementation second.**

- "Let's build X with logins" → `plan-and-spec` first (clarify → spec + issues → on "correct" →
  `goal-loop` → `design` per story); the build chain pulls in `supabase-integration`, which defers to
  `supabase` / `supabase-postgres-best-practices` for the details. Don't jump straight to `design` or
  `goal-loop` for a fresh request — `plan-and-spec` is the entry point.
- "Speed up this slow query" → `supabase-postgres-best-practices` directly.

## Red flags (you are rationalizing — STOP)

| Thought | Reality |
|---|---|
| "I'll just write this one file / start the app first" | STOP. Check BEFORE doing anything. On build intent, `plan-and-spec` comes before any `Write`/`Edit`/`Bash`. |
| "Let me explore the codebase / files first" | The skills tell you HOW to explore. Invoke `plan-and-spec` first. |
| "I need more context first, let me ask / gather info" | The skill check comes BEFORE clarifying questions. `plan-and-spec` does the clarifying. |
| "I'll just ask the clarifying questions myself" | No — `Skill(plan-and-spec)` FIRST. It carries the real questions, templates, gate, and handoff. AskUserQuestion before the Skill call is the #1 bypass. |
| "The dispatcher already told me the flow, I can just do it" | The dispatcher is a summary. Invoke `plan-and-spec` to load the actual template + issue formats + gate. |
| "This feels productive, I'm just helping fast" | Undisciplined action skips the plan, the spec, and the issues. Invoke the skill. |
| "I'll knock out a quick prototype, then plan" | No. A built file before `plan-and-spec` is a contract failure. Skill first. |
| "It's a small app, planning is overkill" | If it is app/feature-creation intent, run `plan-and-spec` — it's the entry point, every size. |
| "I'll just start building, skip the spec/issues" | No — `plan-and-spec` clarifies and gets one "correct" before any build. Run it first. |
| "This is just a quick Supabase question" | Questions are tasks. Invoke `supabase`. |
| "I remember how RLS works" | Supabase changes; the skill has the current rules. Invoke it. |
| "I'll write the schema first, then check" | Check BEFORE writing. The skill shapes the schema. |
| "plan-and-spec should fire on this bug fix" | No — it's intent-gated. Stay quiet, just fix it. |

## Persona — think as a developer, respond as a designer/PM (ALL skills)

This applies to **every** designer-workflow skill, not just `design`:

- **Think as a full-stack developer underneath** — data model, types, RLS, edge cases, error states,
  performance, isolation, blast radius. Do the real engineering.
- **Respond as a designer/PM on the surface** — the user sees plain language and a **working app**,
  never raw code, SQL, file paths, migrations, or stack traces (unless they explicitly ask "show me
  the code"). If you are about to surface engineer-speak, translate it first: "migration" → "saved to
  a database"; "RLS policy" → "each person only sees their own".
- One plain-language confirmation per major step — don't bury the user in detail.
- Everything builds inside an isolated sandbox that never touches production data, secrets, or
  auth/billing. Raw engineer detail is allowed in exactly one place: the **PR body**.

## Verify every development (no exceptions)

Whenever you build or change something runnable, you are **not done until you have run it in a
browser**. Before saying "done"/"fixed"/"works" or opening a PR, invoke **`verify-in-browser`** — it
drives the app in the Claude Chrome extension, completes the real user flow, captures a mobile +
desktop walkthrough, and checks the console + network. A change you have not watched run is not
verified — do not claim it works.
