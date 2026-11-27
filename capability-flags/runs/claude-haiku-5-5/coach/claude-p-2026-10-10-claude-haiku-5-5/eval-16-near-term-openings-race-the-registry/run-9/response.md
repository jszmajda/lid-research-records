## LID Coach report

**Posture:** Solid design, bootstrapping arrow. One tenet conflict to resolve.

**Scorecard**
- ✓ Spec form: all 15 EARS statements are well-formed, with unique, grep-friendly IDs
- ✓ HLD discipline: architecture and tenets only, with no schemas or signatures
- ✓ Mutation hygiene: present-tense docs, with no change-narration or obsolete markers
- ⚠ Tenet cascade: late-opening checkout can pass an earlier-asked entry
- ⚠ Decision capture: the 36-hour split and 20-minute delay have no Decisions rows
- ⚠ LLD sufficiency: "compatible," the core matching rule, is never defined
- ⚠ Configuration: the instruction file has no LID directive block

**Headline:** The arrow is clean for a two-component design. The HLD stays at the level of architecture, the specs are tight EARS statements, and nothing has accumulated residue. The most valuable next step is the late-opening path, which pulls against the *first asked, first served* tenet, and that trade isn't recorded anywhere. Pinning down "compatible" would let the matcher be built without guessing.

**Findings (15 total · 4 high · 7 medium · 4 low)**
- **F1 (high):** `CLAUDE.md` has a `## LID` block with Mode and Version but no `linked-intent-dev` directive. Consider running `/update-lid` to reconcile · *modes are declared, not inferred*
- **F2 (high):** Openings 36 hours or less away let any eligible signed-in account check out during the 20-minute window, so a later-asked patient can claim before an earlier entry is considered · *tenet cascade* (the *first asked, first served* tenet)
- **F3 (high):** The 36-hour split, the 20-minute delay, and checkout-before-scan have no Decisions & Alternatives row, so a cold reader can't see what was given up · *docs carry current intent* (decision capture)
- **F4 (high):** "Compatible" is the matching rule but is never defined (service, site, time window, accessibility?) · *LLDs close enough of the solution space*
- **F5 (medium):** The 36-hour boundary has no reference point or evaluation moment, and FILL-002 re-matches expired offers without saying which path applies · *scope disambiguation*
- **F6 (medium):** FILL-004 allows claims while an opening "remains free," but the design doesn't say whether an outstanding offer makes it not free · *scope disambiguation*
- **F7 (medium):** All 15 specs are marked `[x]`, but there is no code or test yet. The marker reads as "built" when it may mean "agreed" · *tests before code*
- **F8 (medium):** Intake's Decisions row selects append-only history, but only withdrawal (INTAKE-007) has an event spec. Create and change don't · *coherence is adjacency*
- **F9 (medium):** The idempotency-key row accepts "keys require expiry state," but no expiry window or "exact retry" behavior is stated · *LLDs close enough of the solution space*
- **F10 (medium):** INTAKE-006's "newly timed entry" doesn't say whether a service change gets a fresh `enteredAt`. That decides whether the change moves a patient to the back of the queue · *docs carry current intent, written to be read cold*
- **F11 (medium):** "Registry," "portal search," and "eligible" are used without definition. The HLD never mentions a registry, so a cold reader can't place the scan · *docs carry current intent, written to be read cold*
- **F12 (low):** The claim transaction (lock, recheck, ownership, outbox) is described in the LLD, but only the outbox write has a spec (FILL-007). The atomic ownership change has none · *specs are grep-anchored linkage*
- **F13 (low):** Neither LLD declares a `prefix:`, so `FILL` and `INTAKE` link to their components by convention only · *effective intent-tree alignment*
- **F14 (low):** Tenets are unordered. *First asked, first served* and *clinical fit precedes utilization* could collide, and nothing says which leans · *tenets capture forward-looking preference*
- **F15 (low):** The HLD has goals but no non-goals, target users, or measurable success metric · *HLD is architecture and rationale*

**What was audited**
- Dispatch: the project is LID-shaped (HLD and intent docs present), and the instruction file lacks the directive block. Ran a full review; F1 covers the gap.
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files.
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (FILL-001–008, INTAKE-001–007). No arrow overlay, no code, no tests.
- Arrow path: the arrow currently runs HLD → LLD → EARS only, so there is no end-to-end sampling yet.
- Cold-read pass and Decisions-table sweep: completed for all 8 rows. Seven pass as native or as adequately costed. The missing row for the 36-hour split is F3.
- Git history is a single commit, so cascade activity can't be read.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.