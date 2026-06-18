---
description: Initialize the Designer Workflow in the current project — set where sandbox apps live, draw the production isolation boundary, check required tools/MCPs, and confirm the design + supabase-integration skills are ready. Run this once per project after installing the plugin.
argument-hint: "[optional: sandbox folder name, e.g. apps]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Skill, ToolSearch, AskUserQuestion, mcp__claude-in-chrome__list_connected_browsers, mcp__claude-in-chrome__select_browser, mcp__claude-in-chrome__switch_browser, mcp__claude-in-chrome__tabs_context_mcp
---

# Designer Workflow — project initiation (`dw-init`)

You are setting up the **Designer Workflow** in the user's current project so the auto-triggering
`design` skill knows **where it may build** and **what it must never touch**. The user is likely a
designer or PM — keep every prompt in **plain language**, never engineer jargon.

`$ARGUMENTS` (optional) is a suggested sandbox folder name. If empty, default to `apps`.

Work through these steps in order. Use plain-language confirmations, not a wall of output.

## 1. Read the project

- Confirm you're in a git repo: `git rev-parse --is-inside-work-tree` (if not, offer `git init`).
- Note the repo name, the current branch, and whether the working tree is clean (`git status --short`).
- Detect the stack quickly (presence of `package.json`, `next.config.*`, `supabase/`, etc.) — just
  enough to describe the project back to the user in one sentence.

## 2. Connect & pick your browser (Claude Chrome extension) — do this FIRST

The workflow tests **every** change in a real browser via the **Claude Chrome extension**
(`claude-in-chrome`), so set the browser up before anything else. Keep it plain-language.

1. **Invoke the `claude-in-chrome` skill** first (it loads the browser tools), then call
   **`list_connected_browsers`** to see which Chrome browsers are connected to the extension.
2. **If none are connected**, ask the user to connect one, plainly:
   > "I drive a real Chrome to test what I build. Open the **Claude Chrome extension**, click it, and
   > connect this browser (allow access). Tell me once it's connected and I'll continue."
   …then re-run `list_connected_browsers`. Don't move on until at least one shows up.
3. **If one or more are connected**, list them by name and **ask which one to use** for this project
   (use `AskUserQuestion` if there's more than one). Then call **`select_browser`** (or
   `switch_browser`) to make that one active.
4. **If the names are unclear** (e.g. several "Chrome" entries), tell the user they can **rename** a
   browser in the **extension's browser list** so it's easy to identify — then re-list and let them pick.
5. **Record the chosen browser** so later runs reuse it (written to the config in step 6).

Do not continue to the rest of setup until a browser is **connected and selected**.

## 3. Decide where new apps live (sandbox location)

Ask, in plain language:

> "When you describe an app to build, where should it live? I can put each new app in a **`<folder>/`
> subfolder of this project**, or you can have me spin up a **fresh repo per app**. Subfolder is the
> simplest — okay?"

- Default: a subfolder named from `$ARGUMENTS` (or `apps`).
- Record their choice. Create the folder if it's the subfolder option (`mkdir -p <folder>` and add a
  `.gitkeep`), so the design skill has a home for sandboxes.

## 4. Draw the isolation boundary (the safety line)

This is the most important step. Ask, plainly:

> "What in here is **real / production** — the live customer data, real databases, secrets, or the
> login/billing of the real product — that a new experimental app must **never** touch? I'll fence it
> off so the workflow stays in its sandbox."

Capture their answer. Always treat these as **off-limits by default** even if unmentioned: any
`.env*` file, production Supabase projects, existing migrations, auth/billing of existing systems,
other apps/repos, and `.understand-anything*/` KG files. The design skill hard-refuses these and
writes a dev-handoff note instead.

## 5. Check the tools the workflow needs

Report a simple ✅/⚠️ checklist (don't dump raw errors). For each, say what it's for in plain terms
and, if missing, the one line to fix it:

- **Higgsfield MCP** *(REQUIRED — the workflow is hard-gated on this)* — for brand-locked images/icons,
  and the access check that gates the whole workflow. It ships bundled with this plugin (`.mcp.json`),
  so it should already be registered. The user still must **sign in**: verify by calling a read-only
  Higgsfield tool (`balance` or `list_workspaces`). If it is missing or returns an auth error, this is
  a ⛔ blocker — tell them to run `/mcp` → **higgsfield → Authenticate** and sign in (or
  `higgsfield auth login`). **Do not report the project as ready until Higgsfield verifies.**
- **Supabase MCP** — gives new apps a secure backend (data + login). Needed by `supabase-integration`.
  Missing → tell them to add the Supabase MCP server in Claude Code settings.
- **A browser** — already handled in **step 2** (Claude Chrome extension, connected + selected). Just
  confirm a browser is still selected here; if the extension somehow isn't available, fall back to the
  `chrome-devtools` MCP or the `agent-browser` skill and note it.
- **git + a GitHub remote** — so the workflow can open a PR at the end. Check `git remote -v`; if no
  remote, note that PRs will be local branches until a remote is added.

Also confirm the skills are present (they ship with this plugin): `using-designer-workflow`, `design`,
`supabase-integration`, `supabase`, `supabase-postgres-best-practices`.

## 6. Write the project config

Write `.designer-workflow/config.md` at the repo root so the `design` skill reads the boundary and
sandbox location on every run. Use this shape (fill in their answers):

```markdown
# Designer Workflow — project config
<!-- Written by /designer-workflow:dw-init. Edit by hand or re-run dw-init. -->

- **Sandbox apps live in:** `apps/`            <!-- subfolder | fresh-repo-per-app -->
- **Default app branch prefix:** `app/`
- **Off-limits (production / never touch):**
  - <their answer, e.g. the live `clients` table in the prod Supabase project>
  - any `.env*`, production DBs & migrations, existing auth/billing, other apps, .understand-anything*/
- **Browser (Claude Chrome extension):** `<chosen browser name from step 2>`
- **Walkthrough viewports:** mobile + desktop
- **Initialized:** <repo name> on <date from `date +%Y-%m-%d`>
```

Add `.designer-workflow/` is safe to commit (it's config, not secrets) — leave that to the user.

## 7. Confirm it's ready (plain language)

Close with a short, non-technical summary and how to use it — **no command needed from here on**:

> "Designer Workflow is set up. New apps will live in `apps/`, and I'll never touch <their
> production things>. Whenever you want something, just describe it — *'a little tool where clients
> upload a brief and we track it to done'* — and I'll build it, show you it running on phone and
> desktop, and open it up for review. No commands to remember."

If any required tool was missing in step 4, list just those as the only follow-ups.
