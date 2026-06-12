# Golden prompts — designer + PM app ideas

These are the real, plain-language prompts a **designer** or **PM** would actually type. They seed the
acceptance set (SKILL.md §4) and tune the auto-trigger. The skill must fire on all of these, run the
full loop, and stay inside its sandbox.

> Status: starter set. Replace/extend with 5–6 real prompts collected from the team (proposal §9).

## Designer-voiced (visual / content tools)

1. "a clean little gallery app where I drop images and tag them, and can filter by tag"
2. "make me a tiny mood-board tool — I paste links and images into columns and rearrange them"
3. "I want a one-page site that shows our case studies as cards, each opens into a full write-up"

## PM-voiced (process / internal tools)

4. "an intake tool: clients submit a brief, and we track it New → Doing → Done"
5. "a little app where the team logs weekly wins, and I can see them grouped by person"
6. "something where I can list our experiments, their status, and the result, and share a read-only view"

## Negative cases — the skill must STAY QUIET on these

- "make this button calmer" — editing one existing component.
- "why is the tasks page empty?" — a question / debugging.
- "review this PR" — code review.
- "just write the SQL for a users table" — explicit single-layer ask (route to supabase-integration
  directly, not the full design loop).

## What "pass" looks like per prompt

For each positive prompt, the loop should: restate the plan in plain language → confirm → build full
stack in a sandbox branch → run + capture a mobile + desktop walkthrough → open a PR — and never show
the user raw code or reach outside the sandbox.
