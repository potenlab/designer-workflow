# designer-workflow

A **`design` skill** that lets a **designer or PM create a whole running application** in plain
language — Claude does the full-stack engineer's thinking underneath (idea → data model → backend →
UI → running app → PR) but only ever responds in design/product language and a working app, never
code. It **auto-triggers on intent**: the user never types a command and never reads a diff.

See **[docs/TIMELINE.md](docs/TIMELINE.md)** for the full spec, locked decisions, timeline, and
acceptance criteria. (`docs/proposal.html` / `docs/proposal.pdf` are the shareable versions.)

## What ships in this repo

```
.claude/skills/
├── design/                     # the orchestrator: describe an app → get a running app + PR
│   ├── SKILL.md
│   └── references/
│       ├── golden-prompts.md   # designer + PM app-idea prompts (acceptance set)
│       └── dev-handoff-template.md
└── supabase-integration/       # the backend half: schema + RLS + auth + typed client (Supabase MCP)
    └── SKILL.md
```

`design` orchestrates; `supabase-integration` is the backend building block it delegates to. The loop:

1. **Restate** the app plan in plain language → get a yes.
2. **Build** the full stack on an isolated **sandbox branch** (never touches other apps, production
   data, secrets, or auth/billing).
3. **Run** it and show a **mobile + desktop** walkthrough.
4. **Open a PR** with the walkthrough + a human summary.

## Install

Two paths, same behavior — both rely on the skill's auto-trigger `description` (no slash command):

- **Per-project (this repo ships it):** the skills already live in `.claude/skills/`. Anyone who opens
  this repo in Claude Code gets them automatically.
- **Per-user (global, all your projects):** symlink (or copy) the two skill folders into your user
  skills dir:

  ```bash
  ln -sfn "$PWD/.claude/skills/design"               ~/.claude/skills/design
  ln -sfn "$PWD/.claude/skills/supabase-integration" ~/.claude/skills/supabase-integration
  ```

Newly installed skills load at the **start of a Claude Code session** — restart/clear to pick them up.

## Status

Proposal v1 — pending team sign-off (DionNam, Raka). Open inputs still needed from the team are listed
in [docs/TIMELINE.md](docs/TIMELINE.md) §9 (real golden prompts, where sandbox apps live, the
production isolation boundary).
