# Technical spec template — `/docs/plan/<slug>.md`

This is the **engineer-facing** build contract. It is written to a file and **never shown in chat**.
Be precise and technical here — this is the one place in the planning phase where engineer language
belongs. `goal-loop` and `design` build directly against this; each GitHub child story points at its
section via the **Story → implementation map**.

Fill every section. Keep it concrete and buildable, scoped to the sandbox boundary in
`.designer-workflow/config.md`.

```markdown
# Spec — <App / feature name>

- **Slug:** <kebab-case, matches the filename and the sandbox app folder>
- **Status:** planned
- **Created:** <YYYY-MM-DD>
- **Epic:** <#NN once the GitHub epic exists>
- **Sandbox app lives in:** <apps/<slug>/ or fresh repo — from config.md>

## 1. Summary
<2–4 sentences: what the app does, who uses it, the one core flow.>

## 2. Users & access model
- **Roles / who sees what:** <e.g. authenticated user sees only their team's rows>
- **Auth:** <Supabase Auth — email/password, magic link, etc.>
- **RLS model:** <per-table policy intent — the rule each table enforces>

## 3. Data model
<Each table: columns, types, nullability, defaults, FKs, indexes, constraints.>

| Table | Column | Type | Notes (PK/FK/default/constraint) |
|---|---|---|---|
| <table> | <col> | <type> | <PK / FK→… / default / unique / check> |

- **Relationships:** <one-to-many / many-to-many, join tables>
- **RLS policies (per table):** <select/insert/update/delete predicates>

## 4. Types
<Shared TS types / generated Supabase types the UI and client share.>

## 5. Routes / API / pages
| Route | Purpose | Data in | Data out | Auth |
|---|---|---|---|---|
| <path> | <what it does> | <input> | <output> | <public / authed / role> |

## 6. Edge cases & error states
- <empty states, optimistic update failures, permission-denied, network errors, validation>

## 7. Assets needed (built later via higgsfield-assets)
- <images / icons / illustrations the UI needs — names only; generated at build time>

## 8. Sandbox boundary
- **Stays inside:** <the new app's own branch + its own Supabase project/branch>
- **Must NOT touch:** <production DBs, other apps, .env*, existing auth/billing — from config.md>
- **Out-of-sandbox needs (if any) → dev handoff, not a breach:** <none | describe>

## 9. Story → implementation map
<One row per GitHub child story. This is how each issue links back to this spec.>

| Story (issue) | Spec sections it touches | Acceptance (verifiable) |
|---|---|---|
| <#NN — Submit a brief> | §3 (briefs table), §5 (/submit), §2 (insert policy) | <a brief is saved and visible> |
| <#NN — Only-my-team> | §2 (RLS), §3 (team_id) | <account B cannot see account A's briefs> |

## 10. Build order
<The order goal-loop should walk the stories — dependencies first (schema before UI, auth before
per-team filtering, etc.).>
```

Keep it copy-pasteable and unambiguous: an engineer (or `goal-loop`) should be able to build each story
from its mapped sections without re-interviewing the designer/PM.
