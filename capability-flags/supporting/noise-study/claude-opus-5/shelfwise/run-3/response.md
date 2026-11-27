**LID Coach — Shelfwise**

## Executive summary

**Posture:** *Well-formed design layer; the arrow stops at specs, and one core allocation choice leans against its own tenet.*

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no schemas, signatures, or pseudocode bleeding upstream
- ✓ Spec form — 13 EARS-shaped specs, uniquely IDed, scoped rather than falsely ubiquitous
- ✓ Mode fit — Full matches a two-component project that is LID top to bottom
- ⚠ Decision capture — the most contestable allocation choice lives in body prose, not in the Decisions table
- ⚠ Tenet coherence — the branch-preference rule in hold allocation leans against "waiting is honored in sequence"
- ✗ Arrow completeness — every spec is marked `[x]`, but no tests or code anywhere cite them

**Headline:** The design layer is genuinely good — a tight HLD with real tenets, two cleanly separated leaves, and decision tables that mostly let a cold reader reconstruct the choice; the fastest wins are closing the arrow past EARS and getting the allocation-order decision (and its tension with your first tenet) onto the page.

## Findings (14 total · 5 high · 6 medium · 3 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block carries `Mode`/`Version` but no LID directives — nothing tells a fresh session to run the workflow · *modes are declared, not inferred* — the foundation should be visible, not assumed · → `/update-lid`
- **F2 (high):** All 13 specs are marked `[x]`, yet the repo holds no tests, no code, and zero `@spec` annotations · *canonical arrow shape* and *tests carry `@spec` annotations* — the arrow is only walkable if the downstream phases exist
- **F3 (high):** Allocation prefers holds whose pickup branch is the scanning branch, so a later requester can be served before an earlier one — the tenet says "nobody's wait is lengthened by a patron who asked after them" · *tenets capture forward-looking preference*
- **F4 (high):** That same branch-preference choice has no Decisions & Alternatives row; its rationale ("keeps most copies off the courier van") sits in body prose · *docs carry current intent* — decision capture
- **F5 (high):** Both HLD goals need retained timing/expiry data, but closed holds are deleted (tenet 4, `PICKUP-003`, `PICKUP-005`) and no node owns measurement · *effective intent-tree alignment* — named intent with no design component drifts silently
- **F6 (medium):** Goal 1's 4-business-hour target is unscoped against the design's own transit path on a once-daily courier van · *coherence is adjacency* — HLD and LLD disagree at the seam
- **F7 (medium):** `pickup-notices-design.md` says the hold closes when the window lapses; `PICKUP-004`/`PICKUP-005` close it only when staff scan the copy off the shelf · *coherence is adjacency* — LLD/spec drift
- **F8 (medium):** Cancellation is specified only for the in-transit case (`HOLDALLOC-007`); cancelling a plain waiting hold, or one whose copy is already on a holds shelf, is unspecified · *LLDs close enough of the solution space*
- **F9 (medium):** The "re-run allocation as a check-in" contract is restated in prose in both leaves with no spec-ID linkage between them · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F10 (medium):** Neither spec file carries `prefix:` frontmatter; `HOLDALLOC` and `PICKUP` derive informally (and inconsistently) from their directory names · *specs are grep-anchored linkage*
- **F11 (medium):** Tenets 3 and 4 read as triggered rules already encoded in specs rather than tie-breakers, and the four are unordered though they can conflict (hear-once vs. failed delivery; no-history vs. Goal 2) · *tenets capture forward-looking preference*
- **F12 (low):** The `allocated` marker has no spec saying when it clears — checkout, expiry, and cancellation all leave it implicit · *LLDs close enough of the solution space*
- **F13 (low):** "Failed delivery" is undefined for the automated-dialer channel (no answer? voicemail? busy?), though `PICKUP-006` treats all three channels alike · *scope disambiguation*
- **F14 (low):** The HLD has no non-goals or target-users section; boundaries (catalog management, courier logistics, staff-facing UI) are implicit · *HLD is architecture and rationale*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs and both spec files under `docs/intent/` — all 6 markdown files in the repo
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 7 Decisions & Alternatives rows
- Searched tree-wide: `@spec` annotations (0 matches), source and test files (none — the repo is docs-only), `docs/arrows/` (overlay not installed, which is a reasonable call at this size)
- Cold-read pass over all 5 LID docs; decisions sweep over all 7 table rows
- Dispatch: LID-shaped artifacts present, instruction file missing directives → full review anchored on the artifacts, with the configuration gap raised as F1. Mode read as `Full` from the `## LID` block

## Worth a second look

Models in my class are known to miss designs that contradict the project's own tenets — please check both leaf designs against your HLD tenets yourself; I found one in F3 and there may be more. (I could not read the core skill's capability-flags reference from this session, so I am taking the skill's stated default and treating the flags as applying.)

## Where to go next

Want me to walk through the findings in detail, focus on a theme or priority (the tenet/decision cluster in F3–F5 is the richest), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on Shelfwise — when it's worth installing the arrow overlay, how to handle cross-cutting concerns like metrics, where PRDs fit, or what changes once implementation starts landing — I can help with those too.