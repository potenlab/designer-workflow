---
description: Plan an app or feature before building it — clarify the idea with questions, write a technical spec to /docs/plan, and open a designer-language GitHub epic + child-story issues, then (on your okay) build it autonomously story by story. The explicit way to kick off the planning pipeline when auto-trigger is borderline.
argument-hint: "[optional: a one-line description of the app/feature to plan]"
allowed-tools: Skill, Bash, Read, Write, Edit, Glob, Grep
---

# Designer Workflow — plan an app/feature (`dw-plan`)

This is the **explicit, guaranteed** entry to the planning pipeline. Auto-activation usually starts it
on its own from a plain "build me…" message; use this command when you want to be certain it fires, or
to kick it off from an ambiguous prompt.

`$ARGUMENTS` (optional) is a one-line description of what to plan. If empty, ask the user, in plain
language, what they want to build.

**Invoke the `plan-and-spec` skill** with the `Skill` tool and follow it exactly. It will:

1. **Clarify** the idea with a few plain-language questions (who uses it, what it stores, the main
   flow, what's in/out of scope for v1).
2. **Restate** the plan and the story breakdown, then ask **one** question: *"Is this plan correct?"*
3. On **yes**: write a **technical spec** to `/docs/plan/<slug>.md` (never shown in chat) and file a
   **designer-language GitHub epic + one child issue per story**.
4. **Hand off to `goal-loop`** on that same yes — it builds the stories autonomously, one per turn
   (build → verify in a browser → one PR per story), and reports when the whole goal is done.

If the user says **"just plan it, don't build yet,"** stop after the issues are filed and do **not**
start `goal-loop`. The user always wins.

Keep every message to the user in **plain language** — the technical detail lives only in the spec
file and the PRs, never in chat.
