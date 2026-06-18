# GitHub issue templates — epic + child stories (designer language)

These are the **product-facing** tracking artifacts. Unlike the spec, issues are written in **plain
designer/PM language** — user stories and plain acceptance criteria. **No SQL, no schema, no file
paths, no migration talk.** An engineer reads the spec the issue links to; the issue itself is for the
team to track.

Create everything with the **`gh` CLI**. Confirm a remote first (`gh repo view`). If there's no remote,
don't file anything — write this same breakdown as a checklist into the spec file and tell the user.

## Labels (create if missing)

```bash
gh label create epic   --color 5319E7 --description "Designer-workflow epic" 2>/dev/null || true
gh label create story  --color 0E8A16 --description "Designer-workflow child story" 2>/dev/null || true
gh label create change --color FBCA04 --description "Designer-workflow focused change" 2>/dev/null || true
```

## 0. Small focused change → a SINGLE issue (no epic)

For a restyle, a tweak, or a small fix, **don't** create a four-story epic — file ONE issue. You still
always file at least one issue; it's just sized to the work.

```bash
gh issue create --label change --title "<Plain change name, e.g. Restyle the Community tab>" --body-file <(cat <<'EOF'
## What's changing
<2–3 plain sentences: what the user will see different and where.>

## Acceptance criteria
- [ ] <plain, verifiable outcome — what looks/behaves different>
- [ ] Works on phone and desktop, nothing else visibly broken.

<sub>Build notes for the developer: `/docs/plan/<slug>.md`.</sub>
EOF
)
```

Use the epic + child stories below instead **only** for new or multi-part work.

## 1. The epic (the product vision)

```bash
gh issue create --label epic --title "<App name>" --body-file <(cat <<'EOF'
## What we're building
<2–4 plain sentences: what the app does and who it's for. No jargon.>

## Why
<the outcome / problem it solves>

## The pieces (stories)
<!-- Fill the issue numbers AFTER creating the child issues below, then edit this epic. -->
- [ ] #NN — <Story 1, one plain line>
- [ ] #NN — <Story 2>
- [ ] #NN — <Story 3>
- [ ] #NN — <Story 4>

## Done when
- Every story above is checked off, built, and verified running on mobile + desktop.

<sub>Technical plan: `/docs/plan/<slug>.md` (for the developer).</sub>
EOF
)
```

## 2. Each child story (one user story per issue)

```bash
gh issue create --label story --title "<Story name, plain>" --body-file <(cat <<'EOF'
**Part of:** #<epic number>

## Story
As a <who>, I can <do this> so that <benefit>.

## Acceptance criteria
- [ ] <plain, verifiable outcome — what the user sees/does>
- [ ] <another outcome>
- [ ] Works on phone and desktop, nothing visibly broken.

<sub>Build notes for the developer: `/docs/plan/<slug>.md` → <section refs>.</sub>
EOF
)
```

## 3. Wiring epic ↔ children

1. Create the child issues first; capture each returned issue number.
2. Edit the epic's checklist to reference each child by `#NN` (`gh issue edit <epic> --body-file …`).
3. Each child keeps **Part of: #<epic>** at the top.

## Rules

- **Issue body = designer language.** If you're about to write a column name, a policy, or a path in an
  issue — stop; that belongs in the spec. The issue only links to the spec via the small `<sub>` note.
- **One story = one independently-buildable, independently-verifiable slice.** `goal-loop` builds one
  per turn and opens one PR per story that closes that issue.
- Keep acceptance criteria **verifiable in a browser** — they're what `verify-in-browser` checks and
  what closes the issue.
