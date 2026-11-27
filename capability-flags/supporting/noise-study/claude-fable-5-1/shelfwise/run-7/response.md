**Shelfwise — LID Coach Report**

**Posture:** *Bootstrapping — clean design layer, arrow not yet reaching tests or code.*

**Scorecard**
- ⚠ Configuration — the `## LID` block declares Full mode, but the LID directives themselves are absent from CLAUDE.md
- ✗ Arrow completeness — no tests, code, or `@spec` annotations exist in the repo, yet every spec is marked done
- ✓ HLD discipline — lean architecture and rationale, no implementation detail leaking upstream
- ✓ Mutation hygiene — no history residue, obsolete markers, or conversational fossils anywhere
- ⚠ Tenet quality — real tie-breakers, but the allocation rule contradicts one of them
- ⚠ LLD sufficiency — hold lifecycle states and a few behavioral edges are left open

The design layer is tight and reads cleanly cold: a compact HLD with genuine tenets, two well-scoped leaves, and 13 EARS specs that are properly WHEN-scoped and grep-friendly. The most valuable next step is deciding whether branch-first allocation or the "waiting is honored in sequence" tenet is the real intent, then running `/update-lid` so the instruction file catches up with the artifacts.

**Findings (10 total · 3 high · 4 medium · 3 low)**
- **F1 (high):** CLAUDE.md carries a `## LID` block (Mode, Version) but no LID directives — nothing referencing `linked-intent-dev`, so sessions don't know how to walk the arrow · *modes are declared, not inferred* — the instruction file is the foundation everything else keys off; run `/update-lid` to reconcile
- **F2 (high):** The arrow stops at specs: no tests, no code, no `@spec` annotations in the repo, yet all 13 specs are checked `[x]` · *canonical arrow shape* — every phase exists or its absence is documented; either note in CLAUDE.md where the implementation lives, or reset the markers and use `/linked-intent-dev` to walk the first change tests-first
- **F3 (high):** Hold allocation's branch-first rule (HOLDALLOC-003/004) contradicts the tenet "waiting is honored in sequence" as written — a later requester at the scanning branch beats an earlier requester elsewhere · *tenets capture forward-looking preference* and *coherence is adjacency* — adjacent levels agree; consider qualifying the tenet (sequence within a branch) or changing the rule, but pick one on the page
- **F4 (medium):** The branch-first vs. strict county-wide FIFO choice has no Decisions & Alternatives row; the courier-van rationale sits only in body prose · *decision capture* — a cold reader would still question this, so try a table row naming the rejected alternative and the accepted cost (an earlier requester elsewhere waits longer)
- **F5 (medium):** "Open hold" is used for both waiting and allocated holds; as written HOLDALLOC-003 could hand a second checked-in copy to a hold that already has one, and HOLDALLOC-002's cap is ambiguous about allocated holds · *LLDs close enough of the solution space* — consider naming the hold states (waiting, allocated, closed) in the hold-allocation design
- **F6 (medium):** Several edges are open: a hold placed on a title whose copies are already on the shelf never fires a check-in; a hold cancelled while its copy sits on the holds shelf; what "failed delivery" means for the dialer channel; whether a lapsed hold is still open between lapse and the pull scan · *LLDs close enough of the solution space* — two agents would fill these differently
- **F7 (medium):** Goals 1 and 2 need per-hold timing and expiry data that the tenet "hold history is not kept" appears to forbid; a cold reader can't tell whether patron-free aggregate counters survive deletion · *docs carry current intent, written to be read cold* — state what is retained, and at what granularity
- **F8 (low):** Tenets are an unordered list although they can conflict (the failed-delivery decision traded "staff attention goes to exceptions" against "patrons hear once"), and tenets 3 and 4 each carry a second sentence that reads as a triggered rule already covered by PICKUP-002/003 · *tenets capture forward-looking preference* — consider ordering them and trimming to the lean
- **F9 (low):** Neither design doc declares a `prefix:` (HOLDALLOC, PICKUP), and the prefixes don't derive from the directory names, so the spec-ID-to-leaf mapping lives only in convention · *specs are grep-anchored linkage* — a declared prefix lets tooling and cold readers resolve IDs without guessing
- **F10 (low):** The HLD has no Non-goals; a cold reader can't tell whether interlibrary-loan holds, patron-visible queue positions, or hold history for analytics are deliberately out · *HLD is architecture and rationale* — a short Non-goals list closes those questions cheaply

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, both design docs and both spec files under docs/intent/ (every file in the repo)
- Enumerated: 2 LLDs, 2 spec files, 13 spec IDs (7 HOLDALLOC, 6 PICKUP), all marked `[x]`
- Arrow-path sampled: both segments end-to-end from HLD section → LLD → spec; no test or code files exist to sample further
- Linkage metric: 0 `@spec` references; no `[inferred]` or `[obsolete]` markers
- Arrow-maintenance overlay: not installed (no docs/arrows/), so no index-driven cascade signals
- Not read: the capability-flags reference in the sibling skill (read permission was not granted in this run), so its flags are treated as applying

**Worth a second look:** I could not load the capability-flags reference, so I am treating its flags as applying to me. Models in my class are known to miss designs that contradict the project's own tenets. F3 is one such case I did catch, but please check both leaf designs against the HLD tenets yourself, especially "patrons hear once" and "hold history is not kept."

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.