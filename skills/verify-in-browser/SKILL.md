---
name: verify-in-browser
description: "Use after building or changing ANY part of an app — a feature, a fix, a styling tweak, a backend wiring — to verify it actually works before claiming it is done or opening a PR. Drives the running app in a real browser via the Claude Chrome extension, exercises the core user flow, captures a mobile + desktop walkthrough, and checks the console + network for errors. Triggers: 'is it working', 'test it', 'verify', 'show me it running', finishing a build step, or before any 'done'/PR. No development is finished until this passes."
metadata:
  author: dev@potenlab.dev
  version: "0.1.0"
  date: 2026-06-15
  status: v1
  reuses: claude-in-chrome (Claude Chrome extension), chrome-devtools MCP, agent-browser
---

# verify-in-browser — every development is tested in a real browser

> **Think as a developer, respond as a designer/PM.** You verify like an engineer (real flow,
> console, network, two viewports); you report like a PM ("I tested it on phone and desktop —
> uploading and tagging both work, no errors").

## The rule (non-negotiable)

**No development is "done" until you have watched it run in a browser.** Every build, every change,
every fix, every "I think that works" — run the app and drive the real user flow before you say it is
finished or open a PR. A change you have not seen run is not verified; do not claim it works.

If you are about to type "done", "fixed", "should work now", or open a PR **without** having run this
verification in this turn — stop and run it first.

## Use the Claude Chrome extension (preferred)

Drive the running app with the **Claude Chrome extension** — the `claude-in-chrome` tools:

1. `tabs_context_mcp` — get the current tab group (call it once before anything else).
2. `tabs_create_mcp` → `navigate` to the running app URL (the local dev server, e.g.
   `http://localhost:3000`, or the sandbox preview).
3. `computer` / `read_page` / `get_page_text` — drive the **core user flow end to end** (the
   acceptance path: e.g. sign in → create the thing → see it saved → the access rule holds).
4. `read_console_messages` — confirm **no errors** (filter with a `pattern` if noisy).
5. `read_network_requests` — confirm **no failed requests** (4xx/5xx) on the core flow.
6. Capture a **walkthrough at two viewports — mobile and desktop** (screenshots, or `gif_creator`
   for a short recording). These are the evidence the user and the developer judge by.

If the Claude Chrome extension is unavailable, fall back to the **chrome-devtools** MCP or the
**agent-browser** skill — but prefer the extension. Never substitute "the code looks right" for
actually running it.

## The verification checklist (treat as a TodoWrite list — all must pass)

- [ ] App **starts** and the target screen loads (no blank page, no crash).
- [ ] The **core user flow completes** end to end — the actual thing the user asked for.
- [ ] For data/auth apps: the **access rule holds** — e.g. one account cannot see another's rows
      (verify the positive AND the negative case).
- [ ] **Console is clean** — no errors/uncaught exceptions on the flow.
- [ ] **Network is clean** — no failed (4xx/5xx) requests on the flow.
- [ ] **Mobile + desktop** walkthrough captured.

## If anything fails

Fix it **inside the sandbox**, then **re-run this whole checklist**. Never show a broken walkthrough,
never open a PR on an unverified build, and never report success on a flow you did not complete. Loop
until every box is checked.

## Report back (designer/PM language)

Translate the result — never dump console logs or stack traces in chat:

> "Tested and working. On phone and desktop I dropped in an image, tagged it, and saw it saved. I also
> checked that another account can't see your images — it can't. No errors. Here's the walkthrough."

The raw evidence (screenshots/recording, and any engineer notes) belongs in the **PR**, not the chat.
