# LID Coach — Shelfwise

## Executive summary

**Posture:** Well-shaped design layer, with one tenet conflict in allocation and no downstream arrow yet.

**Scorecard**
- ✓ Design-tree shape — one HLD, two leaf LLDs that match its Components list, one spec file each
- ✓ Spec hygiene — clean EARS, unique and stable IDs, every LLD behaviour traceable to a spec
- ✓ Mutation hygiene — all five docs read cold as current intent; no history or chat residue
- ⚠ Decision capture — pickup-notices rows are exemplary; the most contestable choice in hold-allocation has no row
- ⚠ Tenet cascade — local-branch-first allocation works against "waiting is honored in sequence"
- ✗ Arrow completeness — no tests or code in the repo, yet all 13 specs are marked `[x]`

**Headline:** The docs are tight, and the pickup-notices Decisions table is a model of the form: the reminder and expiry rows each name the tenet or goal they trade against and the cost accepted. The most valuable next step is to give local-branch-first allocation the same treatment, because as written it contradicts your first tenet without saying so.

## Findings (8 total · 3 high · 3 medium · 2 low)

- **F1 (high):** Local-branch-first allocation lets a later request jump an earlier one. A copy scanned at branch A goes to A's oldest hold even when a patron at branch B asked first, which the tenet "nobody's wait is lengthened by a patron who asked after them" rules out. This is in `hold-allocation-design.md:11` and HOLDALLOC-003/004, and it recurs wherever allocation re-runs "as a check-in at that branch" (HOLDALLOC-007, PICKUP-005). · *tenet cascade* — leaf designs should lean the way the HLD's tenets say, or record the exception.
- **F2 (high):** The local-first choice has no Decisions & Alternatives row. The courier-van rationale sits in body prose only, with no rejected alternative (strict county-wide order), no tenet named and no cost stated. · *decision capture* — a choice a cold reader would question needs its trade-off on the page.
- **F3 (high):** All 13 specs are marked `[x]`, but the repo holds no tests, no code and no `@spec` annotations. If the implementation lives in another repo, consider saying where; if not, the markers overstate the arrow. · *canonical arrow shape* — HLD → LLDs → EARS → tests → code, with each phase present or its absence explained.
- **F4 (medium):** `CLAUDE.md` has the `## LID` mode block but none of the linked-intent-dev workflow directives, so future sessions learn the mode without the workflow. `/update-lid` reconciles this. · *modes are declared, not inferred* — the instruction file is where a session learns how to work here.
- **F5 (medium):** Hold cancellation has no design or spec. It appears only as a precondition in HOLDALLOC-007. Nothing says how a patron cancels, what happens to a copy already on the holds shelf, or that the record is deleted, which "hold history is not kept" would require. · *LLDs close enough of the solution space* — two agents should land on compatible implementations.
- **F6 (medium):** The LLD and specs disagree on when a lapsed hold closes. `pickup-notices-design.md:11` reads as closing at lapse; PICKUP-005 closes it when staff scan the copy off the shelf. Whether a patron can still collect in between is open. · *coherence is adjacency* — each level agrees with the one next to it.
- **F7 (low):** A lapsed hold closes without telling the patron, and a failed delivery is handled by a staff phone call rather than the chosen channel. Consider stating whether "each event produces one message, on the channel the patron chose" covers these. Dialer failures (no answer) are also unaddressed in `pickup-notices-design.md:13`. · *tenet cascade / LLD sufficiency*.
- **F8 (low):** The four tenets are unordered, though they can pull against each other and against the goals, as F1 shows. The HLD also has no non-goals or target-users section. · *tenets capture forward-looking preference* — tie-breakers work best ranked.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/` (6 files, the whole repo)
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs (HOLDALLOC-001–007, PICKUP-001–006), 7 Decisions rows
- Code and tests: none present, so nothing to sample; 0 `@spec` references
- Arrow overlay: `docs/arrows/` is not installed, so no structural audit was available
- Dispatch: LID-shaped artifacts are present and the mode is declared Full, but the instruction file lacks the directive block. I ran a full review and raised the gap as F4.
- Non-interactive run: no clarifying questions were asked, nothing was written to disk, and no project files were edited.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.