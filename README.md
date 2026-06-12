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

The `design` skill recognizes the intent and runs the loop:

1. **Restate** the app plan in plain language → get your okay.
2. **Build** the full stack on an isolated **sandbox branch** (data + backend + UI). It never touches
   other apps, production data, secrets, or auth/billing.
3. **Run** it and show a **mobile + desktop** walkthrough.
4. **Open a PR** with the walkthrough + a human summary.

## What's in the plugin

```
designer-workflow/
├── .claude-plugin/
│   ├── plugin.json             # plugin manifest
│   └── marketplace.json        # self-marketplace (this repo lists itself)
├── commands/
│   └── dw-init.md              # /designer-workflow:dw-init — per-project setup
├── skills/
│   ├── design/                 # orchestrator: describe an app → running app + PR
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── golden-prompts.md
│   │       └── dev-handoff-template.md
│   └── supabase-integration/   # backend half: schema + RLS + auth + typed client (Supabase MCP)
│       └── SKILL.md
└── docs/                       # TIMELINE.md + proposal.html/pdf
```

`design` orchestrates and delegates the backend to `supabase-integration`. Both auto-trigger from
their `description`; `dw-init` is the one explicit command, used only at setup.

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

- **Supabase MCP** — secure backend for new apps (used by `supabase-integration`).
- **A browser tool** — `chrome-devtools` MCP *or* the `agent-browser` skill — to run apps and capture
  the mobile + desktop walkthrough.
- **higgsfield MCP** *(optional)* — brand-locked image/icon assets.
- **git + a GitHub remote** — so the workflow can open a PR.

`dw-init` checks all of these and tells you, in plain language, what (if anything) is missing.

## Status

Proposal v1 — pending team sign-off (DionNam, Raka). Open team inputs are in
[docs/TIMELINE.md](docs/TIMELINE.md) §9 (real golden prompts, where sandbox apps live, the production
isolation boundary). `dw-init` is how the last two get answered per project.
