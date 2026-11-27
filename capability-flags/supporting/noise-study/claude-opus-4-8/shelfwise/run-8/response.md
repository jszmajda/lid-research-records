Dispatch and inputs are settled. The project is LID-shaped (populated HLD + two LLDs + two spec files), Full mode, no arrow overlay, no code/tests yet. The instruction file carries a `## LID` block (Mode + Version) but no `linked-intent-dev` directive text, so I'm proceeding with a full review anchored on the artifacts and surfacing the config gap as a finding (per the dispatch table). I could not read the sibling `linked-intent-dev/references/capability-flags.md` (outside this session's allowed directories), so per the skill I treat the capability flags as applying.

---

# LID Coach — Shelfwise

## Executive summary

**Posture:** Healthy, well-linked design — with a tenet the allocation logic quietly contradicts.

**Scorecard**
- ✓ **Linkage** — spec IDs (`HOLDALLOC-###`, `PICKUP-###`) are unique, zero-padded, grep-anchored, and trace cleanly to their leaf LLDs
- ✓ **HLD discipline** — architecture and rationale only; no schemas, signatures, or algorithm detail bleeding upstream
- ✓ **Granularity** — one LLD per intent component, matching the HLD's two named components exactly
- ⚠ **Tenet coherence** — the branch-first allocation order contradicts *"waiting is honored in sequence"*
- ⚠ **Decision capture** — the most consequential allocation choice isn't in any Decisions table
- ⚠ **Configuration** — the instruction file declares Mode/Version but carries no LID directive block

**Headline:** The arrow is small but genuinely coherent — two components, cleanly linked HLD → LLD → EARS, with disciplined docs and real tenets. The single most valuable move is reconciling the hold-allocation design with your own *"waiting is honored in sequence"* tenet (and recording that choice), because a future session reading the tenet will build something the design contradicts.

## Findings (6 total · 2 high · 3 medium · 1 low)

- **F1 (high):** Branch-first allocation (`HOLDALLOC-003`/`-004`) lets a later-requesting local patron receive a copy ahead of an earlier county-wide requester — contradicting the HLD tenet *waiting is honored in sequence* · *tenets capture forward-looking preference* / *coherence is adjacency*
- **F2 (high):** Instruction file has a `## LID` block (Mode: Full, Version 1.4.0) but no `linked-intent-dev` directive block · *modes are declared, not inferred*
- **F3 (medium):** The branch-local-priority vs. strict-FIFO choice — the design's load-bearing decision — is absent from hold-allocation's Decisions & Alternatives · *docs carry current intent* (decision capture)
- **F4 (medium):** Hold cancellation is referenced but under-specified — no spec covers cancelling a hold, or a cancellation while the copy sits on the holds shelf (only the in-transit case, `HOLDALLOC-007`) · *LLDs close enough of the solution space*
- **F5 (medium):** `HOLDALLOC-005` (no open holds → no slip, reshelve) has no counterpart in the hold-allocation design prose · *coherence is adjacency*
- **F6 (low):** The arrow stops at specs — no tests or code phase yet — while every spec is marked `[x]`; confirm what that status marker means before implementation begins · *tests before code* / *canonical arrow shape*

## What was audited

- **Read fully:** `CLAUDE.md`; `docs/high-level-design.md`; both LLDs and both spec files under `docs/intent/` (`hold-allocation/`, `pickup-notices/`)
- **Counted:** 2 LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 4 tenets
- **Searched:** repo-wide for code, tests, `@spec` annotations, and a `docs/arrows/` overlay — none present (design-stage project; arrow-maintenance overlay not installed)
- **Cross-checks:** each LLD design behavior against its specs; each spec's leaf prefix against its owning LLD; the allocation and pickup designs against the HLD tenets; every Decisions & Alternatives row against the cold-reader reconstruction test

## Worth a second look

Models in my class are known to miss designs that contradict a project's own tenets — the exact shape of F1. I believe I've caught the sequencing conflict, but please read the two leaf designs against your four HLD tenets yourself to confirm I haven't missed another (e.g., whether *"patrons hear once"* is fully honored across the failed-delivery and expiry paths).

---

Want me to walk through the findings in detail, focus on a theme or priority (the tenet/decision pair in F1–F3 is where I'd start), or work a specific item together? You can also pick a single finding to dig into.

If you have broader questions about using LID for Shelfwise — where a PRD would sit above this HLD, when to promote a component to a sub-HLD, or how the tests/code phases should come in as you start building — I'm glad to work through those too.