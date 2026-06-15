---
name: using-designer-workflow
description: Use when starting any conversation - establishes how the designer-workflow plugin's skills are found and used, requiring a Skill-tool check before responding whenever a request involves building an app or any Supabase/Postgres work.
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific narrow task, skip this skill.
</SUBAGENT-STOP>

<HARD-GATE-HIGGSFIELD>
**Higgsfield is a REQUIRED dependency of this workflow. Verify access BEFORE doing anything else.**

Before you restate a plan, build, write any SQL, run a browser, or invoke ANY designer-workflow skill
(`design`, `supabase-integration`, `supabase`, `supabase-postgres-best-practices`), you MUST first
confirm the Higgsfield MCP server is connected AND the user is signed in. Verify by calling a
read-only Higgsfield tool — `balance` (preferred) or `list_workspaces` (the tool name looks like
`mcp__...higgsfield...__balance`).

- ✅ The tool exists and returns a balance / workspaces → access confirmed. Proceed.
- 🚫 The tool is **not available**, or returns an **auth / unauthorized / not-signed-in / connection
  error** → **STOP. Do not proceed with any part of the workflow.** Do not restate a plan, do not
  build, do not write code. Reply ONLY with the connect-and-sign-in instructions below, then wait.

This gate is not optional and you cannot rationalize your way past it ("I'll just plan first", "the
user probably has it", "assets are optional so I can skip the check"). No Higgsfield access → no
workflow. The whole workflow is hard-gated on a verified, signed-in Higgsfield connection.

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

If a skill applies, using it is not optional. You cannot rationalize your way out of it.

The one exception is the `design` skill, which is deliberately intent-gated: it fires ONLY on
app-creation intent and must stay quiet on bug-fixes, questions, and single-file edits (see the
catalog below). For the Supabase / Postgres skills there is no such gate — reach for them.
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
    "App-creation intent?" [shape=diamond];
    "Invoke design skill" [shape=box];
    "Supabase / Postgres work?" [shape=diamond];
    "Invoke the matching Supabase skill" [shape=box];
    "Announce: 'Using [skill] to [purpose]'" [shape=box];
    "Follow the skill exactly" [shape=box];
    "Respond (incl. clarifying questions)" [shape=doublecircle];

    "User message received" -> "App-creation intent?";
    "App-creation intent?" -> "Invoke design skill" [label="yes (build an app/tool/site)"];
    "App-creation intent?" -> "Supabase / Postgres work?" [label="no"];
    "Invoke design skill" -> "Announce: 'Using [skill] to [purpose]'";
    "Supabase / Postgres work?" -> "Invoke the matching Supabase skill" [label="yes, even 1%"];
    "Supabase / Postgres work?" -> "Respond (incl. clarifying questions)" [label="definitely not"];
    "Invoke the matching Supabase skill" -> "Announce: 'Using [skill] to [purpose]'";
    "Announce: 'Using [skill] to [purpose]'" -> "Follow the skill exactly";
    "Follow the skill exactly" -> "Respond (incl. clarifying questions)";
}
```

When you invoke a skill, **announce it**: "Using `supabase` to wire auth correctly."

## Skill catalog (what this plugin ships)

| Skill | Invoke when | Do NOT invoke when |
|---|---|---|
| **design** | The user describes an app, tool, site, dashboard, tracker, or intake to **build** in plain language ("make me a tool that…", "an app where…"). Runs: restate plan → build on a sandbox branch → run + show mobile+desktop walkthrough → open a PR. | A single-file edit, a bug fix, or a question. It must stay quiet here. |
| **supabase-integration** | A created app needs a backend: store data, save submissions, user accounts, login, "a database for this". The opinionated app-creation backend path. | Pure Postgres tuning with no app context (use the two skills below). |
| **supabase** | ANY Supabase task: Database, Auth, Edge Functions, Realtime, Storage, RLS, migrations, `supabase-js` / `@supabase/ssr`, Supabase CLI or MCP. Prefer it over memory — Supabase changes often. | The task has nothing to do with Supabase. |
| **supabase-postgres-best-practices** | Writing, reviewing, or optimizing Postgres queries, schema, indexes, connections, or locks. | Non-database work. |
| **verify-in-browser** | You just built or changed ANY part of an app and are about to call it done or open a PR. Runs the app in the Claude Chrome extension, drives the real flow, captures mobile+desktop, checks console+network. | You have not changed anything runnable yet. |

## Skill priority

When more than one could apply: **process/orchestration first, implementation second.**

- "Let's build X with logins" → `design` (orchestrator) first; it pulls in `supabase-integration`,
  which defers to `supabase` / `supabase-postgres-best-practices` for the details.
- "Speed up this slow query" → `supabase-postgres-best-practices` directly.

## Red flags (you are rationalizing — STOP)

| Thought | Reality |
|---|---|
| "This is just a quick Supabase question" | Questions are tasks. Invoke `supabase`. |
| "I remember how RLS works" | Supabase changes; the skill has the current rules. Invoke it. |
| "I'll write the schema first, then check" | Check BEFORE writing. The skill shapes the schema. |
| "The design loop is overkill for this app" | If it is app-creation intent, run `design`. |
| "design should fire on this bug fix" | No — `design` is intent-gated. Stay quiet, just fix it. |

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
