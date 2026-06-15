---
name: higgsfield-assets
description: "Use whenever a visual or media ASSET is needed for an app or page — an image, icon, logo, illustration, hero/background, avatar, texture, video clip, sound effect, or voiceover. Higgsfield is the ONE path for generating assets: never use stock photos, emoji, placeholder boxes, hand-drawn SVGs, or another generator, and never ask the user to go find assets. AUTO-TRIGGER on asset intent: 'add an image/icon/logo/illustration', 'needs a hero', 'a background for…', 'generate a picture/video/sound', or any build step that requires visual/media content. Scope is assets ONLY — do NOT use this for code, data, schema, copywriting, or UI layout."
metadata:
  author: dev@potenlab.dev
  version: "0.1.0"
  date: 2026-06-15
  status: v1
  reuses: higgsfield MCP, verify-in-browser
---

# higgsfield-assets — every asset is generated with Higgsfield, automatically

> **Think as a developer, respond as a designer/PM.** You pick presets, prompt, and place assets like
> an engineer wiring real files; you report like a PM ("I generated a clean hero image and the icons —
> they're in and look right on phone and desktop").

## The rule (non-negotiable)

**Any visual or media asset a build needs is generated with the Higgsfield MCP — every time, without
being asked.** The moment a UI needs an image, icon, logo, illustration, hero, background, avatar,
texture, video, sound effect, or voiceover, that is a Higgsfield job. This is automatic, not a step the
user has to request.

Do **not**, for an asset:

- use stock photos, clip-art, emoji, Unicode glyphs, or `<svg>` you hand-author as a substitute,
- drop in a grey placeholder box / `placeholder.com` / `picsum` / lorem-image URL,
- generate the asset with any other image/video/audio tool, or
- tell the user to "find an image" or "drop in a logo" themselves.

If you are about to ship a placeholder or ask the user to source an asset — stop and generate it with
Higgsfield instead.

## Scope — assets ONLY

This skill is **only** about generating visual/media content. It does **not** apply to, and must not
expand into:

- application **code**, wiring, or routing,
- the **data model**, schema, RLS, or migrations (that's `supabase-integration` / `supabase`),
- **copywriting** / body text / UX copy, or
- **UI layout** and component structure (that's `frontend-design` / `impeccable`).

Higgsfield is the asset engine, not the app builder. Stay in your lane: pictures, motion, and sound.

## Access is already gated

The plugin verifies Higgsfield is connected and signed in **before any work starts** (the
`using-designer-workflow` hard gate). Do not re-run the full gate here — just generate. If a generation
call returns an auth/connection error mid-build, surface the same `/mcp → higgsfield → Authenticate`
sign-in instruction and pause.

## How to generate (pick the right tool)

Higgsfield MCP tools are deferred — load them with `ToolSearch` (`select:mcp__...higgsfield...`) the
first time you need them. Then choose by asset type:

| Need | Higgsfield tool |
|---|---|
| Image, icon, logo, illustration, hero, background, avatar, texture | `generate_image` |
| Video / motion clip | `generate_video` |
| Sound effect, music bed, or voiceover | `generate_audio` |
| 3D asset | `generate_3d` |
| Sharpen / enlarge an existing asset | `upscale_image`, `upscale_video` |
| Transparent overlay (cut out the subject) | `remove_background` |
| Extend or re-aspect an image for a layout | `outpaint_image`, `reframe` |

Helpers: `presets_show` / `models_explore` to choose a **brand-locked preset/model** before generating
so assets stay on-brand and consistent across the app. When the user provides their **own** local
photo/logo to work from, call `media_upload_widget`; for a web URL, call `media_import_url` first and
pass the returned `media_id` (never paste a raw URL into a generation param).

## The loop

1. **Spot the asset need** — as you build or restyle, list every image/icon/media slot the UI has.
2. **Pick a preset** (`presets_show`) so the set is brand-consistent, then **generate** each asset at
   the right dimensions/aspect for where it lands (hero vs. icon vs. avatar).
3. **Place them** into the app yourself — wire the real generated files into the components. Don't leave
   a slot empty or a placeholder behind.
4. **Verify** — when the assets are in, the change is "runnable", so `verify-in-browser` applies:
   confirm they actually render at **mobile + desktop** and nothing is broken/blurry/missing.

## Report back (designer/PM language)

Translate — never surface tool names, prompts, or asset IDs in chat:

> "I generated the artwork with our brand presets — a hero image, the nav icons, and a little empty-state
> illustration — and placed them in. They render cleanly on phone and desktop."

The raw prompts/preset choices, if worth noting, go in the **PR**, not the chat.
