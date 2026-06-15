---
name: supabase-integration
description: "Wire a Supabase backend into a freshly created app the right way the first time — schema, RLS, auth, migrations, and type-safe client — driven by the Supabase MCP. Use when the /design app-creation flow (or any task) needs to give a new app a working, secure Postgres backend. Triggers: 'add a backend', 'store data', 'save submissions', 'log in', 'user accounts', 'database', Supabase, RLS, migrations, auth, edge functions. Respond to designers/PMs in plain language; do the engineering underneath."
metadata:
  author: dev@potenlab.dev
  version: "0.1.0"
  date: 2026-06-12
  builds-on: supabase/agent-skills (supabase, supabase-postgres-best-practices)
---

# Supabase Integration (best-practice backend for new apps)

This skill gives a **newly created app** (from `/design`) a backend that is **secure and correct on
the first try**, so it actually runs. It is the engineer's half of the designer/PM workflow:

> **Think as a database engineer. Respond as a designer/PM.** Never show raw SQL or migration files
> unless asked. Translate "save the brief" → a table + RLS + a typed client call, and report back in
> plain language ("Briefs are now saved per user; nobody can see anyone else's.").

It builds on the official Supabase skills (`supabase`, `supabase-postgres-best-practices`), which now
**ship bundled with this plugin** — no separate install. Defer to them for deep Postgres performance
rules and current Supabase API details; this skill is the **opinionated app-creation path** on top.

---

## 0. Verify before you build (do not trust training data)

Supabase changes often. Before writing schema or auth code:

1. Fetch `https://supabase.com/changelog.md`, scan for `breaking-change` tags relevant to the task.
2. Look up the specific topic via the **MCP `search_docs` tool** (preferred), or fetch any docs page
   as markdown by appending `.md` to its URL.
3. Confirm which project you are targeting — call `list_projects` / `get_project`. **For a new
   sandbox app, never point at a production project.** Create a dedicated project/branch.

## 1. The MCP-first workflow

Use the Supabase MCP as the primary interface. Tool names you will use most:

| Step | MCP tool | Why |
| --- | --- | --- |
| Understand current schema | `list_tables`, `list_extensions`, `list_migrations` | Never invent on top of an unknown schema. |
| Iterate on schema (dev) | `execute_sql` | Runs SQL directly, **no migration history** — iterate freely. |
| Audit security/perf | `get_advisors` | Catches missing RLS, exposed `SECURITY DEFINER`, etc. Run after every schema change. |
| Commit final schema | `apply_migration` | Writes the migration entry **once**, when the design is settled. |
| Type-safe client | `generate_typescript_types` | Regenerate after every committed schema change. |
| Debug | `get_logs`, `get_advisors` | Check before guessing. |
| Client config | `get_project_url`, `get_publishable_keys` | For wiring the frontend. |

**Iterate with `execute_sql`, commit with `apply_migration`.** Do not call `apply_migration` while
still designing the schema — every call writes a history entry and you cannot iterate cleanly. Shape
the schema with `execute_sql` until it is right, run `get_advisors`, then `apply_migration` once with
a descriptive name.

## 2. Schema design defaults (apply unless told otherwise)

- **Lowercase, snake_case identifiers.** Unquoted Postgres folds to lowercase; mixed case bites later.
- **Primary key:** `id uuid primary key default gen_random_uuid()` (or `bigint generated always as
  identity` for internal high-volume tables).
- **Always** `created_at timestamptz not null default now()`; add `updated_at` with a trigger when the
  app edits rows.
- **Ownership column** on any user-owned data: `user_id uuid not null references auth.users(id) on
  delete cascade default auth.uid()`. This is what RLS keys on.
- **Foreign keys get indexes** — Postgres does not auto-index the referencing side.
- Pick precise types: `text` (not `varchar(n)`), `timestamptz` (never `timestamp`), `numeric` for
  money, an `enum` or a `check` constraint for fixed status sets.
- Constraints (`not null`, `unique`, `check`, FK) are free correctness — add them at creation.

## 3. RLS & security — the part that makes or breaks the app

**Enable RLS on every table in an exposed schema (`public` by default), at creation. No exceptions.**
A table without RLS in `public` is reachable through the Data API. Then write policies that match the
real access model — don't blanket every table with the same `auth.uid()` and call it done.

Hard rules (from the official Supabase security checklist — internalize all of them):

- **Specify the role with `TO authenticated` / `TO anon`** — `auth.role()` is deprecated and breaks
  when anonymous sign-ins are on.
- **`TO authenticated` alone is auth-without-authorization (IDOR).** Always pair it with an ownership
  predicate: `using ( (select auth.uid()) = user_id )`.
- **UPDATE needs both `USING` and `WITH CHECK`** — without `WITH CHECK` a user can reassign a row to
  someone else. Without a SELECT policy, UPDATE silently affects 0 rows.
- **Views bypass RLS** — create them `WITH (security_invoker = true)` (PG15+).
- **`SECURITY DEFINER` functions bypass RLS and are PUBLIC-callable in `public`.** Don't reach for
  `SECURITY DEFINER` to fix a permission error. Prefer `SECURITY INVOKER`; if genuinely needed, put
  the function in a non-exposed schema, set `search_path = ''`, and check `auth.uid()` inside.
- **Never use `user_metadata` / `raw_user_meta_data` in authz** — it is user-editable. Use
  `app_metadata` / `raw_app_meta_data`.
- **Storage upsert needs INSERT + SELECT + UPDATE** policies, not just INSERT.
- **Wrap `auth.uid()` as `(select auth.uid())`** in policies so the planner caches it per-statement —
  a real performance rule at scale.

Canonical per-user table policy set:

```sql
alter table public.briefs enable row level security;

create policy "owner can read"   on public.briefs for select
  to authenticated using ( (select auth.uid()) = user_id );
create policy "owner can insert" on public.briefs for insert
  to authenticated with check ( (select auth.uid()) = user_id );
create policy "owner can update" on public.briefs for update
  to authenticated using ( (select auth.uid()) = user_id )
                        with check ( (select auth.uid()) = user_id );
create policy "owner can delete" on public.briefs for delete
  to authenticated using ( (select auth.uid()) = user_id );
```

After any schema/policy change: **run `get_advisors` (security + performance) and fix what it flags
before moving on.**

## 4. Auth & client wiring

- Use `@supabase/ssr` for Next.js (the app's stack). Never the legacy `auth-helpers`.
- **Use `getClaims()` / `getUser()` for trust decisions — not `getSession()`** in server code.
- **Only ever ship the publishable key to the browser.** `service_role` / secret keys stay
  server-side; in Next.js anything `NEXT_PUBLIC_` is public. Never put a secret behind that prefix.
- Regenerate types with `generate_typescript_types` after every committed migration and import them
  so client calls are type-checked.

## 5. Commit & verify

When the schema is settled:

1. `get_advisors` (security + performance) → fix everything.
2. `apply_migration` with a descriptive name (one coherent change).
3. `generate_typescript_types` → save into the app.
4. **Verify it works** — run a real `execute_sql` insert/select as the intended role, confirm RLS
   lets the owner in and keeps others out. A backend without a verifying query is not done.

## 6. Reporting back (designer/PM mode)

Translate the result, never dump SQL:

> "Done. Briefs are now saved to a database. Each person only ever sees their own — I tested that
> someone else's account can't read them. Login is wired up. This all lives in the app's own sandbox,
> nothing touches our live customer data."

If a request would cross the sandbox boundary (touch a production DB, real customer data, shared
secrets, billing/auth of an existing system), **stop** and write a dev-handoff note instead — same
guardrail as the rest of `/design`.

---

## Reference

- Official skills: `supabase`, `supabase-postgres-best-practices` — bundled in this plugin under `skills/`
  (vendored from `supabase/agent-skills`, MIT). Stand-alone install: `npx skills add supabase/agent-skills`.
- Security index: `https://supabase.com/docs/guides/security/product-security.md`
- RLS guide: `https://supabase.com/docs/guides/database/postgres/row-level-security.md`
- MCP setup: `https://supabase.com/docs/guides/getting-started/mcp`
