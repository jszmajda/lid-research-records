# LID Coach — Visit Planner

## 1. Executive summary

**Posture:** *Healthy design layer; the arrow's downstream phases haven't started yet.*

**Scorecard**
- ⚠ Arrow completeness — HLD, LLDs and EARS are all present; no tests, no code
- ⚠ Linkage — spec IDs are clean and greppable, but no `@spec` annotations exist yet and LLDs carry no `prefix:` frontmatter
- ⚠ Cascade health — two seams look unresolved: withdrawal vs. in-flight offers, and the short-notice claim path vs. the HLD tenet
- ✓ Tenet quality — four real tie-breakers, each with a defensible opposite
- ⚠ Configuration — mode marker is declared; the mandatory directive block is absent
- ✓ Mode fit — Full mode matches a whole-repo design

The design layer here is genuinely strong — the HLD reads like it was written for a cold reader, and the two LLDs close most of their own decision space. The fastest wins are configuration reconciliation (`/update-lid`) and status honesty: every spec is marked implemented, and nothing implements them.

## 2. Findings

**Findings (13 total · 5 high · 6 medium · 2 low)**

- **F1 (high):** `CLAUDE.md` declares `- Mode: Full` but has no `## Linked-Intent Development` directive block — no mandatory skill reference, navigation table, terminology, or `@spec` convention · *modes are declared, not inferred* — a mode bullet without the directives that operationalize it leaves a future session guessing the workflow → run `/update-lid`
- **F2 (high):** All 15 specs are marked `[x]` (implemented) while the repo contains zero source files, zero tests, and zero `@spec` annotations — the arrow stops at EARS · *canonical arrow shape* — the Tests and Code phases are missing for every component · *intent leads; code is compiled output* — markers claiming a state the code doesn't have is the drift this principle protects against
- **F3 (high):** "Compatible" (FILL-001/005) and "eligible" (FILL-004/006) are never defined, and no rule maps intake's stored fields (service, sites, time window, accessibility needs) onto the matching decision · *LLDs close enough of the solution space* — two agents reading this would land on different matchers, which is exactly where intent drift enters
- **F4 (high):** The short-notice path lets "any eligible signed-in account" claim a published opening (FILL-004) before the matcher runs (FILL-005) — this contradicts the HLD tenet **First asked, first served**, and no Decisions row records the trade-off · *tenet cascade* — name the tenet, the mechanism, and the condition; consider whether staff or drive-by accounts should claim ahead of the least-`enteredAt` entry
- **F5 (high):** Withdrawal excludes an entry from matching (INTAKE-007) but says nothing about an offer already outstanding — a withdrawn patient can still claim, and the rule belongs at the seam, not inside either segment · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across* — this is a cross-boundary obligation currently owned by nobody
- **F6 (medium):** Both LLDs lack `parent:`/`prefix:` frontmatter, and `FILL-*` doesn't spell `fulfillment/` — the ID→leaf bridge is guesswork today · *effective intent-tree alignment* — the leaf's `prefix:` is the authoritative namespace pointer
- **F7 (medium):** The staff-assisted path exists only as context — "staff may act for patients who call" (HLD) and "or with staff assistance" (Intake) — with no design section, no spec, and no statement of who the actor is in FILL-008's event · *LLDs close enough of the solution space*
- **F8 (medium):** The two-hour offer window lives only in Fulfillment's prose (FILL-002's trigger depends on it), and neither the 36-hour threshold nor the 20-minute scan delay has a spec or a Decisions row · *decision capture* — a cold reader will ask "why 36?" and cannot reconstruct what was given up
- **F9 (medium):** Cold-read ambiguities in the intake segment: INTAKE-006's "create a newly timed entry" doesn't say whether the replacement gets a fresh `enteredAt` (which decides queue position), and the design's "Exact retries" doesn't line up with the spec's "idempotency key" mechanism · *docs carry current intent, written to be read cold*
- **F10 (medium):** The HLD omits Non-Goals, Target Users, Key Design Decisions, and Success Metrics · *HLD is architecture and rationale* — those sections are where the "why" belongs, above the LLDs
- **F11 (low):** "Registry scan" and "checkout" are undefined jargon in Fulfillment Design · *docs carry current intent, written to be read cold* — a fresh author would name the scan's scope
- **F12 (low):** Spec lines use `- [x] **ID** When …` where the EARS reference format is `- [x] **ID**: When …` · *minimum surface, maximum discipline* — a parser or grep habit keyed on `**ID**:` will miss these
- **F13 (low):** With no `docs/arrows/` overlay, the deterministic linkage and coherence checks aren't available for the eventual code · consider `/arrow-maintenance` once implementation lands

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake`, `fulfillment`), both spec files, and the LID reference material (EARS syntax, LLD templates, instruction-file template)
- Enumerated: 2 LLDs, 2 spec files, 15 specs (INTAKE-001…007, FILL-001…008), 8 Decisions rows across both LLDs
- Sampled: the entire repository — 6 tracked files, no source, no tests, no `@spec` annotations, no `docs/arrows/` overlay; no residue markers (`[obsolete]`, `[inferred]`, changelog sections) found
- Cold-read pass: all 5 LID docs read as a fresh author with no conversation context; all 8 Decisions rows swept forward from the landed design

## 4. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---
*Defaults taken (non-interactive run):* proceeded with a full review in the declared **Full** mode — the instruction file is present and the project is LID-shaped, though the missing directive block was surfaced as F1 rather than blocking; no `## LID Scope` section was expected or used; the report is rendered inline and **no files were edited** (the coach is advisory — F1/F6 point at `/update-lid`, F13 at `/arrow-maintenance`); questions the skill would normally ask were resolved by taking its stated defaults.