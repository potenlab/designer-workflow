# designer-workflow

A Claude Code **plugin**. A **designer or PM describes an application in plain language** and gets a
**running app + a PR** — Claude does the full-stack engineer's thinking underneath (idea → data model
→ backend → UI → running app → PR) but only ever responds in design/product language and a working
app, **never code**. It **auto-triggers on intent**: no command to memorize, no diffs to read.

See **[docs/TIMELINE.md](docs/TIMELINE.md)** for the full spec, locked decisions, and acceptance
criteria. (`docs/proposal.html` / `docs/proposal.pdf` are the shareable versions.)

## Install (2 steps)

**1 — Install the plugin** in Claude Code:

```text
/plugin marketplace add potenlab/designer-workflow
/plugin install designer-workflow@designer-workflow
```

(or non-interactively: `claude plugin marketplace add potenlab/designer-workflow` then
`claude plugin install designer-workflow@designer-workflow`.)

**2 — Initialize it in your project** — run once per project:

```text
/designer-workflow:dw-init
```

`dw-init` asks, in plain language, **where new apps should live** and **what's off-limits** (your real
data, secrets, auth/billing), checks the tools the workflow needs (Supabase MCP, a browser tool,
optionally higgsfield), and writes `.designer-workflow/config.md`. After that there is **no command** —
just describe an app and the workflow takes over.

## How to use it (after install)

Just say what you want:

> "a clean little gallery app where I drop images and tag them"
> "an intake tool: clients submit a brief, and we track it New → Doing → Done"

The workflow recognizes the intent and runs the full pipeline — **plan → confirm → build → ship**:

1. **Clarify & plan** (`plan-and-spec`) — it asks a few plain-language questions, restates the plan,
   and shows how it'd break the work into pieces.
2. **Confirm — the one gate** — *"Is this plan correct?"* On your **yes** it writes a **technical spec**
   to `docs/plan/` (for the developer — never shown in chat) and opens a **GitHub epic + one child issue
   per piece**, written in plain product language.
3. **Build autonomously** (`goal-loop`) — it works the pieces **one at a time**: builds each on an
   isolated **sandbox branch**, runs it, captures a **mobile + desktop** walkthrough, and opens **one PR
   per piece** that closes its issue. It never touches other apps, production data, secrets, or
   auth/billing.
4. **Report** — when every piece is built and verified, it hands you all the review links.

You only ever make **one decision** ("is the plan correct?"); after that it runs to done. If you'd
rather stop at the plan, say *"just plan it, don't build yet."* There's no command to remember, but
`/designer-workflow:dw-plan` will kick the planning off explicitly if you want to be certain.

The split of audiences is deliberate: **chat stays plain language**, the **technical spec** lives in
`docs/plan/`, and the **GitHub issues** are designer/product language for the team to track.

## What's in the plugin

```
designer-workflow/
├── .claude-plugin/
│   ├── plugin.json             # plugin manifest
│   └── marketplace.json        # self-marketplace (this repo lists itself)
├── .mcp.json                   # bundled MCP servers → Higgsfield auto-installs with the plugin
├── commands/
│   ├── dw-init.md              # /designer-workflow:dw-init — per-project setup
│   └── dw-plan.md              # /designer-workflow:dw-plan — explicit start of the planning pipeline
├── skills/
│   ├── using-designer-workflow/ # dispatcher: the "check + use a skill before responding" contract
│   │   └── SKILL.md
│   ├── plan-and-spec/          # ENTRY: clarify → confirm → technical spec (docs/plan) + designer GitHub epic+stories
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── spec-template.md      # the technical /docs/plan spec (engineer language)
│   │       └── issue-templates.md    # epic + child-story issues (designer language)
│   ├── goal-loop/              # autonomous executor: build the epic one child story per turn → one PR each
│   │   └── SKILL.md
│   ├── design/                 # builds ONE story full-stack → running app + PR (called per story by goal-loop)
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── golden-prompts.md
│   │       └── dev-handoff-template.md
│   ├── supabase-integration/   # backend half: schema + RLS + auth + typed client (Supabase MCP)
│   │   └── SKILL.md
│   ├── supabase/               # ← bundled from supabase/agent-skills (MIT): deep Supabase knowledge
│   ├── supabase-postgres-best-practices/  # ← bundled (MIT): Postgres perf + schema rules
│   ├── higgsfield-assets/      # auto-uses Higgsfield MCP for every asset (images/icons/video/sound)
│   │   └── SKILL.md
│   └── verify-in-browser/      # mandatory test step: run every change in the Claude Chrome extension
│       └── SKILL.md
├── hooks/
│   ├── hooks.json              # SessionStart hook (startup|clear|compact) → injects the dispatcher
│   ├── session-start           # emits the dispatcher skill as context-injection JSON
│   └── run-hook.cmd            # polyglot wrapper so the hook runs on Unix + Windows
└── docs/                       # TIMELINE.md + proposal.html/pdf
```

### Auto-activation (no command, no setup — superpowers-style)

Skills already activate from their `description` the moment the plugin is installed. To make that
**proactive and resilient**, the plugin uses the [`obra/superpowers`](https://github.com/obra/superpowers)
pattern: a single **`SessionStart`** hook (matcher `startup|clear|compact`) runs `hooks/session-start`,
which injects the **full text of the `using-designer-workflow` dispatcher skill** into context. The
`compact` matcher means the rule **re-fires after context compaction**, so it survives long sessions.

The dispatcher is a behavioral contract, not a feature list: *check for a relevant skill before
responding, and if there is even a 1% chance one applies, invoke it with the `Skill` tool and announce
it.* That trains the habit, so once `designer-workflow` is installed all skills are used automatically:

- **plan-and-spec** is the **entry point** — it fires on app/feature-creation intent ("make me a tool
  that…", "add a feature where…") and stays silent on bug-fixes, questions, and single-file edits (it is
  deliberately intent-gated — per the acceptance tests). It clarifies, gets one "is this correct?", then
  writes the technical spec + the designer-language GitHub epic/stories.
- **goal-loop** runs downstream: on your "correct" it builds the epic **autonomously, one child story
  per turn** (build → verify → one PR per story), and reports when the goal is met. You don't invoke it
  directly.
- **design** builds a single story full-stack (backend + UI + assets + wire) → running app + PR; it's
  normally called **by goal-loop** once per story.
- **supabase / supabase-postgres-best-practices / supabase-integration** are consulted automatically
  for any Supabase or Postgres work, in preference to model memory.
- **higgsfield-assets** fires whenever a visual or media asset is needed (image, icon, logo, hero,
  video, sound) and makes Higgsfield the **only** asset path — auto-generated and auto-placed, never a
  stock photo, emoji, or placeholder, and never a "go find an image yourself". Assets only — it stays
  out of code, data, and copy.
- **verify-in-browser** fires whenever something runnable was built or changed — before any
  "done"/PR.

Two rules cut across **all** skills, enforced by the dispatcher:

- **Think as a developer, respond as a designer/PM** — real engineering underneath; plain language +
  a working app on the surface, never raw code/SQL/migrations in chat (engineer detail lives only in
  the PR).
- **Verify every development in a browser** — no build or change is "done" until `verify-in-browser`
  has run it in the **Claude Chrome extension** (`claude-in-chrome`), completed the real user flow,
  captured a mobile + desktop walkthrough, and confirmed the console + network are clean. It re-runs
  after every change, not just at the end.

`design` orchestrates and delegates the backend to `supabase-integration`, which in turn defers to the
two **bundled official Supabase skills** (`supabase`, `supabase-postgres-best-practices`, vendored from
[`supabase/agent-skills`](https://github.com/supabase/agent-skills), MIT). `dw-init` is the one explicit
command, used only at setup. Because the official skills ship inside the plugin, installing
`designer-workflow` installs them too — no `npx skills add` step needed.

### Higgsfield is required — verify-first hard gate

[Higgsfield](https://higgsfield.ai/mcp) is a **hard dependency**, auto-installed via `.mcp.json`
(server `higgsfield` → `https://mcp.higgsfield.ai/mcp`, HTTP + OAuth). The workflow **refuses to run
until Higgsfield is connected and the user is signed in**:

- The dispatcher and `design` skill **verify first** — before any plan, build, SQL, or browser step,
  they call a read-only Higgsfield tool (`balance` / `list_workspaces`). On success → proceed.
- If the tool is missing or returns an auth/connection error, the workflow **stops** and asks the user
  to sign in — no plan, no build, no PR until it verifies.

**Sign in once after install:** run `/mcp` → **higgsfield → Authenticate** and log in in the browser
(CLI alternative: `higgsfield auth login`). The MCP server itself is already registered by the plugin;
only the sign-in is on the user. This makes Higgsfield access the gate for the entire workflow.

## Develop / test locally

```bash
# Load the plugin in a throwaway session without installing it
claude --plugin-dir /path/to/designer-workflow

# Validate the manifest + skill/command frontmatter
claude plugin validate /path/to/designer-workflow

# After editing skills/commands mid-session
/reload-plugins
```

## Requirements

- **Higgsfield MCP** *(REQUIRED — hard gate)* — bundled via `.mcp.json` (`https://mcp.higgsfield.ai/mcp`).
  Brand-locked assets **and** the access check that gates the whole workflow. Sign in once after install
  via `/mcp` → **higgsfield → Authenticate** (or `higgsfield auth login`). Until it verifies, the
  workflow refuses to build.
- **Supabase MCP** — secure backend for new apps (used by `supabase-integration` and the bundled
  `supabase` skill). The Supabase knowledge skills themselves ship with the plugin — no separate install.
- **A browser tool** — `chrome-devtools` MCP *or* the `agent-browser` skill — to run apps and capture
  the mobile + desktop walkthrough.
- **git + a GitHub remote** — so the workflow can open a PR.

`dw-init` checks all of these and tells you, in plain language, what (if anything) is missing —
Higgsfield is treated as a blocker, the rest as warnings.

## Status

Proposal v1 — pending team sign-off (DionNam, Raka). Open team inputs are in
[docs/TIMELINE.md](docs/TIMELINE.md) §9 (real golden prompts, where sandbox apps live, the production
isolation boundary). `dw-init` is how the last two get answered per project.
