**Shelfwise — LID Coach Review**

## Executive summary

**Posture:** Strong intent layer; the arrow stops at EARS, and a few load-bearing decisions lean against the HLD's own tenets.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no schemas or signatures bleeding upstream
- ✓ Spec craft — clean EARS phrasing, unique IDs, scoped WHEN clauses, no obsolete residue
- ✓ Mode fit — Full matches a project where every component is under LID
- ✗ Arrow completeness — no tests and no code for either component, though all 13 specs are marked `[x]`
- ⚠ Tenet cascade — branch-first allocation and record deletion work against stated tenets and goals under conditions the docs describe
- ⚠ Decision capture — the design's most reversible choice survives only as prose
- ⚠ Configuration — the `## LID` block is present, but the instruction file never names Linked-Intent Development

**Headline:** Two components, two clean design docs, and 13 well-formed specs that a cold reader can follow — that's the hard part done. The fastest wins are closing the arrow's bottom half (tests and code, or a note saying where they live) and getting the branch-priority rule onto the record, since it currently contradicts the first tenet in the HLD.

## Findings (14 total · 5 high · 6 medium · 3 low)

- **F1 (high):** `CLAUDE.md` carries `## LID` mode/version but no LID directive block — run `/update-lid` to reconcile · *modes are declared, not inferred* (the mode must be readable, not inferred from artifacts)
- **F2 (high):** Arrow ends at EARS — no tests, no code, no `@spec` annotations anywhere, yet every spec is checked `[x]` · *canonical arrow shape*; *coherence is adjacency* (adjacent levels must agree, or downstream sessions fill the gap themselves)
- **F3 (high):** `HOLDALLOC-003`/`004` serve a later hold whose pickup branch matches the scanning branch ahead of an earlier county-wide hold — directly against *"Waiting is honored in sequence… nobody's wait is lengthened by a patron who asked after them"* · *tenet cascade* (design nodes should lean the way the HLD says to lean, or record the exception)
- **F4 (high):** That branch-first rule appears only as a prose aside ("keeps most copies off the courier van") — no Decisions & Alternatives row, though pure FIFO is the obvious reversal a cold reader would reach for · *decision capture* (a choice a reader would still question needs its alternative and accepted cost on the page)
- **F5 (high):** `PICKUP-003`/`005` delete the hold record on close and the tenet *"Hold history is not kept"* forbids retention — nothing in the docs describes what Goal 2 (<10% expiry) or Goal 1 (median notification time) would be computed from · *tenet cascade*; *coherence is adjacency*
- **F6 (medium):** Hold cancellation is specified only for the in-transit case (`HOLDALLOC-007`) — a hold cancelled while its copy sits on a holds shelf, or before allocation, has no spec and no design text · *LLDs close enough of the solution space* (open edges are where the next agent guesses)
- **F7 (medium):** Spec files carry no `prefix:` frontmatter, and prefixes abbreviate leaf names unevenly (`HOLDALLOC` ↔ `hold-allocation`, `PICKUP` ↔ `pickup-notices`) · *specs are grep-anchored linkage*; *effective intent-tree alignment*
- **F8 (medium):** HLD has Problem, Approach, Tenets, Goals, Components — but no target users, non-goals, or Key Design Decisions · *HLD is architecture and rationale*
- **F9 (medium):** The "Allocation trigger" row ("Shelfwise must be up whenever desks are open") sets an availability posture both components inherit, but sits in the hold-allocation leaf · *intent attaches at the lowest node that dominates it* (substance governing siblings should rise to the shared parent)
- **F10 (medium):** The transit path depends on a van that runs once a day, so transit allocations systematically miss Goal 1's four hours — the expiry row records exactly this kind of cost, the transit choice does not · *tenet cascade*; *decision capture*
- **F11 (medium):** Tenets are an unordered list, yet at least two pairs can conflict (hear-once vs. Goal 2's expiry rate; sequence vs. staff attention) · *tenets capture forward-looking preference* (order them when they can collide)
- **F12 (low):** *"Patrons hear once, clearly. Each event produces one message…"* is phrased as a triggered rule — already fixed by `PICKUP-002`/`006` — rather than as a lean a future session could apply to an unanticipated channel · *tenets capture forward-looking preference*
- **F13 (low):** LLD decision rows cite "Goal 1" / "Goal 2" by ordinal, which breaks silently if the HLD's numbered list is reordered · *docs carry current intent, written to be read cold*
- **F14 (low):** "Oldest timestamp" has no tie-break for two holds placed in the same instant · *LLDs close enough of the solution space*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 13 specs (7 `HOLDALLOC`, 6 `PICKUP`), all marked `[x]`
- Arrow-path sampled: both segments attempted end-to-end (HLD §Components → LLD → specs → tests → code); both terminate at the spec layer
- Linkage metric: 0 `@spec` annotations; 0 source or test files in the repository
- Arrow-maintenance overlay: `docs/arrows/` absent, so structural checks (orphans, reverse orphans, index drift) were treated as out of reach — `/arrow-maintenance` would enumerate precisely if you install it
- Cold-read pass: run over all five LID docs; the docs read cleanly without conversational residue — F13 and F14 are what it surfaced
- Non-interactive run: no mode question was asked; the declared `Mode: Full` was taken as-is, and the report was rendered inline rather than written to disk (the skill's default)

## Offer to help

Want me to walk through any of these in detail, focus on a theme — the tenet conflicts in F3/F5 are the ones I'd open with — or work through specific items together? Picking a single finding to dig into works well too.

If you have broader questions about using LID on Shelfwise — how to shape the tests-and-code half of the arrow for a system that hooks into an external circulation event, whether the two components want a sub-HLD as they grow, or when to install the arrow-maintenance overlay — I can help with those as well.