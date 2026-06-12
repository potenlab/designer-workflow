# Dev-handoff note template

Use this **instead of** reaching outside the sandbox (SKILL.md §2). Produce it whenever building the
app would require touching another app/repo, a production database or migration, shared secrets /
`.env*`, or the auth/billing of an existing system.

Tell the user, in plain language, what you did — then drop this note for the developer.

> To the user: *"This part needs a developer — it connects to our real customer data, which the app
> sandbox can't touch on its own. I've written up exactly what's needed so [dev] can do it safely.
> Everything else is built and running."*

---

```markdown
## Dev handoff — <app name>

**Why this needs a developer:** <one line — e.g. "writes to the production `clients` table">

**What the design flow already built (in sandbox):**
- <branch / app folder>
- <Supabase sandbox project/branch it created>
- <what runs today>

**The out-of-sandbox change needed (NOT done — for a human):**
- Target: <which repo / which production project / which secret>
- Change: <precise description — table, policy, env var, auth/billing hook>
- Risk: <what could break; data exposure; migration ordering>
- Suggested check: `get_advisors` after, verify RLS with a real query as the intended role

**Acceptance for the dev's part:**
- [ ] <verifiable outcome 1>
- [ ] <verifiable outcome 2>
```

---

Keep the note concrete and copy-pasteable. The developer should be able to act on it without
re-interviewing the designer/PM.
